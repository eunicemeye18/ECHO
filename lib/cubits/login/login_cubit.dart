import 'package:echo_work/cubits/login/login_state.dart';
import 'package:echo_work/repositories/api_repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository authRepository;

  LoginCubit({required this.authRepository}) : super(LoginState.initial());

  Future<Map<String, dynamic>> login(String email, String password) async {
    return {};
  }
}
