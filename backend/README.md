# ECHO WORK AI Backend

API FastAPI déployée sur **Vercel** (serverless, gratuit, URL fixe).
LLM : **Google Gemini 2.0 Flash** (gratuit, pas de carte bancaire).

---

## Déploiement (5 minutes)

### 1. Clé API Gemini (gratuite, sans carte bancaire)

1. Aller sur **[aistudio.google.com/apikey](https://aistudio.google.com/apikey)**
2. Se connecter avec un compte Google
3. Cliquer **"Create API key"** → copier la clé

### 2. Déployer sur Vercel

1. Aller sur **[vercel.com](https://vercel.com)** → **"Add New Project"**
2. Importer le repo GitHub `eunicemeye18/ECHO`
3. **Ne pas changer** le Root Directory (laisser `/`)
4. Dans **"Environment Variables"** → ajouter :
   - `GEMINI_API_KEY` = (ta clé Gemini)
5. Cliquer **"Deploy"**
6. Copier l'URL générée (ex: `https://echo-xxxx.vercel.app`)

### 3. Mettre à jour l'URL dans Flutter

Dans `lib/fonctionalites/messagerie.dart` :
```dart
static const String _apiUrl = "https://echo-xxxx.vercel.app";
```

### 4. Activer le redéploiement automatique via GitHub Actions

1. Dans Vercel : **Settings → Tokens** → créer un token
2. Dans GitHub : **Settings → Secrets → Actions** → ajouter :
   - `VERCEL_TOKEN` = token Vercel
   - `VERCEL_ORG_ID` = visible dans Vercel Settings → General
   - `VERCEL_PROJECT_ID` = visible dans le projet Vercel → Settings

---

## Test de l'API

```bash
curl https://echo-xxxx.vercel.app/health
# → {"status":"healthy","gemini_ready":true}

curl -X POST https://echo-xxxx.vercel.app/analyser \
  -H "Content-Type: application/json" \
  -d '{"message":"Je t envoie le rapport demain","auteur":"uid123","conversation_id":"chat_abc"}'
# → {"rappel_cree":true,"mot_cle":"Rapport","texte_extrait":"Envoyer le rapport demain","type_rappel":"promesse","when_text":"Demain"}
```

---

## Structure

```
api/
  index.py          ← FastAPI app (point d'entrée Vercel)
  requirements.txt  ← dépendances Python
vercel.json         ← config déploiement Vercel
```
