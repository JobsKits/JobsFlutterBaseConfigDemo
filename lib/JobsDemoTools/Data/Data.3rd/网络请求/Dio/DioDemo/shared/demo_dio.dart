import 'package:dio/dio.dart';

class DemoDio {
  DemoDio._();

  static final Dio instance = Dio(
    BaseOptions(
      baseUrl: 'http://127.0.0.1:18080',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      headers: const {
        'Content-Type': 'application/json',
      },
      validateStatus: (status) =>
          status != null && status >= 200 && status < 500,
    ),
  );
}
