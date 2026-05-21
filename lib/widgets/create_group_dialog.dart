import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:flutter/material.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _nameController = TextEditingController();
  final List<String> _selectedUserIds = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = Auth().currentUser;
    if (currentUser == null) return const SizedBox();

    return Dialog(
      backgroundColor: const Color(0xFF0E0E0E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF1E1E1E), width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: MediaQuery.of(context).size.width * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.group_add, color: Color(0xFFE50914), size: 24),
                SizedBox(width: 10),
                Text(
                  "Créer un groupe",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Group Name Input
            const Text(
              "NOM DU GROUPE",
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ex: Projet Lisbonne",
                hintStyle: TextStyle(color: Colors.grey[700]),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2E2E2E)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFE50914)),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Select Members
            const Text(
              "SELECTIONNER LES MEMBRES",
              style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("users")
                    .where("uid", isNotEqualTo: currentUser.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)));
                  }
                  final users = snapshot.data?.docs ?? [];
                  if (users.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text("Aucun autre membre disponible", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data() as Map<String, dynamic>;
                      final uid = userData["uid"] ?? "";
                      final name = userData["name"] ?? (userData["email"]?.split('@')[0] ?? "");
                      final isSelected = _selectedUserIds.contains(uid);

                      return CheckboxListTile(
                        value: isSelected,
                        activeColor: const Color(0xFFE50914),
                        checkColor: Colors.white,
                        title: Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedUserIds.add(uid);
                            } else {
                              _selectedUserIds.remove(uid);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE50914),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Créer", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Le nom du groupe est requis"), backgroundColor: Color(0xFFE50914)),
      );
      return;
    }
    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un membre"), backgroundColor: Color(0xFFE50914)),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Auth().currentUser!;
      final groupId = FirebaseFirestore.instance.collection("groups").doc().id;
      final members = [currentUser.uid, ..._selectedUserIds];

      await FirebaseFirestore.instance.collection("groups").doc(groupId).set({
        "groupId": groupId,
        "name": name,
        "initials": name.substring(0, name.length > 1 ? 2 : 1).toUpperCase(),
        "color": 0xFF5E35B1,
        "members": members,
        "lastMessage": "${currentUser.email!.split('@')[0]} a créé le groupe.",
        "lastMessageTime": Timestamp.now(),
        "unreadCount": 0,
        "isGroup": true,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Groupe '$name' créé avec succès !"), backgroundColor: Colors.green),
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
