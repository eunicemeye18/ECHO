"""
ECHO WORK AI API — Backend FastAPI
Déployé sur Render.com

Variables d'environnement requises :
  GROQ_API_KEY  → https://console.groq.com (gratuit)
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from groq import Groq
import os
import json
import re
from dotenv import load_dotenv

load_dotenv()

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(title="ECHO WORK AI API", version="1.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Groq client ────────────────────────────────────────────────────────────────
_groq_key = os.environ.get("GROQ_API_KEY", "")
client = Groq(api_key=_groq_key) if _groq_key else None

# ── Modèles Pydantic ───────────────────────────────────────────────────────────
class MessageRequest(BaseModel):
    message: str
    auteur: str
    conversation_id: str


class AnalyseResult(BaseModel):
    rappel_cree: bool
    mot_cle: str | None = None
    texte_extrait: str | None = None
    type_rappel: str | None = None   # "promesse" | "rendez-vous"
    when_text: str | None = None


# ── Prompt système ─────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """Tu es un assistant intelligent intégré dans une application de messagerie professionnelle appelée ECHO WORK.

Ton rôle est d'analyser les messages envoyés par les utilisateurs et de détecter :
1. Les PROMESSES : engagements pris envers quelqu'un ("je vais envoyer", "je ferai", "je t'envoie", "je m'en occupe", "je te rappelle", "je prépare", "je gère", etc.)
2. Les RENDEZ-VOUS : mentions d'une date, heure, lieu ou événement futur ("on se voit demain", "réunion lundi", "rendez-vous à 14h", "je serai là vendredi", "meeting à 10h", etc.)

Réponds UNIQUEMENT avec un objet JSON valide, sans texte avant ou après :
{
  "rappel_cree": true,
  "mot_cle": "mot clé court (ex: Rapport, Réunion, Appel, Livraison, Document)",
  "texte_extrait": "reformulation courte et claire de l'engagement",
  "type_rappel": "promesse" ou "rendez-vous",
  "when_text": "indication temporelle si présente, sinon null"
}

Si aucun engagement n'est détecté : {"rappel_cree": false}

Exemples :
- "Je t'envoie le rapport demain matin" → {"rappel_cree": true, "mot_cle": "Rapport", "texte_extrait": "Envoyer le rapport demain matin", "type_rappel": "promesse", "when_text": "Demain matin"}
- "On se voit vendredi à 15h ?" → {"rappel_cree": true, "mot_cle": "Rendez-vous", "texte_extrait": "Rendez-vous vendredi à 15h", "type_rappel": "rendez-vous", "when_text": "Vendredi à 15h"}
- "Je m'en occupe" → {"rappel_cree": true, "mot_cle": "Engagement", "texte_extrait": "S'occuper de la tâche", "type_rappel": "promesse", "when_text": null}
- "Ok super merci" → {"rappel_cree": false}
- "👍" → {"rappel_cree": false}
- "D'accord" → {"rappel_cree": false}

Ne crée PAS de rappel pour de simples acquiescements sans engagement explicite."""


# ── Routes ─────────────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {
        "status": "ok",
        "service": "ECHO WORK AI API",
        "version": "1.1.0",
        "groq_configured": client is not None,
    }


@app.get("/health")
def health():
    return {"status": "healthy", "groq_ready": client is not None}


@app.post("/analyser", response_model=AnalyseResult)
async def analyser_message(request: MessageRequest):
    message = request.message.strip()

    # ── Filtres rapides (évite des appels inutiles à l'API) ────────────────
    if len(message) < 5:
        return AnalyseResult(rappel_cree=False)

    # Message composé uniquement d'emojis / ponctuation / chiffres
    if re.match(r'^[\W\d\s]+$', message):
        return AnalyseResult(rappel_cree=False)

    # Groq non configuré → fallback gracieux
    if client is None:
        return AnalyseResult(rappel_cree=False)

    try:
        completion = client.chat.completions.create(
            model="llama-3.1-8b-instant",
            messages=[
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": f'Analyse ce message : "{message}"'},
            ],
            temperature=0.1,
            max_tokens=200,
        )

        raw = completion.choices[0].message.content.strip()

        # Extraire le bloc JSON même si le modèle ajoute du texte autour
        json_match = re.search(r'\{[^{}]*\}', raw, re.DOTALL)
        if not json_match:
            return AnalyseResult(rappel_cree=False)

        data = json.loads(json_match.group())

        if not data.get("rappel_cree", False):
            return AnalyseResult(rappel_cree=False)

        return AnalyseResult(
            rappel_cree=True,
            mot_cle=data.get("mot_cle"),
            texte_extrait=data.get("texte_extrait"),
            type_rappel=data.get("type_rappel"),
            when_text=data.get("when_text"),
        )

    except json.JSONDecodeError:
        return AnalyseResult(rappel_cree=False)
    except Exception as e:
        print(f"[AI ERROR] {e}")
        return AnalyseResult(rappel_cree=False)
