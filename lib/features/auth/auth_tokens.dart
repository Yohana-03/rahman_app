import 'package:finalrahman/core/api_config.dart';
import 'package:finalrahman/core/json_utils.dart';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.accessExpiresAt,
  });

  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final DateTime? accessExpiresAt;

  bool get canRefresh => refreshToken != null && refreshToken!.isNotEmpty;

  bool get isAccessExpired {
    final expiry = accessExpiresAt;
    if (expiry == null) return false;
    return !DateTime.now().isBefore(expiry);
  }

  bool get shouldRefresh {
    final expiry = accessExpiresAt;
    if (!canRefresh || expiry == null) return false;
    return !DateTime.now().isBefore(expiry.subtract(ApiConfig.refreshSkew));
  }

  factory AuthTokens.fromApiBody(Map<String, dynamic> body) {
    final map = readEnvelope(body);
    final access = map['access_token'] ?? map['token'];
    if (access is! String || access.isEmpty) {
      throw const FormatException('Missing access token');
    }

    final refresh = map['refresh_token'];
    final expiresIn = map['expires_in'];
    DateTime? expiresAt;
    if (expiresIn is num) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn.toInt()));
    }
    final storedExpiry = map['access_expires_at'];
    if (expiresAt == null && storedExpiry is String) {
      expiresAt = DateTime.tryParse(storedExpiry);
    }

    final tokenType = map['token_type'];
    return AuthTokens(
      accessToken: access,
      refreshToken: refresh is String && refresh.isNotEmpty ? refresh : null,
      tokenType: tokenType is String && tokenType.isNotEmpty
          ? tokenType
          : 'Bearer',
      accessExpiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'access_expires_at': accessExpiresAt?.toIso8601String(),
    };
  }
}
