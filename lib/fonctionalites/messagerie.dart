import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Résultat retourné par l'analyse IA.
class IaAnalyseResult {
  final bool rappelCree;
  final String? motCle;
  final String? texteExtrait;
  final String? typeRappel; // "promesse" | "rendez-vous"
  final String? whenText;

  const IaAnalyseResult({
    required this.rappelCree,
    this.motCle,
    this.texteExtrait,
    this.typeRappel,
    this.whenText,
  });

  factory IaAnalyseResult.none() => const IaAnalyseResult(rappelCree: false);
}

class Messagerie {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Clé API Gemini — passée via --dart-define à la compilation
  // ou définie ici directement pour le déploiement CI/CD
  static const String _geminiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // Modèle Gemini initialisé une seule fois (singleton)
  static GenerativeModel? _model;

  static GenerativeModel? _getModel() {
    if (_model != null) return _model;
    final key = _geminiKey.isNotEmpty
        ? _geminiKey
        : 'AIzaSyBSDRMflHAG2nXlkL8qqBofsMeEazYkjLE';
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: key,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        maxOutputTokens: 200,
        responseMimeType: 'application/json',
      ),
    );
    return _model;
  }

  static const String _systemPrompt = '''
Tu es un assistant intégré dans l'application de messagerie professionnelle ECHO WORK.

Analyse ce message et détecte s'il contient :
1. Une PROMESSE : engagement explicite ("je vais envoyer", "je ferai", "je t'envoie", "je m'en occupe", "je te rappelle", "je prépare", "je gère", "je livre")
2. Un RENDEZ-VOUS : date/heure/lieu futur ("on se voit demain", "réunion lundi", "rendez-vous à 14h", "meeting à 10h", "je serai là vendredi")

Réponds UNIQUEMENT avec ce JSON (rien d'autre) :
- Si engagement détecté : {"rappel_cree": true, "mot_cle": "mot court", "texte_extrait": "reformulation claire", "type_rappel": "promesse" ou "rendez-vous", "when_text": "indication temporelle ou null"}
- Sinon : {"rappel_cree": false}

Exemples :
- "Je t'envoie le rapport demain" → {"rappel_cree": true, "mot_cle": "Rapport", "texte_extrait": "Envoyer le rapport demain", "type_rappel": "promesse", "when_text": "Demain"}
- "Réunion vendredi à 14h" → {"rappel_cree": true, "mot_cle": "Réunion", "texte_extrait": "Réunion vendredi à 14h", "type_rappel": "rendez-vous", "when_text": "Vendredi à 14h"}
- "Ok merci" → {"rappel_cree": false}
- "👍" → {"rappel_cree": false}
''';

  /// Envoie un message dans Firestore et retourne le résultat de l'analyse IA.
  Future<IaAnalyseResult> sendMessage(
    String currentUid,
    String receiverUid,
    String message, {
    String type = "text",
    String? fileUrl,
    String? fileName,
    String? fileSize,
    bool isGroup = false,
  }) async {
    // ── 1. Calculer le chatId ──────────────────────────────────────────────
    final String chatId;
    if (isGroup) {
      chatId = receiverUid;
    } else {
      final ids = [currentUid, receiverUid]..sort();
      chatId = ids.join("_");
    }

    // ── 2. Construire le payload ───────────────────────────────────────────
    final Map<String, dynamic> messageData = {
      "senderUid": currentUid,
      "receiverUid": receiverUid,
      "message": message,
      "chatId": chatId,
      "timestamp": Timestamp.now(),
      "type": type,
    };
    if (fileUrl != null) messageData["fileUrl"] = fileUrl;
    if (fileName != null) messageData["fileName"] = fileName;
    if (fileSize != null) messageData["fileSize"] = fileSize;

    // ── 3. Sauvegarder dans Firestore (immédiat, prioritaire) ──────────────
    await db
        .collection("Chats")
        .doc(chatId)
        .collection(chatId)
        .add(messageData);

    // ── 4. Mettre à jour le groupe si applicable ───────────────────────────
    if (isGroup) {
      _updateGroupLastMessage(currentUid, chatId, message, type, fileName);
    }

    // ── 5. Analyse IA (texte 1-to-1 uniquement) ───────────────────────────
    if (type != "text" || isGroup) return IaAnalyseResult.none();

    return _analyserAvecGemini(message);
  }

  /// Appel direct à l'API Gemini depuis Flutter.
  Future<IaAnalyseResult> _analyserAvecGemini(String message) async {
    // Ignorer les messages trop courts ou composés d'emojis
    if (message.trim().length < 5) return IaAnalyseResult.none();

    final model = _getModel();
    if (model == null) return IaAnalyseResult.none();

    try {
      final prompt = '$_systemPrompt\nMessage à analyser : "$message"';
      final response = await model.generateContent([Content.text(prompt)]);
      final raw = response.text?.trim() ?? '';

      if (raw.isEmpty) return IaAnalyseResult.none();

      debugPrint('🤖 Gemini raw: $raw');

      // Parser le JSON retourné
      final data = jsonDecode(raw) as Map<String, dynamic>;

      if (data['rappel_cree'] != true) return IaAnalyseResult.none();

      return IaAnalyseResult(
        rappelCree: true,
        motCle: data['mot_cle'] as String?,
        texteExtrait: data['texte_extrait'] as String?,
        typeRappel: data['type_rappel'] as String?,
        whenText: data['when_text'] as String?,
      );
    } on GenerativeAIException catch (e) {
      debugPrint('❌ Gemini API error: ${e.message}');
      return IaAnalyseResult.none();
    } catch (e) {
      debugPrint('❌ IA erreur: $e');
      return IaAnalyseResult.none();
    }
  }

  /// Met à jour le dernier message du groupe.
  Future<void> _updateGroupLastMessage(
    String currentUid,
    String chatId,
    String message,
    String type,
    String? fileName,
  ) async {
    try {
      final userDoc = await db.collection("users").doc(currentUid).get();
      final String authorName = userDoc.exists
          ? (userDoc.data()?["name"] ??
                userDoc.data()?["email"]?.split('@')[0] ??
                "Quelqu'un")
          : "Quelqu'un";

      String displayMsg = message;
      if (type == "image") displayMsg = "📷 Photo";
      if (type == "file") displayMsg = "📄 Fichier: $fileName";

      await db.collection("groups").doc(chatId).update({
        "lastMessage": "$authorName: $displayMsg",
        "lastMessageTime": Timestamp.now(),
      });
    } catch (e) {
      debugPrint("❌ Groupe update: $e");
    }
  }
}
