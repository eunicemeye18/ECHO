import 'package:echo_work/pages/discussions.dart';
import 'package:flutter/material.dart';

class RappelDetailPage extends StatelessWidget {
  const RappelDetailPage({
    super.key,
    required this.title,
    required this.whenText,
    required this.dateDetail,
    required this.location,
    required this.partnerName,
    required this.partnerUid,
    required this.sourceText,
  });

  final String title;
  final String whenText;
  final String dateDetail;
  final String location;
  final String partnerName;
  final String partnerUid;
  final String sourceText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            
            // Icon Calendar Red Circle
            Container(
              height: 72,
              width: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE50914),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),

            // Title & Subtitle
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              whenText,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 40),

            // Detail fields card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0E0E0E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E1E1E), width: 1.2),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDetailRow("Quand ?", dateDetail),
                  const Divider(color: Color(0xFF1E1E1E), height: 24),
                  _buildDetailRow("Où ?", location),
                  const Divider(color: Color(0xFF1E1E1E), height: 24),
                  _buildDetailRowWithUser("Avec qui ?", partnerName),
                  const Divider(color: Color(0xFF1E1E1E), height: 24),
                  _buildDetailRow("Créé à partir de", sourceText),
                ],
              ),
            ),
            const Spacer(),

            // Actions Buttons
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Discussions(
                        email: partnerName,
                        uid: partnerUid,
                        initials: partnerName.isNotEmpty ? partnerName[0].toUpperCase() : "U",
                        avatarColor: const Color(0xFF2E7D32),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Voir la conversation",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Modification indisponible en mode démo")),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: Color(0xFF2E2E2E)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Modifier",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Rappel supprimé !")),
                );
                Navigator.pop(context);
              },
              child: const Text(
                "Supprimer",
                style: TextStyle(
                  color: Color(0xFFE50914),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRowWithUser(String label, String username) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: const Color(0xFF2E7D32),
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "U",
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              username,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
