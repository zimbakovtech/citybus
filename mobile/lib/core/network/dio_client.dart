import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../errors/failures.dart';

/// Single Dio instance for the whole app: base URL from --dart-define,
/// sane timeouts, and an interceptor that maps transport errors to [Failure]s.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '${Env.apiBaseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
  dio.interceptors.add(_FailureInterceptor());
  return dio;
});

class _FailureInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = switch (err.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout => const NetworkFailure(),
      DioExceptionType.badResponse when err.response?.statusCode == 404 =>
        NotFoundFailure(_detail(err) ?? 'Not found'),
      _ => ServerFailure(_detail(err) ?? 'Unexpected server error'),
    };
    handler.reject(err.copyWith(error: failure));
  }

  String? _detail(DioException err) {
    final data = err.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    return null;
  }
}

/// Unwraps the [Failure] placed on a [DioException] by the interceptor.
Failure asFailure(Object error) {
  if (error is DioException && error.error is Failure) {
    return error.error! as Failure;
  }
  if (error is Failure) return error;
  return ServerFailure(error.toString());
}
