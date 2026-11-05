import 'dart:convert';

import 'package:finalrahman/features/auth/auth_tokens.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStore {
  Future<AuthTokens?> read();
  Future<void> write(AuthTokens tokens);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._storage);

  static const _key = 'rahman_auth_tokens';

  final FlutterSecureStorage _storage;

  @override
  Future<AuthTokens?> read() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return AuthTokens.fromApiBody(Map<String, dynamic>.from(decoded));
  }

  @override
  Future<void> write(AuthTokens tokens) {
    return _storage.write(key: _key, value: jsonEncode(tokens.toJson()));
  }

  @override
  Future<void> clear() {
    return _storage.delete(key: _key);
  }
}

class MemoryTokenStore implements TokenStore {
  AuthTokens? _tokens;

  @override
  Future<void> clear() async {
    _tokens = null;
  }

  @override
  Future<AuthTokens?> read() async => _tokens;

  @override
  Future<void> write(AuthTokens tokens) async {
    _tokens = tokens;
  }
}
