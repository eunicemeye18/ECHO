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
    this.motCle,
    this.typeRappel,
    this.whenText,
  });

  /// Texte extrait / reformulé par l'IA
  final String messageText;
  final String partnerName;
  final String partnerUid;

  /// Données enrichies par l'IA
  final String? motCle;
  final String? typeRappel; // "promesse" | "rendez-vous"
  final String? whenText;

  @override
  State<NouveauRappelSheet> createState() => _NouveauRappelSheetState();
}

class _NouveauRappelSheetState extends State<NouveauRappelSheet> {
  bool _isLoading = false;

  bool get _isRendezVous => widget.typeRappel == "rendez-vous";

  String get _badgeLabel => _isRendezVous ? "Rendez-vous" : "Promesse";

  Color get _badgeColor =>
      _isRendezVous ? const Color(0xFF5E35B1) : const Color(0xFFE50914);

  IconData get _badgeIcon =>
      _isRendezVous ? Icons.calendar_today : Icons.handshake_outlined;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0E0E0E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0xFF1E1E1E), width: 1.5)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Barre de fermeture ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
              // Badge type (Promesse / Rendez-vous)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _badgeColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_badgeIcon, color: _badgeColor, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      _badgeLabel,
                      style: TextStyle(
                        color: _badgeColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Icône IA ───────────────────────────────────────────────────
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914).withValues(alpha: 0.1),
              border: Border.all(
                color: const Color(0xFFE50914).withValues(alpha: 0.3),
                width: 1,
              ),
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

          // ── Titre ──────────────────────────────────────────────────────
          Text(
            _isRendezVous ? "Rendez-vous détecté ✨" : "Promesse détectée ✨",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // ── Sous-titre ─────────────────────────────────────────────────
          Text(
            "ECHO a détecté ceci dans votre conversation avec ${widget.partnerName}.",
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // ── Citation du message extrait ────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E2E2E), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '"${widget.messageText}"',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
                // Afficher le mot-clé et la date si disponibles
                if (widget.motCle != null || widget.whenText != null) ...[
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFF2E2E2E), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (widget.motCle != null) ...[
                        _buildChip(
                          Icons.label_outline,
                          widget.motCle!,
                          Colors.grey,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.whenText != null)
                        _buildChip(
                          Icons.schedule,
                          widget.whenText!,
                          const Color(0xFFE50914),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Question ───────────────────────────────────────────────────
          const Text(
            "Veux-tu le sauvegarder dans ta mémoire ?",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // ── Bouton Sauvegarder ─────────────────────────────────────────
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
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Sauvegarder dans ma Mémoire",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Bouton Plus tard ───────────────────────────────────────────
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
                "Ignorer",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            "Vous gardez toujours le contrôle.",
            style: TextStyle(color: Colors.grey[600], fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Future<void> _saveRappel() async {
    setState(() => _isLoading = true);

    try {
      final currentUid = Auth().currentUser!.uid;
      final bool isRendezVous = widget.typeRappel == "rendez-vous";
      final String dateStr = DateFormat(
        'dd MMM',
        'fr_FR',
      ).format(DateTime.now());

      await FirebaseFirestore.instance.collection("Rappels").add({
        "message": widget.messageText,
        "auteur": currentUid,
        "chatId": "${widget.partnerUid}_$currentUid",
        "mot_cle":
            widget.motCle ?? (isRendezVous ? "Rendez-vous" : "Engagement"),
        "timestamp": Timestamp.now(),
        "statut": "actif",
        "type": isRendezVous ? "rendez-vous" : "promesse",
        "location": "N/A",
        "whenText": widget.whenText ?? "Détecté par l'IA",
        "dateDetail": widget.whenText ?? "Créé à partir de la discussion",
        "partnerName": widget.partnerName,
        "partnerUid": widget.partnerUid,
        "sourceText": "Discussion du $dateStr",
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 10),
                Text(
                  isRendezVous
                      ? "Rendez-vous enregistré dans votre Mémoire !"
                      : "Promesse enregistrée dans votre Mémoire !",
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E1E1E),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: const Color(0xFFE50914),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
