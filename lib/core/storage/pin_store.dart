import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PinStore {
  Future<bool> hasPin();
  Future<void> savePin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clear();
}

class SecurePinStore implements PinStore {
  SecurePinStore(this._storage);

  static const _hashKey = 'rahman_pin_hash';
  static const _saltKey = 'rahman_pin_salt';

  final FlutterSecureStorage _storage;

  @override
  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _hashKey);
    return hash != null && hash.isNotEmpty;
  }

  @override
  Future<void> savePin(String pin) async {
    final salt = _randomSalt();
    await _storage.write(key: _saltKey, value: salt);
    await _storage.write(key: _hashKey, value: hashPin(pin, salt));
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _saltKey);
    final expected = await _storage.read(key: _hashKey);
    if (salt == null || expected == null) return false;
    return _constantTimeEquals(hashPin(pin, salt), expected);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _hashKey);
    await _storage.delete(key: _saltKey);
  }
}

class MemoryPinStore implements PinStore {
  String? _hash;
  String? _salt;

  @override
  Future<void> clear() async {
    _hash = null;
    _salt = null;
  }

  @override
  Future<bool> hasPin() async => _hash != null;

  @override
  Future<void> savePin(String pin) async {
    _salt = _randomSalt();
    _hash = hashPin(pin, _salt!);
  }

  @override
  Future<bool> verifyPin(String pin) async {
    if (_hash == null || _salt == null) return false;
    return _constantTimeEquals(hashPin(pin, _salt!), _hash!);
  }
}

String hashPin(String pin, String salt) {
  return sha256.convert(utf8.encode('$salt:$pin')).toString();
}

String _randomSalt() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return base64Url.encode(bytes);
}

bool _constantTimeEquals(String a, String b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
  }
  return diff == 0;
}
