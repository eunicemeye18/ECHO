import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/pages/calling_page.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _seedMockCallsIfNeeded();
  }

  Future<void> _seedMockCallsIfNeeded() async {
    try {
      final currentUid = Auth().currentUser?.uid;
      if (currentUid == null) return;

      final snapshot = await _db.collection("calls").get();
      if (snapshot.docs.isEmpty) {
        final mockCalls = [
          {
            "callerUid": "lucas_uid",
            "callerName": "Lucas",
            "receiverUid": currentUid,
            "receiverName": "Moi",
            "timestamp": Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1, hours: 2))),
            "isVideo": false,
            "duration": "00:00",
            "status": "no_answer",
          },
          {
            "callerUid": currentUid,
            "callerName": "Moi",
            "receiverUid": "sara_uid",
            "receiverName": "Sara",
            "timestamp": Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 4))),
            "isVideo": true,
            "duration": "12:45",
            "status": "completed",
          },
          {
            "callerUid": "mehdi_uid",
            "callerName": "Mehdi",
            "receiverUid": currentUid,
            "receiverName": "Moi",
            "timestamp": Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 3, hours: 1))),
            "isVideo": false,
            "duration": "04:15",
            "status": "completed",
          },
          {
            "callerUid": "maman_uid",
            "callerName": "Maman",
            "receiverUid": currentUid,
            "receiverName": "Moi",
            "timestamp": Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 6, hours: 10))),
            "isVideo": false,
            "duration": "00:00",
            "status": "no_answer",
          },
        ];

        final batch = _db.batch();
        for (var call in mockCalls) {
          final docRef = _db.collection("calls").doc();
          batch.set(docRef, call);
        }
        await batch.commit();
        print("🌱 Mock calls seeded in Firestore !");
      }
    } catch (e) {
      print("Error seeding mock calls: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Auth().currentUser;
    if (currentUser == null) return const Scaffold(body: Center(child: Text("Non connecté")));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Appels récents",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'serif',
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_call, color: Color(0xFFE50914)),
            onPressed: () => _showStartCallDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db.collection("calls").orderBy("timestamp", descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }

          final calls = snapshot.data?.docs ?? [];
          if (calls.isEmpty) {
            return const Center(
              child: Text("Aucun appel récent", style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final data = calls[index].data() as Map<String, dynamic>;
              final String callerUid = data["callerUid"] ?? "";
              final String callerName = data["callerName"] ?? "";
              final String receiverUid = data["receiverUid"] ?? "";
              final String receiverName = data["receiverName"] ?? "";
              final bool isVideo = data["isVideo"] ?? false;
              final String duration = data["duration"] ?? "00:00";
              final String status = data["status"] ?? "completed";
              
              final bool isOutgoing = callerUid == currentUser.uid;
              final String displayName = isOutgoing ? receiverName : callerName;
              final String displayUid = isOutgoing ? receiverUid : callerUid;
              
              String dateText = "";
              if (data["timestamp"] != null) {
                try {
                  final DateTime date = (data["timestamp"] as Timestamp).toDate();
                  dateText = DateFormat('dd MMM à HH:mm', 'fr_FR').format(date);
                } catch (_) {}
              }

              IconData callIcon;
              Color callIconColor;

              if (status == "no_answer") {
                callIcon = Icons.call_missed;
                callIconColor = const Color(0xFFE50914);
              } else {
                callIcon = isOutgoing ? Icons.call_made : Icons.call_received;
                callIconColor = Colors.green;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF1E1E1E),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    displayName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Icon(callIcon, color: callIconColor, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          "$dateText ${status == 'completed' ? '($duration)' : '(Manqué)'}",
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(isVideo ? Icons.videocam : Icons.phone, color: Colors.grey, size: 20),
                        onPressed: () => _initiateCall(context, displayName, displayUid, isVideo),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _initiateCall(BuildContext context, String name, String uid, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallingPage(
          name: name,
          uid: uid,
          isVideo: isVideo,
        ),
      ),
    );
  }

  void _showStartCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StreamBuilder<QuerySnapshot>(
        stream: _db.collection("users").where("uid", isNotEqualTo: Auth().currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          final users = snapshot.data!.docs;

          return Dialog(
            backgroundColor: const Color(0xFF0E0E0E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF1E1E1E)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Nouvel Appel",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final u = users[index].data() as Map<String, dynamic>;
                        final name = u["name"] ?? (u["email"]?.split('@')[0] ?? "");
                        final uid = u["uid"] ?? "";

                        return ListTile(
                          title: Text(name, style: const TextStyle(color: Colors.white)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.green),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _initiateCall(context, name, uid, false);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.videocam, color: Color(0xFFE50914)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _initiateCall(context, name, uid, true);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
