import 'package:clone_whatsapp_base_code/services/firebase_auth/auth.dart';

class AuthRepository {

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await Auth.login(email, password);
  }

}
