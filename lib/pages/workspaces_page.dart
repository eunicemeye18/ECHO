import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkspacesPage extends StatefulWidget {
  const WorkspacesPage({super.key});

  @override
  State<WorkspacesPage> createState() => _WorkspacesPageState();
}

class _WorkspacesPageState extends State<WorkspacesPage> {
  String _selectedTab = "Salons"; // "Salons" | "Tâches" | "Fichiers"
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _initializeDefaultWorkspacesIfNeeded();
  }

  // Initialise automatiquement des salons par défaut si la collection est vide
  Future<void> _initializeDefaultWorkspacesIfNeeded() async {
    try {
      final snapshot = await _db.collection("workspaces").get();
      if (snapshot.docs.isEmpty) {
        final batch = _db.batch();
        
        final defaultSalons = [
          {"name": "général", "members": 12, "unread": 5, "type": "text", "isReadOnly": false, "order": 1},
          {"name": "design-ui", "members": 4, "unread": 2, "type": "text", "isReadOnly": false, "order": 2},
          {"name": "dev-frontend", "members": 6, "unread": 0, "type": "text", "isReadOnly": false, "order": 3},
          {"name": "Annonces", "members": 12, "unread": 0, "type": "announcement", "isReadOnly": true, "order": 4},
        ];

        for (var salon in defaultSalons) {
          final docRef = _db.collection("workspaces").doc();
          batch.set(docRef, salon);
        }

        await batch.commit();
        print("🌱 Salons par défaut initialisés dans Firestore !");
      }
    } catch (e) {
      print("❌ Erreur lors de l'initialisation des salons: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            const Row(
              children: [
                Text(
                  "💬 Projet ECHO",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'serif',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "12 membres · Sprint #4 actif",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),

            // --- TAB SELECTOR (PILLS) ---
            Row(
              children: [
                _buildTabButton("Salons"),
                const SizedBox(width: 10),
                _buildTabButton("Tâches"),
                const SizedBox(width: 10),
                _buildTabButton("Fichiers"),
              ],
            ),
            const SizedBox(height: 20),

            // --- TAB CONTENT ---
            Expanded(
              child: _buildTabContent(),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE50914) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          tabName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    if (_selectedTab == "Salons") {
      return _buildSalonsList();
    } else if (_selectedTab == "Tâches") {
      return _buildTasksList();
    } else {
      return _buildFilesList();
    }
  }

  // --- 1. LISTE DES SALONS (DYNAMIQUE FIRESTORE) ---
  Widget _buildSalonsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection("workspaces").orderBy("order").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erreur: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Aucun salon disponible",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final String name = data["name"] ?? "";
            final int members = data["members"] ?? 0;
            final int unread = data["unread"] ?? 0;
            final String type = data["type"] ?? "text";
            final bool isReadOnly = data["isReadOnly"] ?? false;

            bool isAnnouncement = type == "announcement";

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E0E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isAnnouncement ? const Color(0xFFE50914) : const Color(0xFF1E1E1E),
                  width: isAnnouncement ? 1.5 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  isAnnouncement ? "📢 $name" : "# $name",
                  style: TextStyle(
                    color: isAnnouncement ? const Color(0xFFE50914) : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  isReadOnly ? "Lecture seule" : "$members membres",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                  ),
                ),
                trailing: unread > 0
                    ? Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE50914),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$unread",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
                onTap: () {
                  // Interaction : Ouvrir le salon ou marquer comme lu
                  if (unread > 0) {
                    docs[index].reference.update({"unread": 0});
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Ouverture du salon : $name"),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- 2. LISTE DES TÂCHES ---
  Widget _buildTasksList() {
    // Implémentation d'une liste de tâches dynamique locale/Firestore
    final tasks = [
      {"title": "Corriger l'inversion d'authentification", "status": true},
      {"title": "Sublimer le design de Discussions", "status": true},
      {"title": "Connecter l'onglet Workspaces à Firestore", "status": true},
      {"title": "Implémenter la connexion Google", "status": false},
      {"title": "Peaufiner les micro-animations", "status": false},
    ];

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        bool isDone = task["status"] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
          ),
          child: ListTile(
            leading: Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? const Color(0xFFE50914) : Colors.grey,
            ),
            title: Text(
              task["title"] as String,
              style: TextStyle(
                color: isDone ? Colors.grey : Colors.white,
                decoration: isDone ? TextDecoration.lineThrough : null,
                fontSize: 15,
              ),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Modification des tâches à venir !")),
              );
            },
          ),
        );
      },
    );
  }

  // --- 3. LISTE DES FICHIERS ---
  Widget _buildFilesList() {
    final files = [
      {"name": "Charte_Graphique_ECHO_WORK.pdf", "size": "4.2 MB", "type": "pdf"},
      {"name": "Wireframes_App_v2.fig", "size": "18.5 MB", "type": "figma"},
      {"name": "Brief_Client_Final.docx", "size": "1.1 MB", "type": "doc"},
    ];

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
          ),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file, color: Color(0xFFE50914)),
            title: Text(
              file["name"]!,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            subtitle: Text(
              file["size"]!,
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
            trailing: const Icon(Icons.download, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Téléchargement de ${file["name"]}")),
              );
            },
          ),
        );
      },
    );
  }
}
