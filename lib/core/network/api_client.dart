import 'package:dio/dio.dart';
import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/core/json_utils.dart';
import 'package:finalrahman/core/network/api_exception.dart';
import 'package:finalrahman/core/storage/token_store.dart';
import 'package:finalrahman/features/auth/auth_tokens.dart';
import 'package:finalrahman/features/auth/parent_profile.dart';
import 'package:finalrahman/features/portal/fee_statement.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/features/portal/student.dart';

class ApiClient {
  ApiClient({
    required this.tokenStore,
    required this.onSessionExpired,
    String baseUrl = ApiConfig.baseUrl,
    Dio? dio,
  }) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      headers: const {'Accept': 'application/json'},
      contentType: Headers.jsonContentType,
    );
    this.dio = dio ?? Dio(options);
    _refreshDio = Dio(options);
    this.dio.interceptors.add(_AuthInterceptor(this));
  }

  final TokenStore tokenStore;
  final void Function() onSessionExpired;
  late final Dio dio;
  late final Dio _refreshDio;
  Future<void>? _refreshing;

  Future<AuthTokens> login(String email, String password) {
    return _send(
      () => dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(extra: const {'noAuth': true}),
      ),
      AuthTokens.fromApiBody,
    );
  }

  Future<void> logout() async {
    try {
      await dio.post(
        '/auth/logout',
        options: Options(extra: const {'skipRefresh': true}),
      );
    } on DioException {
      // The device still signs out if the server cannot be reached.
    }
  }

  Future<ParentProfile> profile() {
    return _send(() => dio.get('/me'), ParentProfile.fromApiBody);
  }

  Future<List<Student>> students() async {
    final body = await _body(() => dio.get('/parent/students'));
    final data = body['data'];
    final list = data is List
        ? data
        : data is Map
        ? readList(data['data'])
        : const [];
    return [
      for (final item in list)
        if (item is Map) Student.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<ResultReport> results(int studentId) {
    return _send(
      () => dio.get('/parent/students/$studentId/results'),
      ResultReport.fromApiBody,
    );
  }

  Future<FeeStatement> fees(int studentId) {
    return _send(
      () => dio.get('/parent/students/$studentId/fees'),
      FeeStatement.fromApiBody,
    );
  }

  Future<void> refreshIfDue() async {
    final tokens = await tokenStore.read();
    if (tokens == null || !tokens.shouldRefresh) return;
    await refreshSession();
  }

  Future<void> refreshSession() {
    final pending = _refreshing;
    if (pending != null) return pending;
    final future = _refreshNow();
    _refreshing = future;
    return future.whenComplete(() {
      if (identical(_refreshing, future)) _refreshing = null;
    });
  }

  Future<void> _refreshNow() async {
    final tokens = await tokenStore.read();
    if (tokens == null || !tokens.canRefresh) {
      await tokenStore.clear();
      throw const ApiException(
        'Your session expired. Sign in again.',
        statusCode: 401,
      );
    }

    try {
      final response = await _refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': tokens.refreshToken},
      );
      final next = AuthTokens.fromApiBody(_asMap(response.data));
      await tokenStore.write(next);
    } on DioException catch (error) {
      await tokenStore.clear();
      throw ApiException.fromDio(error);
    } on FormatException {
      await tokenStore.clear();
      throw const ApiException('Unexpected response from the server.');
    }
  }

  Future<T> _send<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic> body) parse,
  ) async {
    final body = await _body(request);
    try {
      return parse(body);
    } on FormatException {
      throw const ApiException('Unexpected response from the server.');
    }
  }

  Future<Map<String, dynamic>> _body(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      return _asMap(response.data);
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Unexpected response from the server.');
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._client);

  final ApiClient _client;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['noAuth'] == true) {
      handler.next(options);
      return;
    }

    if (options.extra['skipRefresh'] != true) {
      try {
        await _client.refreshIfDue();
      } on ApiException {
        await _client.tokenStore.clear();
        _client.onSessionExpired();
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            error: 'Session expired',
          ),
        );
        return;
      }
    }

    final tokens = await _client.tokenStore.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final skip =
        options.extra['noAuth'] == true || options.extra['skipRefresh'] == true;
    final retried = options.extra['retried'] == true;
    if (err.response?.statusCode != 401 || skip || retried) {
      handler.next(err);
      return;
    }

    final current = await _client.tokenStore.read();
    if (current == null || !current.canRefresh) {
      await _client.tokenStore.clear();
      _client.onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      await _client.refreshSession();
      final latest = await _client.tokenStore.read();
      if (latest == null) {
        _client.onSessionExpired();
        handler.next(err);
        return;
      }
      options.extra['retried'] = true;
      options.headers['Authorization'] = 'Bearer ${latest.accessToken}';
      final response = await _client.dio.fetch<dynamic>(options);
      handler.resolve(response);
    } catch (_) {
      await _client.tokenStore.clear();
      _client.onSessionExpired();
      handler.next(err);
    }
  }
}
