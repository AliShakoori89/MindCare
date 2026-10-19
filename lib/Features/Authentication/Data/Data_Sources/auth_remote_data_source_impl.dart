
import 'package:dio/dio.dart';

import '../../Domain/Entities/auth_session.dart';
import 'auth_remote_data_source.dart';

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;

  const AuthApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<void> sendOtp({required String email}) async {
    try {
      final response = await dio.post(
        'auth/send-otp',
        data: {'email': email.trim().toLowerCase()},
      );

      final body = _asMap(response.data);

      if (body['success'] == false) {
        throw AuthApiException(
          _messageFrom(body) ?? 'ارسال کد تأیید ناموفق بود.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (error) {
      throw _toAuthException(error);
    }
  }

  @override
  Future<AuthSession> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await dio.post(
        'auth/verify-otp',
        data: {
          'email': email.trim().toLowerCase(),
          'code': code.trim(),
        },
      );

      final body = _asMap(response.data);

      if (body['success'] == false) {
        throw AuthApiException(
          _messageFrom(body) ?? 'تأیید کد ناموفق بود.',
          statusCode: response.statusCode,
        );
      }

      final data = _asMap(body['data']);
      final user = _asMap(data['user']);
      final token = data['token'] as String?;
      final userId = user['id'] as String?;
      final userEmail = user['email'] as String?;

      if (token == null ||
          token.isEmpty ||
          userId == null ||
          userEmail == null) {
        throw const AuthApiException(
          'پاسخ احراز هویت از سرور معتبر نیست.',
        );
      }

      return AuthSession(
        userId: userId,
        email: userEmail,
        accessToken: token,
      );
    } on DioException catch (error) {
      throw _toAuthException(error);
    }
  }

  @override
  Future<AuthSession> getCurrentSession({
    required String accessToken,
  }) async {
    try {
      final response = await dio.get(
        'auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final body = _asMap(response.data);

      if (body['success'] == false) {
        throw AuthApiException(
          _messageFrom(body) ?? 'نشست کاربر معتبر نیست.',
          statusCode: response.statusCode,
        );
      }

      final user = _asMap(body['data']);
      final userId = user['id'] as String?;
      final email = user['email'] as String?;

      if (userId == null || email == null) {
        throw const AuthApiException(
          'اطلاعات کاربر از سرور دریافت نشد.',
        );
      }

      return AuthSession(
        userId: userId,
        email: email,
        accessToken: accessToken,
      );
    } on DioException catch (error) {
      throw _toAuthException(error);
    }
  }

  @override
  Future<void> logout({required String accessToken}) async {
    try {
      await dio.post(
        'auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (error) {
      throw _toAuthException(error);
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map(
            (key, value) => MapEntry(key.toString(), value),
      );
    }

    return <String, dynamic>{};
  }

  String? _messageFrom(Map<String, dynamic> body) {
    final message = body['message'];

    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    if (message is List && message.isNotEmpty) {
      return message.join('\n');
    }

    return null;
  }

  AuthApiException _toAuthException(DioException error) {
    final responseBody = _asMap(error.response?.data);
    final message = _messageFrom(responseBody);

    if (message != null) {
      return AuthApiException(
        message,
        statusCode: error.response?.statusCode,
      );
    }

    if (error.response == null) {
      return const AuthApiException(
        'ارتباط با سرور برقرار نشد. اتصال شبکه را بررسی کنید.',
      );
    }

    return AuthApiException(
      'درخواست ناموفق بود. دوباره تلاش کنید.',
      statusCode: error.response?.statusCode,
    );
  }
}
