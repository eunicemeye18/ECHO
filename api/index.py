"""
ECHO WORK AI API — Déployé sur Vercel (Serverless Python)
LLM : Google Gemini 2.0 Flash (gratuit, pas de carte bancaire)

Variable d'environnement requise :
  GEMINI_API_KEY  → https://aistudio.google.com/apikey (gratuit)
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import os
import json
import re

# ── App ────────────────────────────────────────────────────────────────────────
app = FastAPI(title="ECHO WORK AI API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Gemini client ──────────────────────────────────────────────────────────────
_gemini_key = os.environ.get("GEMINI_API_KEY", "")
_model = None

if _gemini_key:
    genai.configure(api_key=_gemini_key)
    _model = genai.GenerativeModel(
        model_name="gemini-2.0-flash",
        generation_config=genai.GenerationConfig(
            temperature=0.1,
            max_output_tokens=200,
            response_mime_type="application/json",
        ),
    )

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
PROMPT_TEMPLATE = """Tu es un assistant intégré dans l'application de messagerie professionnelle ECHO WORK.

Analyse ce message et détecte s'il contient :
1. Une PROMESSE : engagement explicite ("je vais envoyer", "je ferai", "je t'envoie", "je m'en occupe", "je te rappelle", "je prépare", "je gère", "je livre")
2. Un RENDEZ-VOUS : date/heure/lieu futur ("on se voit demain", "réunion lundi", "rendez-vous à 14h", "meeting à 10h", "je serai là vendredi")

Message à analyser : "{message}"

Réponds UNIQUEMENT avec ce JSON (rien d'autre) :
- Si engagement détecté : {{"rappel_cree": true, "mot_cle": "mot court", "texte_extrait": "reformulation claire", "type_rappel": "promesse" ou "rendez-vous", "when_text": "indication temporelle ou null"}}
- Sinon : {{"rappel_cree": false}}

Exemples :
- "Je t'envoie le rapport demain" → {{"rappel_cree": true, "mot_cle": "Rapport", "texte_extrait": "Envoyer le rapport demain", "type_rappel": "promesse", "when_text": "Demain"}}
- "Réunion vendredi à 14h" → {{"rappel_cree": true, "mot_cle": "Réunion", "texte_extrait": "Réunion vendredi à 14h", "type_rappel": "rendez-vous", "when_text": "Vendredi à 14h"}}
- "Ok merci" → {{"rappel_cree": false}}
- "👍" → {{"rappel_cree": false}}"""


# ── Routes ─────────────────────────────────────────────────────────────────────
@app.get("/")
def root():
    return {
        "status": "ok",
        "service": "ECHO WORK AI API",
        "version": "2.0.0",
        "model": "gemini-2.0-flash",
        "ready": _model is not None,
    }


@app.get("/health")
def health():
    return {"status": "healthy", "gemini_ready": _model is not None}


@app.post("/analyser", response_model=AnalyseResult)
async def analyser_message(request: MessageRequest):
    message = request.message.strip()

    # ── Filtres rapides ────────────────────────────────────────────────────
    if len(message) < 5:
        return AnalyseResult(rappel_cree=False)

    # Emojis / ponctuation / chiffres seuls
    if re.match(r'^[\W\d\s]+$', message):
        return AnalyseResult(rappel_cree=False)

    # Modèle non configuré
    if _model is None:
        return AnalyseResult(rappel_cree=False)

    try:
        prompt = PROMPT_TEMPLATE.format(message=message)
        response = _model.generate_content(prompt)
        raw = response.text.strip()

        # Extraire le JSON (Gemini avec response_mime_type=json retourne du JSON pur)
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
