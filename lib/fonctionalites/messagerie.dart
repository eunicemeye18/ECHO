import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  /// URL du backend FastAPI déployé sur Vercel.
  /// Après déploiement, remplacer par l'URL réelle.
  /// Ex: "https://echo-xxxx.vercel.app"
  static const String _apiUrl = "https://echo-work-ai.vercel.app";

  final Dio _dio = Dio(
    BaseOptions(
      // Render free tier peut avoir un cold start de ~15s
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 15),
      headers: {"Content-Type": "application/json"},
    ),
  );

  /// Envoie un message dans Firestore et retourne le résultat de l'analyse IA.
  /// L'envoi Firestore est prioritaire et non bloqué par l'IA.
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

    // ── 3. Sauvegarder dans Firestore (immédiat) ───────────────────────────
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

    return _analyserAvecIA(message, currentUid, chatId);
  }

  /// Appel HTTP vers le backend FastAPI.
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

      debugPrint("🤖 IA: $data");

      if (!rappelCree) return IaAnalyseResult.none();

      return IaAnalyseResult(
        rappelCree: true,
        motCle: data["mot_cle"] as String?,
        texteExtrait: data["texte_extrait"] as String?,
        typeRappel: data["type_rappel"] as String?,
        whenText: data["when_text"] as String?,
      );
    } on DioException catch (e) {
      debugPrint("❌ IA réseau: ${e.message}");
      return IaAnalyseResult.none();
    } catch (e) {
      debugPrint("❌ IA erreur: $e");
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
