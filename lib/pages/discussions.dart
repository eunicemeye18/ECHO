import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clone_whatsapp_base_code/fonctionalites/messagerie.dart';
import 'package:clone_whatsapp_base_code/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';

class Discussions extends StatefulWidget {
  const Discussions({super.key, required this.email, required this.uid});
  final String email; // email de l'interlocuteur (affiché dans l'appBar)
  final String uid;   // uid de l'interlocuteur
  @override
  State<Discussions> createState() => _DiscussionsState();
}

class _DiscussionsState extends State<Discussions> {
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // chatId = les deux uids triés et joints par "_"
  // Ex: "aaa_bbb" (toujours le même peu importe qui envoie)
  String get chatId {
    List ids = [Auth().currentUser!.uid, widget.uid];
    ids.sort();
    String id = ids.join("_");
    print("🔑 chatId calculé: $id");
    return id;
  }

  // Stream qui écoute en temps réel les messages du chat
  // orderBy timestamp = messages dans l'ordre chronologique
  Stream<QuerySnapshot> get messagesStream {
    print("🎧 Abonnement au stream pour chatId: $chatId");
    return FirebaseFirestore.instance
        .collection("Chats")
        .doc(chatId)
        .collection(chatId)
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Fait défiler automatiquement vers le dernier message
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // On récupère l'uid de l'user connecté une seule fois ici
    final currentUid = Auth().currentUser!.uid;
    print("👤 currentUid dans build: $currentUid");
    print("👤 receiverUid           : ${widget.uid}");

    return Scaffold(
      appBar: AppBar(title: Text(widget.email)),
      body: Column(
        children: [

          // ─── LISTE DES MESSAGES ───────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {

                // Log de l'état du stream à chaque rebuild
                print("── StreamBuilder rebuild ──");
                print("   connectionState : ${snapshot.connectionState}");
                print("   hasData         : ${snapshot.hasData}");
                print("   hasError        : ${snapshot.hasError}");
                print("   error           : ${snapshot.error}");
                print("   docs count      : ${snapshot.data?.docs.length}");

                // Erreur Firestore (ex: permission denied)
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // En attente de la première réponse Firestore
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Pas encore de données (stream ouvert mais vide)
                if (!snapshot.hasData) {
                  print("⚠️ snapshot ouvert mais pas de data");
                  return const Center(child: Text("Chargement..."));
                }

                final docs = snapshot.data!.docs;
                print("📋 Nombre de messages reçus: ${docs.length}");

                // Aucun message dans ce chat
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aucun message\nCommencez la conversation !",
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                // Scroll vers le bas quand les messages sont chargés
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    // isMe = true si c'est moi qui ai envoyé ce message
                    final isMe = data["senderUid"] == currentUid;

                    print("💬 Message[$index] | isMe:$isMe | ${data['message']}");

                    return Align(
                      // Mes messages à droite, les autres à gauche
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        // Largeur max = 70% de l'écran
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          // Rouge pour moi, gris pour l'autre
                          color: isMe ? Colors.red : Colors.grey[300],
                          // Coins arrondis style WhatsApp
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          data["message"] ?? "",
                          style: TextStyle(
                            color: isMe ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ─── CHAMP DE SAISIE ──────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.black),
                    maxLines: null, // permet les messages sur plusieurs lignes
                    decoration: InputDecoration(
                      hintText: "Nouveau Message",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton envoyer
                GestureDetector(
                  onTap: () {
                    print("🖱️ Bouton envoyer appuyé");
                    final text = messageController.text.trim();

                    // On n'envoie pas si le champ est vide
                    if (text.isNotEmpty) {
                      Messagerie().sendMessage(currentUid, widget.uid, text);
                      messageController.clear();
                    } else {
                      print("⚠️ Message vide, envoi annulé");
                    }
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}