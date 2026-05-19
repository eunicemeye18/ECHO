import 'package:clone_whatsapp_base_code/constants/api_config.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    return {};
  }
}
