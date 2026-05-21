import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class Messagerie {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final Dio _dio = Dio();
  
  // URL de ton API déployée
  static const String _apiUrl = "https://unarmored-salvaging-tragedy.ngrok-free.dev/";

  Future<void> sendMessage(
    String currentUid,
    String receiverUid,
    String message, {
    String type = "text",
    String? fileUrl,
    String? fileName,
    String? fileSize,
    bool isGroup = false,
  }) async {
    String chatId;
    if (isGroup) {
      chatId = receiverUid;
    } else {
      List ids = [currentUid, receiverUid];
      ids.sort();
      chatId = ids.join("_");
    }

    Map<String, dynamic> messageData = {
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

    // 1. Envoyer le message dans Firestore
    await db.collection("Chats").doc(chatId).collection(chatId).add(messageData);

    // 2. Mettre à jour le dernier message dans le groupe si applicable
    if (isGroup) {
      try {
        // Obtenir le nom d'affichage de l'auteur
        final userDoc = await db.collection("users").doc(currentUid).get();
        final String authorName = userDoc.exists 
            ? (userDoc.data()?["name"] ?? userDoc.data()?["email"]?.split('@')[0] ?? "Quelqu'un")
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
        print("❌ Erreur lors de la mise à jour du groupe: $e");
      }
    }

    // 3. Analyser le message avec l'IA
    if (type == "text" && !isGroup) {
      try {
        final response = await _dio.post(
          "$_apiUrl/analyser",
          data: {
            "message": message,
            "auteur": currentUid,
            "conversation_id": chatId,
          },
        );

        final resultat = response.data;
        print("🤖 IA: ${resultat}");

        // Si promesse détectée → sauvegarder dans Firestore
        if (resultat["rappel_cree"] == true) {
          await db.collection("Rappels").add({
            "message": message,
            "auteur": currentUid,
            "chatId": chatId,
            "mot_cle": resultat["mot_cle"] ?? "Engagement",
            "timestamp": Timestamp.now(),
            "statut": "actif",
            "type": "promesse",
            "location": "N/A",
            "whenText": "Détecté par l'IA",
            "dateDetail": "Détecté par l'IA",
            "partnerName": "Contact",
            "partnerUid": receiverUid,
            "sourceText": "Discussion",
          });

          print("✅ Promesse détectée et sauvegardée !");
        }
      } catch (e) {
        print("❌ Erreur IA: $e");
      }
    }
  }
}
