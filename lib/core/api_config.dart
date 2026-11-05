class ApiConfig {
  static const baseUrl = 'https://rahman.ac.tz/api/v1';

  /// Refresh the access token this long before the server says it expires.
  static const refreshSkew = Duration(seconds: 45);
}

class AppTiming {
  static const splash = Duration(seconds: 3);
}

const pinLength = 4;
