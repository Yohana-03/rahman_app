import 'package:finalrahman/core/storage/pin_store.dart';
import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:finalrahman/core/storage/token_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppDependencies {
  const AppDependencies({
    required this.tokenStore,
    required this.pinStore,
    required this.preferences,
  });

  final TokenStore tokenStore;
  final PinStore pinStore;
  final PreferenceStore preferences;

  factory AppDependencies.production() {
    const secure = FlutterSecureStorage();
    return AppDependencies(
      tokenStore: SecureTokenStore(secure),
      pinStore: SecurePinStore(secure),
      preferences: SharedPreferenceStore(),
    );
  }

  factory AppDependencies.memory() {
    return AppDependencies(
      tokenStore: MemoryTokenStore(),
      pinStore: MemoryPinStore(),
      preferences: MemoryPreferenceStore(),
    );
  }
}
