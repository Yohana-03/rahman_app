import 'package:finalrahman/core/network/api_client.dart';
import 'package:finalrahman/core/network/api_exception.dart';
import 'package:finalrahman/core/storage/pin_store.dart';
import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:finalrahman/core/storage/token_store.dart';
import 'package:finalrahman/features/auth/auth_tokens.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:flutter/foundation.dart';

enum AppPhase { splash, login, setPin, lock, selectStudent, portal }

class SessionController extends ChangeNotifier {
  SessionController({
    required this.api,
    required this.tokenStore,
    required this.pinStore,
    required this.preferences,
    required this.portal,
    required this.splashDuration,
  });

  final ApiClient api;
  final TokenStore tokenStore;
  final PinStore pinStore;
  final PreferenceStore preferences;
  final PortalController portal;
  final Duration splashDuration;

  AppPhase _phase = AppPhase.splash;
  AppPhase _restoredPhase = AppPhase.login;
  bool _busy = false;
  bool _closed = false;
  int _pinAttempts = 0;
  String? flashMessage;

  AppPhase get phase => _phase;
  bool get busy => _busy;

  Future<void> bootstrap() async {
    await Future.wait([
      _restore(),
      Future.delayed(splashDuration),
    ]);
    if (_closed) return;
    _phase = _restoredPhase;
    _notify();
  }

  Future<String?> login(String email, String password) async {
    try {
      _busy = true;
      _notify();
      final tokens = await api.login(email.trim(), password);
      await tokenStore.write(tokens);
      await preferences.writeLastEmail(email.trim());
      flashMessage = null;
      final hasPin = await pinStore.hasPin();
      _phase = hasPin ? AppPhase.selectStudent : AppPhase.setPin;
      if (hasPin) {
        await portal.loadStudents();
      }
      return null;
    } on ApiException catch (error) {
      return error.message;
    } finally {
      _busy = false;
      _notify();
    }
  }

  Future<void> completePinSetup(String pin) async {
    await pinStore.savePin(pin);
    _pinAttempts = 0;
    _phase = AppPhase.selectStudent;
    _notify();
    await portal.loadStudents();
  }

  Future<bool> verifyPin(String pin) => pinStore.verifyPin(pin);

  Future<void> changePin(String pin) => pinStore.savePin(pin);

  Future<String?> unlock(String pin) async {
    final matches = await pinStore.verifyPin(pin);
    if (!matches) {
      _pinAttempts += 1;
      if (_pinAttempts >= 5) {
        flashMessage = 'Too many PIN attempts. Sign in with your password.';
        await logout(keepFlash: true);
        return flashMessage;
      }
      final left = 5 - _pinAttempts;
      return 'Incorrect PIN. $left ${left == 1 ? 'attempt' : 'attempts'} left.';
    }

    _pinAttempts = 0;
    _phase = AppPhase.selectStudent;
    _notify();
    await portal.loadStudents();
    return null;
  }

  void enterPortal() {
    _phase = AppPhase.portal;
    _notify();
  }

  Future<void> logout({bool keepFlash = false}) async {
    final flash = flashMessage;
    try {
      await api.logout();
    } catch (_) {
      // Local sign-out continues when the network call fails.
    }
    await tokenStore.clear();
    await pinStore.clear();
    await preferences.clearSelectedStudentId();
    portal.reset();
    flashMessage = keepFlash ? flash : null;
    _pinAttempts = 0;
    _phase = AppPhase.login;
    _notify();
  }

  void handleSessionExpired() {
    portal.reset();
    flashMessage = 'Your session expired. Sign in again.';
    if (_phase == AppPhase.splash || _phase == AppPhase.login) return;
    _phase = AppPhase.login;
    _notify();
  }

  void clearFlash() {
    if (flashMessage == null) return;
    flashMessage = null;
    _notify();
  }

  void close() {
    _closed = true;
  }

  Future<void> _restore() async {
    AuthTokens? tokens;
    var hasPin = false;
    try {
      tokens = await tokenStore.read();
      hasPin = await pinStore.hasPin();
    } catch (_) {
      tokens = null;
    }

    if (tokens != null && tokens.shouldRefresh) {
      try {
        await api.refreshSession();
        tokens = await tokenStore.read();
      } catch (_) {
        tokens = null;
        flashMessage = 'Your session expired. Sign in again.';
      }
    } else if (tokens != null && tokens.isAccessExpired) {
      await tokenStore.clear();
      tokens = null;
      flashMessage = 'Your session expired. Sign in again.';
    }

    if (tokens == null) {
      _restoredPhase = AppPhase.login;
    } else if (!hasPin) {
      _restoredPhase = AppPhase.setPin;
    } else {
      _restoredPhase = AppPhase.lock;
    }
  }

  void _notify() {
    if (_closed) return;
    notifyListeners();
  }
}
