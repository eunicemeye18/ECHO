import 'package:clone_whatsapp_base_code/pages/discussions.dart';
import 'package:clone_whatsapp_base_code/services/firebase_auth/auth.dart';
import 'package:clone_whatsapp_base_code/widgets/contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = Auth().currentUser;

  //   final kColorScheme = ColorScheme.fromSeed(
  //   brightness: Brightness.light,

  //   seedColor: const Color(0xFFE50914), // rouge Netflix

  //   primary: const Color(0xFFE50914),

  //   secondary: const Color(0xFFB81D24),

  //   surface: Colors.white,

  //   background: const Color(0xFFF5F5F5),
  // );

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        leading: Text("ECHO"),
        actions: [
          IconButton(
            onPressed: () {
              Auth().logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("uid", isNotEqualTo: currentUser.currentUser!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Text("Aucun utilisateur");
          }
          List<dynamic> users = [];
          snapshot.data!.docs.forEach((_element) {
            users.add(_element);
          });

          return ListView.builder(
            shrinkWrap: true,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userMail = user["email"];
              final userUid = user["uid"];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Discussions(email: userMail,uid: userUid,)),
                  );
                },
                child: Contact(userMail: userMail, userUid: userUid),
              );
            },
          );
        },
      ),
    );
  }
}
