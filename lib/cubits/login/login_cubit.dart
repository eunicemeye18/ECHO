import 'package:clone_whatsapp_base_code/cubits/login/login_state.dart';
import 'package:clone_whatsapp_base_code/repositories/api_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(LoginState.initial());

  Future<Map<String, dynamic>> login(String email, String password) async {
    return {};
  }
}
