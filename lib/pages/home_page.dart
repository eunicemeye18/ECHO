import 'package:clone_whatsapp_base_code/services/firebase_auth/auth.dart';
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
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            Text("ECHO", style: TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: () {
                Auth().logout();
              },
              child: Text("Se déconnecter", style: TextStyle(color: Color(0xFFE50914)),),
            ),
          ],
        ),
      ),
    );
  }
}
