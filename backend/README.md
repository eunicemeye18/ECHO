# ECHO WORK AI Backend

API FastAPI qui analyse les messages de l'app ECHO WORK pour détecter automatiquement les promesses et rendez-vous.

## Stack

- **FastAPI** + **Uvicorn**
- **Groq** (LLaMA 3.1 8B Instant) — gratuit, ~200ms de latence
- Déployé sur **Render.com** (free tier)

---

## Déploiement (une seule fois, ~5 minutes)

### 1. Clé API Groq (gratuite)

1. Aller sur [console.groq.com](https://console.groq.com)
2. Créer un compte (gratuit, pas de carte bancaire)
3. **API Keys** → **Create API Key** → copier la clé

### 2. Déployer sur Render.com

1. Aller sur [render.com](https://render.com) → **New Web Service**
2. Connecter le repo GitHub `eunicemeye18/ECHO`
3. Configurer :
   - **Root Directory** : `backend`
   - **Build Command** : `pip install -r requirements.txt`
   - **Start Command** : `uvicorn main:app --host 0.0.0.0 --port $PORT`
4. **Environment Variables** → ajouter :
   - `GROQ_API_KEY` = (ta clé Groq)
5. Cliquer **Deploy**
6. Copier l'URL générée (ex: `https://echo-work-ai-xxxx.onrender.com`)

### 3. Mettre à jour l'URL dans Flutter

Dans `lib/fonctionalites/messagerie.dart`, remplacer :
```dart
static const String _apiUrl = "https://echo-work-ai.onrender.com";
```
par l'URL réelle de ton service Render.

### 4. Activer le redéploiement automatique via GitHub Actions

1. Dans Render : **Settings** → **Deploy Hook** → copier l'URL
2. Dans GitHub : **Settings** → **Secrets and variables** → **Actions** → **New secret**
   - Nom : `RENDER_DEPLOY_HOOK_URL`
   - Valeur : l'URL du deploy hook Render

Désormais, chaque push sur `main` qui modifie `backend/` redéploie automatiquement le backend.

---

## Test local

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env   # puis remplir GROQ_API_KEY
uvicorn main:app --reload
```

Tester :
```bash
curl -X POST http://localhost:8000/analyser \
  -H "Content-Type: application/json" \
  -d '{"message": "Je t envoie le rapport demain", "auteur": "uid123", "conversation_id": "chat_abc"}'
```

Réponse attendue :
```json
{
  "rappel_cree": true,
  "mot_cle": "Rapport",
  "texte_extrait": "Envoyer le rapport demain",
  "type_rappel": "promesse",
  "when_text": "Demain"
}
```

---

## Endpoints

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | `/` | Statut de l'API |
| GET | `/health` | Health check |
| POST | `/analyser` | Analyser un message |
