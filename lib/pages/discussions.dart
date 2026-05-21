import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/fonctionalites/messagerie.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:echo_work/widgets/nouveau_rappel_sheet.dart';
import 'package:flutter/material.dart';

class Discussions extends StatefulWidget {
  const Discussions({
    super.key,
    required this.email,
    required this.uid,
    this.initials,
    this.avatarColor,
    this.isGroup = false,
    this.groupId,
  });

  final String email;
  final String uid;
  final String? initials;
  final Color? avatarColor;
  final bool isGroup;
  final String? groupId;

  @override
  State<Discussions> createState() => _DiscussionsState();
}

class _DiscussionsState extends State<Discussions> {
  final messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // chatId = les deux uids triés et joints par "_"
  String get chatId {
    final ids = [Auth().currentUser!.uid, widget.uid]..sort();
    return ids.join("_");
  }

  // Stream qui écoute en temps réel les messages du chat
  Stream<QuerySnapshot> get messagesStream {
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
    final currentUid = Auth().currentUser!.uid;
    final String partnerName = widget.email.split('@')[0];
    final String partnerInitials =
        widget.initials ??
        (partnerName.isNotEmpty ? partnerName[0].toUpperCase() : "U");
    final Color partnerColor = widget.avatarColor ?? const Color(0xFFE50914);

    return Scaffold(
      backgroundColor: Colors.black,

      // ─── PREMIUM CUSTOM APP BAR ───────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: partnerColor,
              child: Text(
                partnerInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    partnerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: Colors.green,
                        size: 8,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "En ligne",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.videocam_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appels vidéo indisponibles en mode démo"),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.phone_outlined,
              color: Colors.white,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Appels vocaux indisponibles en mode démo"),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          const Divider(color: Color(0xFF1E1E1E), height: 1),

          // ─── LISTE DES MESSAGES ───────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        "Erreur:\n${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFE50914)),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE50914)),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0E0E0E),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF1E1E1E),
                              ),
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFFE50914),
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Sécurité de bout en bout",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Les messages sont chiffrés. Saisissez votre premier message ci-dessous pour démarrer la discussion.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Faire défiler automatiquement vers le bas après le chargement des messages
                _scrollToBottom();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final isMe = data["senderUid"] == currentUid;

                    // Formater l'heure du message
                    String timeText = "";
                    if (data["timestamp"] != null) {
                      try {
                        final DateTime date = (data["timestamp"] as Timestamp)
                            .toDate();
                        timeText =
                            "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                      } catch (_) {
                        timeText = "";
                      }
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFFE50914)
                                : const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                data["message"] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    timeText,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 10,
                                    ),
                                  ),
                                  if (isMe) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.done_all,
                                      color: Colors.white70,
                                      size: 13,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ─── CHAMP DE SAISIE PREMIUM (PILL STYLE) ───────────────────────────
          Container(
            color: Colors.black,
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 20,
            ),
            child: Row(
              children: [
                // Bouton Pièce Jointe (+)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Ajout de fichiers bientôt disponible"),
                      ),
                    );
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E1E1E),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),

                // Champ de texte
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E0E0E),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF1E1E1E),
                        width: 1.2,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: "Nouveau Message...",
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Bouton Envoyer
                GestureDetector(
                  onTap: () async {
                    final text = messageController.text.trim();
                    if (text.isEmpty) return;

                    // Vider le champ et scroller immédiatement — UX fluide
                    messageController.clear();
                    _scrollToBottom();

                    // Envoyer + analyser en parallèle
                    final result = await Messagerie().sendMessage(
                      currentUid,
                      widget.uid,
                      text,
                    );

                    // Si l'IA détecte une promesse/RDV → afficher le sheet
                    if (result.rappelCree && mounted) {
                      final partnerName = widget.email.contains('@')
                          ? widget.email.split('@')[0]
                          : widget.email;

                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => NouveauRappelSheet(
                          messageText: result.texteExtrait ?? text,
                          partnerName: partnerName,
                          partnerUid: widget.uid,
                          motCle: result.motCle,
                          typeRappel: result.typeRappel,
                          whenText: result.whenText,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFE50914),
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 18,
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
