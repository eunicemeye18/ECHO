import 'package:dio/dio.dart';

class ApiConfig {
  static String testBaseUrl = "https://api.dev.com/api/v1/";
  static String prodBaseUrl = "https://api.com/api/v1/";

  static Dio api() {
    final options = BaseOptions(
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      baseUrl: testBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status! < 600; // on accepte tout, on gère ensuite
      },
    );

    final dio = Dio(options);

    

    return dio;
  }
}