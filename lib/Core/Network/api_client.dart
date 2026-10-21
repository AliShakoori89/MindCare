import 'package:dio/dio.dart';

typedef AccessTokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient._();

  static const String baseUrl = 'http://10.170.2.20:3000/api/';

  static Dio createDio({AccessTokenProvider? accessTokenProvider}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (accessTokenProvider != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final token = await accessTokenProvider();

              if (token != null && token.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              handler.next(options);
            } catch (error, stackTrace) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: error,
                  stackTrace: stackTrace,
                  type: DioExceptionType.unknown,
                ),
              );
            }
          },
        ),
      );
    }

    return dio;
  }
}
