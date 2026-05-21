from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from groq import Groq
import os
import json
import re
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="ECHO WORK AI API", version="1.0.0")

# CORS — autoriser les appels depuis l'app Flutter web et mobile
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

client = Groq(api_key=os.environ.get("GROQ_API_KEY"))


class MessageRequest(BaseModel):
    message: str
    auteur: str
    conversation_id: str


class AnalyseResult(BaseModel):
    rappel_cree: bool
    mot_cle: str | None = None
    texte_extrait: str | None = None
    type_rappel: str | None = None  # "promesse" | "rendez-vous"
    when_text: str | None = None


SYSTEM_PROMPT = """Tu es un assistant intelligent intégré dans une application de messagerie professionnelle appelée ECHO WORK.

Ton rôle est d'analyser les messages envoyés par les utilisateurs et de détecter :
1. Les PROMESSES : engagements pris envers quelqu'un ("je vais envoyer", "je ferai", "je t'envoie", "je m'en occupe", "je te rappelle", etc.)
2. Les RENDEZ-VOUS : mentions d'une date, heure, lieu ou événement futur ("on se voit demain", "réunion lundi", "rendez-vous à 14h", "je serai là", etc.)

Réponds UNIQUEMENT avec un objet JSON valide, sans texte avant ou après, avec cette structure exacte :
{
  "rappel_cree": true ou false,
  "mot_cle": "mot clé court décrivant l'engagement (ex: Réunion, Document, Appel, Livraison)",
  "texte_extrait": "reformulation courte et claire de l'engagement détecté",
  "type_rappel": "promesse" ou "rendez-vous",
  "when_text": "indication temporelle si présente, sinon null"
}

Si aucun engagement ni rendez-vous n'est détecté, réponds :
{"rappel_cree": false}

Exemples :
- "Je t'envoie le rapport demain matin" → {"rappel_cree": true, "mot_cle": "Rapport", "texte_extrait": "Envoyer le rapport demain matin", "type_rappel": "promesse", "when_text": "Demain matin"}
- "On se voit vendredi à 15h ?" → {"rappel_cree": true, "mot_cle": "Rendez-vous", "texte_extrait": "Rendez-vous vendredi à 15h", "type_rappel": "rendez-vous", "when_text": "Vendredi à 15h"}
- "Ok super merci" → {"rappel_cree": false}
- "👍" → {"rappel_cree": false}
- "Lol" → {"rappel_cree": false}

Sois précis et ne crée pas de faux positifs. Un simple "oui" ou "d'accord" sans contexte d'engagement ne doit PAS créer de rappel."""


@app.get("/")
def root():
    return {"status": "ok", "service": "ECHO WORK AI API", "version": "1.0.0"}


@app.get("/health")
def health():
    return {"status": "healthy"}


@app.post("/analyser", response_model=AnalyseResult)
async def analyser_message(request: MessageRequest):
    # Ignorer les messages trop courts ou non-textuels
    message = request.message.strip()
    if len(message) < 5:
        return AnalyseResult(rappel_cree=False)

    # Ignorer les messages qui sont juste des emojis ou chiffres
    if re.match(r'^[\W\d\s]+$', message):
        return AnalyseResult(rappel_cree=False)

    try:
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",  # rapide et gratuit sur Groq
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": f"Analyse ce message : \"{message}\""},
            ],
            temperature=0.1,  # déterministe pour la détection
            max_tokens=200,
        )

        raw = completion.choices[0].message.content.strip()

        # Extraire le JSON de la réponse
        json_match = re.search(r'\{.*\}', raw, re.DOTALL)
        if not json_match:
            return AnalyseResult(rappel_cree=False)

        data = json.loads(json_match.group())

        return AnalyseResult(
            rappel_cree=data.get("rappel_cree", False),
            mot_cle=data.get("mot_cle"),
            texte_extrait=data.get("texte_extrait"),
            type_rappel=data.get("type_rappel"),
            when_text=data.get("when_text"),
        )

    except json.JSONDecodeError:
        return AnalyseResult(rappel_cree=False)
    except Exception as e:
        # Ne jamais bloquer l'envoi du message à cause de l'IA
        print(f"AI analysis error: {e}")
        return AnalyseResult(rappel_cree=False)
