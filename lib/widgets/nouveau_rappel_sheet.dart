import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NouveauRappelSheet extends StatefulWidget {
  const NouveauRappelSheet({
    super.key,
    required this.messageText,
    required this.partnerName,
    required this.partnerUid,
  });

  final String messageText;
  final String partnerName;
  final String partnerUid;

  @override
  State<NouveauRappelSheet> createState() => _NouveauRappelSheetState();
}

class _NouveauRappelSheetState extends State<NouveauRappelSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E), width: 1.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Close header line
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          
          // Glowing AI Sparkle Icon
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914).withOpacity(0.1),
              border: Border.all(color: const Color(0xFFE50914).withOpacity(0.3), width: 1),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFE50914),
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          const Text(
            "Nouvelle promesse détectée ✨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            "ECHO a détecté ceci dans votre conversation avec ${widget.partnerName}.",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Quote Card showing the detected promise text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
            ),
            child: Text(
              "\"${widget.messageText}\"",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Question
          const Text(
            "Veux-tu le sauvegarder dans ta mémoire ?",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveRappel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text(
                      "Sauvegarder",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // Later Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Color(0xFF2E2E2E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Plus tard",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          Text(
            "Vous gardez toujours le contrôle.",
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _saveRappel() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUid = Auth().currentUser!.uid;
      final bool isAppointment = widget.messageText.toLowerCase().contains("rendez-vous") ||
                                 widget.messageText.toLowerCase().contains("réunion") ||
                                 widget.messageText.toLowerCase().contains("voir");

      await FirebaseFirestore.instance.collection("Rappels").add({
        "message": widget.messageText,
        "auteur": currentUid,
        "chatId": "${widget.partnerUid}_$currentUid",
        "mot_cle": isAppointment ? "Rendez-vous" : "Engagement",
        "timestamp": Timestamp.now(),
        "statut": "actif",
        "type": isAppointment ? "rendez-vous" : "promesse",
        "location": isAppointment ? "Café de la gare" : "N/A",
        "whenText": "Créé via IA",
        "dateDetail": "Créé à partir de la discussion",
        "partnerName": widget.partnerName,
        "partnerUid": widget.partnerUid,
        "sourceText": "Discussion du ${DateFormat('dd MMM', 'fr_FR').format(DateTime.now())}",
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Promesse enregistrée dans votre Mémoire !"),
              ],
            ),
            backgroundColor: Color(0xFF1E1E1E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: const Color(0xFFE50914)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
