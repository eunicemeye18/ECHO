import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Résultat retourné par l'analyse IA.
/// Si [rappelCree] est true, [texteExtrait], [motCle] et [typeRappel] sont renseignés.
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

  // URL du backend déployé sur Render.
  // Remplacer par l'URL réelle après déploiement.
  static const String _apiUrl = "https://echo-work-ai.onrender.com";

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  /// Envoie un message et retourne le résultat de l'analyse IA.
  /// L'envoi Firestore est immédiat ; l'analyse IA est lancée en parallèle
  /// et son résultat est retourné pour que l'UI puisse réagir.
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
    String chatId;
    if (isGroup) {
      chatId = receiverUid;
    } else {
      final ids = [currentUid, receiverUid]..sort();
      chatId = ids.join("_");
    }

    // ── 2. Construire le payload du message ───────────────────────────────
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

    // ── 3. Sauvegarder dans Firestore (prioritaire, non bloqué par l'IA) ──
    await db
        .collection("Chats")
        .doc(chatId)
        .collection(chatId)
        .add(messageData);

    // ── 4. Mettre à jour le lastMessage du groupe si applicable ───────────
    if (isGroup) {
      _updateGroupLastMessage(currentUid, chatId, message, type, fileName);
    }

    // ── 5. Analyse IA (uniquement messages texte 1-to-1) ──────────────────
    if (type != "text" || isGroup) return IaAnalyseResult.none();

    return _analyserAvecIA(message, currentUid, chatId);
  }

  /// Appel HTTP vers le backend FastAPI — non bloquant pour l'UX.
  Future<IaAnalyseResult> _analyserAvecIA(
    String message,
    String auteur,
    String conversationId,
  ) async {
    try {
      final response = await _dio.post(
        "$_apiUrl/analyser",
        data: {
          "message": message,
          "auteur": auteur,
          "conversation_id": conversationId,
        },
      );

      if (response.statusCode != 200 || response.data == null) {
        return IaAnalyseResult.none();
      }

      final data = response.data as Map<String, dynamic>;
      final bool rappelCree = data["rappel_cree"] == true;

      debugPrint("🤖 IA résultat: $data");

      if (!rappelCree) return IaAnalyseResult.none();

      return IaAnalyseResult(
        rappelCree: true,
        motCle: data["mot_cle"] as String?,
        texteExtrait: data["texte_extrait"] as String?,
        typeRappel: data["type_rappel"] as String?,
        whenText: data["when_text"] as String?,
      );
    } on DioException catch (e) {
      debugPrint("❌ Erreur IA (réseau): ${e.message}");
      return IaAnalyseResult.none();
    } catch (e) {
      debugPrint("❌ Erreur IA: $e");
      return IaAnalyseResult.none();
    }
  }

  /// Met à jour le dernier message affiché dans la liste des groupes.
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
      if (type == "image") {
        displayMsg = "📷 Photo";
      } else if (type == "file") {
        displayMsg = "📄 Fichier: $fileName";
      }

      await db.collection("groups").doc(chatId).update({
        "lastMessage": "$authorName: $displayMsg",
        "lastMessageTime": Timestamp.now(),
      });
    } catch (e) {
      debugPrint("❌ Erreur mise à jour groupe: $e");
    }
  }
}
