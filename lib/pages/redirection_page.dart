import 'package:echo_work/pages/login_pages.dart';
import 'package:echo_work/pages/shell_page.dart';
import 'package:echo_work/services/firebase_auth/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => _RedirectionPageState();
}

class _RedirectionPageState extends State<RedirectionPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen();
        } else if (snapshot.hasData) {
          return const ShellPage();
        } else {
          return const LoginPages();
        }
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo rouge arrondi (Squircle)
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE50914),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            const SizedBox(height: 30),
            // Nom de l'application
            const Text(
              "ECHO WORK",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            // Tagline élégante
            const Text(
              "CONNECT  ·  WORK  ·  FLOW",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 40),
            // Barre de progression horizontale rouge
            SizedBox(
              width: 120,
              height: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: const LinearProgressIndicator(
                  backgroundColor: Color(0xFF1E1E1E),
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE50914)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

