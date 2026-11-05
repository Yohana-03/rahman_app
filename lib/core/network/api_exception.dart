import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  factory ApiException.fromDio(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            return ApiException(value.first.toString(), statusCode: status);
          }
          if (value is String && value.isNotEmpty) {
            return ApiException(value, statusCode: status);
          }
        }
      }
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return ApiException(message, statusCode: status);
      }
    }

    if (status == 429) {
      return const ApiException(
        'Too many attempts. Wait a moment and try again.',
        statusCode: 429,
      );
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const ApiException(
          'Could not reach the school server. Check your connection.',
        );
      default:
        return ApiException(
          'Something went wrong. Please try again.',
          statusCode: status,
        );
    }
  }

  @override
  String toString() => message;
}
