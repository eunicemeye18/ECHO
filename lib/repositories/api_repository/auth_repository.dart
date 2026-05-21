import 'package:echo_work/services/firebase_auth/auth.dart';

class AuthRepository {

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await Auth.login(email, password);
  }

}
