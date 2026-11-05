import 'package:shared_preferences/shared_preferences.dart';

enum ThemePreference { light, dark }

abstract class PreferenceStore {
  Future<ThemePreference> readTheme();
  Future<void> writeTheme(ThemePreference preference);
  Future<int?> readSelectedStudentId();
  Future<void> writeSelectedStudentId(int id);
  Future<void> clearSelectedStudentId();
  Future<String?> readLastEmail();
  Future<void> writeLastEmail(String email);
}

class SharedPreferenceStore implements PreferenceStore {
  static const _themeKey = 'theme_mode';
  static const _studentKey = 'selected_student_id';
  static const _emailKey = 'last_email';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<ThemePreference> readTheme() async {
    final value = (await _prefs).getString(_themeKey);
    return value == 'dark' ? ThemePreference.dark : ThemePreference.light;
  }

  @override
  Future<void> writeTheme(ThemePreference preference) async {
    await (await _prefs).setString(
      _themeKey,
      preference == ThemePreference.dark ? 'dark' : 'light',
    );
  }

  @override
  Future<int?> readSelectedStudentId() async {
    return (await _prefs).getInt(_studentKey);
  }

  @override
  Future<void> writeSelectedStudentId(int id) async {
    await (await _prefs).setInt(_studentKey, id);
  }

  @override
  Future<void> clearSelectedStudentId() async {
    await (await _prefs).remove(_studentKey);
  }

  @override
  Future<String?> readLastEmail() async {
    return (await _prefs).getString(_emailKey);
  }

  @override
  Future<void> writeLastEmail(String email) async {
    await (await _prefs).setString(_emailKey, email);
  }
}

class MemoryPreferenceStore implements PreferenceStore {
  ThemePreference theme = ThemePreference.light;
  int? selectedStudentId;
  String? lastEmail;

  @override
  Future<void> clearSelectedStudentId() async {
    selectedStudentId = null;
  }

  @override
  Future<String?> readLastEmail() async => lastEmail;

  @override
  Future<int?> readSelectedStudentId() async => selectedStudentId;

  @override
  Future<ThemePreference> readTheme() async => theme;

  @override
  Future<void> writeLastEmail(String email) async {
    lastEmail = email;
  }

  @override
  Future<void> writeSelectedStudentId(int id) async {
    selectedStudentId = id;
  }

  @override
  Future<void> writeTheme(ThemePreference preference) async {
    theme = preference;
  }
}
