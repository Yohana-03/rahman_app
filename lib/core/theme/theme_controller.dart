import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:flutter/material.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferences);

  final PreferenceStore _preferences;
  ThemePreference _preference = ThemePreference.light;
  bool _closed = false;

  ThemePreference get preference => _preference;

  ThemeMode get themeMode =>
      _preference == ThemePreference.dark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final stored = await _preferences.readTheme();
    if (_closed) return;
    _preference = stored;
    notifyListeners();
  }

  Future<void> setPreference(ThemePreference preference) async {
    _preference = preference;
    notifyListeners();
    await _preferences.writeTheme(preference);
  }

  void close() {
    _closed = true;
  }
}
