import 'package:echo_work/pages/discussions.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "ECHO",
          style: TextStyle(
            color: Color(0xFFE50914),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- AUJOURD'HUI HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Aujourd'hui",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "3",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification 1: Anniversaire
            _buildNotificationCard(
              context,
              icon: Icons.cake,
              title: "Anniversaire",
              time: "09:00",
              message: "Sara a son anniversaire aujourd'hui.",
              actionLabel: "Envoyer un message",
              onTapAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Discussions(
                      email: "Sara",
                      uid: "sara_uid",
                      avatarColor: Color(0xFFE50914),
                      initials: "S",
                    ),
                  ),
                );
              },
            ),

            // Notification 2: Rendez-vous
            _buildNotificationCard(
              context,
              icon: Icons.calendar_today,
              title: "Rendez-vous",
              time: "08:30",
              message: "Tu as un rendez-vous avec Lucas demain à 18h00.",
              actionLabel: "Voir les détails",
              onTapAction: () {
                // Navigate to memory page or show detail dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ouverture des détails du rappel...")),
                );
              },
            ),

            // Notification 3: Réponse en attente
            _buildNotificationCard(
              context,
              icon: Icons.reply,
              title: "Réponse en attente",
              time: "Hier",
              message: "Lucas t'a envoyé un message important il y a 2 jours.",
              actionLabel: "Voir le message",
              onTapAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Discussions(
                      email: "Lucas",
                      uid: "lucas_uid",
                      avatarColor: Color(0xFF2E7D32),
                      initials: "L",
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),

            // --- CETTE SEMAINE HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Cette semaine",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE50914),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "2",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notification 4: Projet Lisbonne
            _buildNotificationCard(
              context,
              icon: Icons.chat_bubble,
              title: "Projet Lisbonne",
              time: "dim.",
              message: "2 éléments en attente dans votre conversation.",
              actionLabel: "Ouvrir le chat",
              onTapAction: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Ouverture du groupe Projet Lisbonne...")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String time,
    required String message,
    required String actionLabel,
    required VoidCallback onTapAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E1E), width: 1.2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0x1AE50914),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFE50914),
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1E1E1E), height: 1),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTapAction,
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: Color(0xFFE50914),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
