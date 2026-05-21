import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/pages/rappel_detail_page.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RappelsPage extends StatefulWidget {
  const RappelsPage({super.key});

  @override
  State<RappelsPage> createState() => _RappelsPageState();
}

class _RappelsPageState extends State<RappelsPage> {
  String _selectedTab = "Tout"; // "Tout" | "Promesses" | "Rendez-vous" | "Idées"
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _seedDefaultRappelsIfNeeded();
  }

  Future<void> _seedDefaultRappelsIfNeeded() async {
    try {
      final currentUid = Auth().currentUser?.uid;
      if (currentUid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection("Rappels")
          .where("auteur", isEqualTo: currentUid)
          .get();

      if (snapshot.docs.isEmpty) {
        final mockRappels = [
          {
            "message": "Rendez-vous avec Lucas",
            "auteur": currentUid,
            "chatId": "lucas_uid_$currentUid",
            "mot_cle": "Rendez-vous",
            "timestamp": Timestamp.fromDate(DateTime.now().add(const Duration(days: 1))),
            "statut": "actif",
            "type": "rendez-vous",
            "location": "Café de la gare",
            "whenText": "Demain à 18h00",
            "dateDetail": "Vendredi 24 Mai à 18h00",
            "partnerName": "Lucas",
            "partnerUid": "lucas_uid",
            "sourceText": "Discussion du 18 Mai",
          },
          {
            "message": "Anniversaire de Sara",
            "auteur": currentUid,
            "chatId": "sara_uid_$currentUid",
            "mot_cle": "Anniversaire",
            "timestamp": Timestamp.now(),
            "statut": "actif",
            "type": "rendez-vous",
            "location": "N/A",
            "whenText": "Aujourd'hui",
            "dateDetail": "Jeudi 23 Mai à 09h00",
            "partnerName": "Sara",
            "partnerUid": "sara_uid",
            "sourceText": "Alerte Calendrier",
          },
          {
            "message": "Voyage Lisbonne",
            "auteur": currentUid,
            "chatId": "projet_lisbonne_uid",
            "mot_cle": "Voyage",
            "timestamp": Timestamp.fromDate(DateTime.now().add(const Duration(days: 12))),
            "statut": "actif",
            "type": "rendez-vous",
            "location": "Aéroport Lisbonne",
            "whenText": "12 juin",
            "dateDetail": "Mercredi 12 Juin à 14h00",
            "partnerName": "Sara",
            "partnerUid": "sara_uid",
            "sourceText": "Discussion Lisbonne",
          },
          {
            "message": "Envoyer le document à Lucas",
            "auteur": currentUid,
            "chatId": "lucas_uid_$currentUid",
            "mot_cle": "Document",
            "timestamp": Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5))),
            "statut": "actif",
            "type": "promesse",
            "location": "N/A",
            "whenText": "Mentionné il y a 5 jours",
            "dateDetail": "Mentionné il y a 5 jours",
            "partnerName": "Lucas",
            "partnerUid": "lucas_uid",
            "sourceText": "Discussion du 18 Mai",
          }
        ];

        final batch = FirebaseFirestore.instance.batch();
        for (var r in mockRappels) {
          final docRef = FirebaseFirestore.instance.collection("Rappels").doc();
          batch.set(docRef, r);
        }
        await batch.commit();
        print("🌱 Mock Rappels seeded in Firestore !");
      }
    } catch (e) {
      print("Error seeding mock rappels: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = Auth().currentUser?.uid;
    if (currentUid == null) return const Scaffold(body: Center(child: Text("Non connecté")));

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TITLE ---
              const Text(
                "Mémoire",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 16),

              // --- SEARCH BAR ---
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E0E0E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: "Rechercher dans votre mémoire",
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
              const SizedBox(height: 20),

              // --- FILTER TABS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabButton("Tout"),
                    const SizedBox(width: 8),
                    _buildTabButton("Promesses"),
                    const SizedBox(width: 8),
                    _buildTabButton("Rendez-vous"),
                    const SizedBox(width: 8),
                    _buildTabButton("Idées"),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- DYNAMIC CONTENT LIST ---
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("Rappels")
                      .where("auteur", isEqualTo: currentUid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Erreur: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                    }

                    final allRappels = snapshot.data?.docs ?? [];
                    
                    // Filter by search query & tab
                    final filteredRappels = allRappels.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final message = (data["message"] as String? ?? "").toLowerCase();
                      final type = data["type"] as String? ?? "promesse";
                      
                      // Text Search check
                      if (_searchQuery.isNotEmpty && !message.contains(_searchQuery)) {
                        return false;
                      }

                      // Tab check
                      if (_selectedTab == "Promesses" && type != "promesse") return false;
                      if (_selectedTab == "Rendez-vous" && type != "rendez-vous") return false;
                      if (_selectedTab == "Idées" && type != "idee") return false;

                      return true;
                    }).toList();

                    // Split into upcoming and promises
                    final upcoming = filteredRappels.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["type"] == "rendez-vous" && data["statut"] == "actif";
                    }).toList();

                    final promises = filteredRappels.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data["type"] == "promesse";
                    }).toList();

                    return ListView(
                      children: [
                        // --- SECTION: À VENIR ---
                        if (_selectedTab == "Tout" || _selectedTab == "Rendez-vous") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "À venir",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              if (upcoming.length > 3)
                                const Text("Voir tout", style: TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (upcoming.isEmpty)
                            const Text("Aucun rendez-vous à venir", style: TextStyle(color: Colors.grey, fontSize: 13))
                          else
                            ...upcoming.map((doc) => _buildUpcomingItem(context, doc)),
                          const SizedBox(height: 32),
                        ],

                        // --- SECTION: PROMESSES ---
                        if (_selectedTab == "Tout" || _selectedTab == "Promesses") ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Promesses",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const Text("Voir tout", style: TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (promises.isEmpty)
                            const Text("Aucune promesse enregistrée", style: TextStyle(color: Colors.grey, fontSize: 13))
                          else
                            ...promises.map((doc) => _buildPromiseItem(context, doc)),
                        ],
                      ],
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

  Widget _buildTabButton(String tabName) {
    bool isActive = _selectedTab == tabName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = tabName;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE50914) : const Color(0xFF0E0E0E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? const Color(0xFFE50914) : const Color(0xFF1E1E1E), width: 1),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String message = data["message"] ?? "";
    final String whenText = data["whenText"] ?? "";
    final String dateDetail = data["dateDetail"] ?? "";
    final String location = data["location"] ?? "";
    final String partnerName = data["partnerName"] ?? "";
    final String partnerUid = data["partnerUid"] ?? "";
    final String sourceText = data["sourceText"] ?? "";

    Color badgeColor = const Color(0xFFE50914);
    String badgeText = whenText;

    if (whenText.toLowerCase().contains("demain")) {
      badgeColor = const Color(0xFF1E1E1E);
    } else if (whenText.toLowerCase().contains("aujourd'hui")) {
      badgeColor = const Color(0x33E50914);
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
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0x1AE50914),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.calendar_today, color: Color(0xFFE50914), size: 18),
        ),
        title: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            dateDetail,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: badgeColor,
            borderRadius: BorderRadius.circular(8),
            border: badgeColor == const Color(0xFF1E1E1E) ? Border.all(color: const Color(0xFF2E2E2E)) : null,
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              color: badgeColor == const Color(0xFF1E1E1E) ? Colors.red : Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RappelDetailPage(
                title: message,
                whenText: whenText,
                dateDetail: dateDetail,
                location: location,
                partnerName: partnerName,
                partnerUid: partnerUid,
                sourceText: sourceText,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromiseItem(BuildContext context, DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final String message = data["message"] ?? "";
    final String whenText = data["whenText"] ?? "";
    final String status = data["statut"] ?? "actif";
    final bool isChecked = status == "fait";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
      ),
      child: CheckboxListTile(
        value: isChecked,
        activeColor: const Color(0xFFE50914),
        checkColor: Colors.white,
        title: Text(
          message,
          style: TextStyle(
            color: isChecked ? Colors.grey : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            decoration: isChecked ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          whenText,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        onChanged: (bool? value) {
          doc.reference.update({"statut": value == true ? "fait" : "actif"});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(value == true ? "Félicitations, promesse tenue !" : "Promesse réactivée !"),
              backgroundColor: const Color(0xFF1E1E1E),
            ),
          );
        },
        controlAffinity: ListTileControlAffinity.trailing,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
