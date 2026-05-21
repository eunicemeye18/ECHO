import 'package:echo_work/pages/discussions.dart';
import 'package:echo_work/pages/notifications_page.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:echo_work/widgets/create_group_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? currentUser = Auth().currentUser;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedCategory = "Tous";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _seedMockUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _seedMockUsers() async {
    try {
      final currentUid = currentUser?.uid;
      if (currentUid == null) return;

      final usersCollection = FirebaseFirestore.instance.collection("users");
      final groupsCollection = FirebaseFirestore.instance.collection("groups");

      final mockUsers = [
        {
          "uid": "sara_uid",
          "email": "sara@echo.work",
          "name": "Sara",
          "initials": "S",
          "color": 0xFFE50914,
          "isOnline": true,
          "isFavorite": true,
        },
        {
          "uid": "lucas_uid",
          "email": "lucas@echo.work",
          "name": "Lucas",
          "initials": "L",
          "color": 0xFF2E7D32,
          "isOnline": true,
          "isFavorite": false,
        },
        {
          "uid": "maman_uid",
          "email": "maman@echo.work",
          "name": "Maman",
          "initials": "M",
          "color": 0xFF8D6E63,
          "isOnline": false,
          "isFavorite": true,
        },
        {
          "uid": "mehdi_uid",
          "email": "mehdi@echo.work",
          "name": "Mehdi",
          "initials": "M",
          "color": 0xFF5E35B1,
          "isOnline": true,
          "isFavorite": false,
        },
        {
          "uid": "camille_uid",
          "email": "camille@echo.work",
          "name": "Camille",
          "initials": "C",
          "color": 0xFF00695C,
          "isOnline": true,
          "isFavorite": false,
        },
      ];

      for (var u in mockUsers) {
        final doc = await usersCollection.doc(u["uid"] as String).get();
        if (!doc.exists) {
          await usersCollection.doc(u["uid"] as String).set(u);
          debugPrint("🌱 Seeded user: ${u['name']}");

          List ids = [currentUid, u["uid"]];
          ids.sort();
          String chatId = ids.join("_");
          final messagesCollection = FirebaseFirestore.instance
              .collection("Chats")
              .doc(chatId)
              .collection(chatId);

          final msgsSnapshot = await messagesCollection.limit(1).get();
          if (msgsSnapshot.docs.isEmpty) {
            String initialMsg = "";
            int offsetDays = 0;
            if (u["name"] == "Sara") {
              initialMsg = "Le brief créatif est prêt pour le Projet Lisbonne ! 📅";
              offsetDays = 0;
            } else if (u["name"] == "Lucas") {
              initialMsg = "Le livrable est prêt pour review 🎁";
              offsetDays = 1;
            } else if (u["name"] == "Mehdi") {
              initialMsg = "OK je check demain matin";
              offsetDays = 2;
            } else if (u["name"] == "Maman") {
              initialMsg = "N'oublie pas d'appeler ce week-end.";
              offsetDays = 6;
            } else {
              initialMsg = "Salut ! On se capte plus tard.";
              offsetDays = 4;
            }

            await messagesCollection.add({
              "senderUid": u["uid"],
              "receiverUid": currentUid,
              "message": initialMsg,
              "chatId": chatId,
              "timestamp": Timestamp.fromDate(
                  DateTime.now().subtract(Duration(days: offsetDays))),
              "type": "text",
            });
          }
        }
      }

      final groupDoc =
          await groupsCollection.doc("projet_lisbonne_uid").get();
      if (!groupDoc.exists) {
        await groupsCollection.doc("projet_lisbonne_uid").set({
          "groupId": "projet_lisbonne_uid",
          "name": "Projet Lisbonne",
          "initials": "PL",
          "color": 0xFF5E35B1,
          "members": [currentUid, "sara_uid", "lucas_uid"],
          "lastMessage": "Sara: Brief envoyé",
          "lastMessageTime": Timestamp.now(),
          "unreadCount": 2,
          "isGroup": true,
        });
        debugPrint("🌱 Seeded group: Projet Lisbonne");
      }
    } catch (e) {
      debugPrint("❌ Error seeding mock users/groups: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Non connecté")));
    }

    final String userEmail = currentUser!.email ?? "koffi@echo.work";
    final String userInitials =
        userEmail.isNotEmpty ? userEmail[0].toUpperCase() : "K";
    final String displayName = userEmail.split('@')[0];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateGroupDialog(),
          );
        },
        backgroundColor: const Color(0xFFE50914),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFE50914),
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName.toUpperCase() == "DEMO"
                            ? "Koffi Doe"
                            : displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.fiber_manual_record,
                              color: Colors.green, size: 10),
                          SizedBox(width: 4),
                          Text(
                            "En ligne",
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildHeaderButton(Icons.search, () {}),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      _buildHeaderButton(Icons.notifications_none, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotificationsPage()),
                        );
                      }),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          height: 8,
                          width: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE50914),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- CHAMP DE RECHERCHE ---
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: const Color(0xFF1E1E1E), width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Rechercher une discussion...",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim().toLowerCase();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- FILTRES CATÉGORIES ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryFilter("Tous"),
                    const SizedBox(width: 8),
                    _buildCategoryFilter("Non lus"),
                    const SizedBox(width: 8),
                    _buildCategoryFilter("Groupes"),
                    const SizedBox(width: 8),
                    _buildCategoryFilter("Favoris"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- CONTACTS EN LIGNE (HORIZONTAL) ---
              const Text(
                "EN LIGNE",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 86,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();

                    final users = snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["isOnline"] == true &&
                          data["uid"] != currentUser!.uid;
                    }).toList();

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: users.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: Column(
                              children: [
                                Container(
                                  height: 52,
                                  width: 52,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.grey[800]!,
                                        style: BorderStyle.solid,
                                        width: 1.5),
                                  ),
                                  child: const Icon(Icons.add,
                                      color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                const Text("Vous",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          );
                        }

                        final data =
                            users[index - 1].data() as Map<String, dynamic>;
                        final String name = data["name"] ??
                            (data["email"]?.split('@')[0] ?? "");
                        final String initials = data["initials"] ?? "U";
                        final Color color =
                            Color((data["color"] as int?) ?? 0xFFE50914);

                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Discussions(
                                    email: name,
                                    uid: data["uid"] ?? "",
                                    initials: initials,
                                    avatarColor: color,
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: color,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  name,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // --- TOUS LES CONTACTS ---
              const Text(
                "TOUS LES CONTACTS",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .snapshots(),
                  builder: (context, usersSnapshot) {
                    if (!usersSnapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFFE50914)));
                    }

                    final allUsers = usersSnapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data["uid"] == currentUser!.uid) return false;
                      if (_searchQuery.isNotEmpty) {
                        final name = data["name"] ??
                            (data["email"]?.split('@')[0] ?? "");
                        final email = data["email"] ?? "";
                        if (!name.toLowerCase().contains(_searchQuery) &&
                            !email.toLowerCase().contains(_searchQuery)) {
                          return false;
                        }
                      }
                      return true;
                    }).toList();

                    if (allUsers.isEmpty) {
                      return const Center(
                        child: Text(
                          "Aucun contact disponible",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: allUsers.length,
                      itemBuilder: (context, index) {
                        final data =
                            allUsers[index].data() as Map<String, dynamic>;
                        final String name = data["name"] ??
                            (data["email"]?.split('@')[0] ?? "Utilisateur");
                        final String initials = data["initials"] ?? "U";
                        final String uid = data["uid"] ?? "";
                        final Color color =
                            Color((data["color"] as int?) ?? 0xFFE50914);
                        final bool isOnline = data["isOnline"] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: color,
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                if (isOnline)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.black, width: 1.5),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                            subtitle: Text(
                              isOnline ? "En ligne" : "Hors ligne",
                              style: TextStyle(
                                  color: isOnline
                                      ? Colors.green
                                      : Colors.grey[600],
                                  fontSize: 12),
                            ),
                            trailing: Icon(
                              Icons.chat_bubble_outline,
                              color: const Color(0xFFE50914),
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Discussions(
                                    email: name,
                                    uid: uid,
                                    initials: initials,
                                    avatarColor: color,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E0E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCategoryFilter(String categoryName) {
    bool isActive = _selectedCategory == categoryName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = categoryName;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFE50914)
              : const Color(0xFF0E0E0E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive
                  ? const Color(0xFFE50914)
                  : const Color(0xFF1E1E1E),
              width: 1),
        ),
        child: Text(
          categoryName,
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class ChatItemWidget extends StatelessWidget {
  final String currentUid;
  final String partnerUid;
  final String partnerName;
  final String partnerInitials;
  final Color avatarColor;
  final bool isFavorite;
  final bool isOnline;
  final int mockUnread;
  final Function() onTap;

  const ChatItemWidget({
    super.key,
    required this.currentUid,
    required this.partnerUid,
    required this.partnerName,
    required this.partnerInitials,
    required this.avatarColor,
    required this.onTap,
    this.isFavorite = false,
    this.isOnline = false,
    this.mockUnread = 0,
  });

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return "";
    try {
      final date = timestamp.toDate();
      final now = DateTime.now();
      final diff = now.difference(date).inDays;
      if (diff == 0) {
        return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      } else if (diff == 1) {
        return "Hier";
      } else if (diff < 7) {
        const jours = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
        return jours[date.weekday - 1];
      } else {
        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}";
      }
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    List ids = [currentUid, partnerUid];
    ids.sort();
    String chatId = ids.join("_");

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Chats")
          .doc(chatId)
          .collection(chatId)
          .orderBy("timestamp", descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        String lastMsg = "Commencer la discussion sécurisée";
        String timeStr = "";

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;
          lastMsg = doc["message"] ?? "";
          final type = doc["type"] ?? "text";
          if (type == "image") {
            lastMsg = "📷 Photo";
          } else if (type == "file") {
            lastMsg = "📄 Fichier: ${doc['fileName'] ?? ''}";
          }
          timeStr = _formatTimestamp(doc["timestamp"] as Timestamp?);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: avatarColor,
                  child: Text(
                    partnerInitials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            title: Text(
              partnerName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                lastMsg,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  timeStr,
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (mockUnread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE50914),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$mockUnread",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else if (isFavorite)
                  const Icon(Icons.star,
                      color: Color(0xFFE50914), size: 16)
                else
                  const SizedBox(height: 18),
              ],
            ),
            onTap: onTap,
          ),
        );
      },
    );
  }
}