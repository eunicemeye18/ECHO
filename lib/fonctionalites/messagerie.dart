import 'package:cloud_firestore/cloud_firestore.dart';

class Messagerie {
  FirebaseFirestore db = FirebaseFirestore.instance;

  // Envoie un message dans la sous-collection du chat entre les deux users
  Future<void> sendMessage(
    String currentUid,
    String receiverUid,
    String message,
  ) async {
    // On crée un chatId unique en triant les uids pour que
    // A→B et B→A donnent toujours le même chatId
    List ids = [currentUid, receiverUid];
    ids.sort();
    String chatId = ids.join("_");

    print("📤 sendMessage appelé");
    print("   currentUid : $currentUid");
    print("   receiverUid: $receiverUid");
    print("   chatId     : $chatId");
    print("   message    : $message");

    try {
      await db
          .collection("Chats")   // collection principale
          .doc(chatId)            // document = identifiant du chat
          .collection(chatId)    // sous-collection = les messages
          .add({
        "senderUid": currentUid,
        "receiverUid": receiverUid,
        "message": message,
        "chatId": chatId,
        "timestamp": Timestamp.now(),
      });

      print("✅ Message écrit dans Firestore avec succès !");
    } catch (e) {
      print("🔴 Erreur lors de l'envoi : $e");
    }
  }
}