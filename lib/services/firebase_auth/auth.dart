import 'package:echo_work/constants/api_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  static Dio api = ApiConfig.api();
  //LOGIN WITH EMAIL PASSWORD
  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  //CREATE USER WITH EMAIL-PASSWORD
  Future<void> createUserWithEmailAndPassword(
  String email,
  String password,
) async {
  try {
    print("🔵 1. Début création user...");
    
    UserCredential credential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    
    print("🟢 2. User Firebase Auth créé: ${credential.user?.uid}");

    String? uid = credential.user?.uid;
    
    if (uid == null) {
      print("🔴 3. UID est null !");
      return;
    }

    print("🔵 4. Tentative écriture Firestore...");
    
    await db.collection("users").doc(uid).set({
      "email": email,
      "uid": uid,
    });
    
    print("🟢 5. Firestore OK !");
    
  } catch (e, stackTrace) {
    print("🔴 ERREUR: $e");
    print("🔴 STACK: $stackTrace");
    rethrow;
  }
}

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return {};
  }
}
