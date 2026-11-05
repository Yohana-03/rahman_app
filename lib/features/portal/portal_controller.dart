import 'package:finalrahman/core/network/api_client.dart';
import 'package:finalrahman/core/network/api_exception.dart';
import 'package:finalrahman/core/storage/preference_store.dart';
import 'package:finalrahman/features/auth/parent_profile.dart';
import 'package:finalrahman/features/portal/fee_statement.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/features/portal/student.dart';
import 'package:flutter/foundation.dart';

class PortalController extends ChangeNotifier {
  PortalController({required this.api, required this.preferences});

  final ApiClient api;
  final PreferenceStore preferences;

  ParentProfile? profile;
  List<Student> students = const [];
  Student? selected;
  ResultReport? report;
  FeeStatement? fees;
  bool loadingStudents = false;
  bool loadingProfile = false;
  bool loadingResults = false;
  bool loadingFees = false;
  String? studentsError;
  String? profileError;
  String? resultsError;
  String? feesError;

  int _studentsGeneration = 0;
  int _profileGeneration = 0;
  int _resultsGeneration = 0;
  int _feesGeneration = 0;
  bool _closed = false;

  Future<void> loadStudents() async {
    final generation = ++_studentsGeneration;
    loadingStudents = true;
    studentsError = null;
    _notify();
    try {
      final loaded = await api.students();
      if (generation != _studentsGeneration) return;
      students = loaded;
      final selectedId = selected?.id;
      if (selectedId != null) {
        for (final student in loaded) {
          if (student.id == selectedId) {
            selected = student;
            break;
          }
        }
      }
    } on ApiException catch (error) {
      if (generation != _studentsGeneration) return;
      studentsError = error.message;
    } finally {
      if (generation == _studentsGeneration) {
        loadingStudents = false;
        _notify();
      }
    }
  }

  Future<void> openStudent(Student student) async {
    selected = student;
    report = null;
    fees = null;
    resultsError = null;
    feesError = null;
    await preferences.writeSelectedStudentId(student.id);
    _notify();
    await Future.wait([loadProfile(), loadResults(), loadFees()]);
  }

  Future<void> loadProfile() async {
    final generation = ++_profileGeneration;
    loadingProfile = true;
    profileError = null;
    _notify();
    try {
      final loaded = await api.profile();
      if (generation != _profileGeneration) return;
      profile = loaded;
    } on ApiException catch (error) {
      if (generation != _profileGeneration) return;
      profileError = error.message;
    } finally {
      if (generation == _profileGeneration) {
        loadingProfile = false;
        _notify();
      }
    }
  }

  Future<void> loadResults() async {
    final student = selected;
    if (student == null) return;
    final generation = ++_resultsGeneration;
    loadingResults = true;
    resultsError = null;
    _notify();
    try {
      final loaded = await api.results(student.id);
      if (generation != _resultsGeneration) return;
      report = loaded;
    } on ApiException catch (error) {
      if (generation != _resultsGeneration) return;
      resultsError = error.message;
    } finally {
      if (generation == _resultsGeneration) {
        loadingResults = false;
        _notify();
      }
    }
  }

  Future<void> loadFees() async {
    final student = selected;
    if (student == null) return;
    final generation = ++_feesGeneration;
    loadingFees = true;
    feesError = null;
    _notify();
    try {
      final loaded = await api.fees(student.id);
      if (generation != _feesGeneration) return;
      fees = loaded;
    } on ApiException catch (error) {
      if (generation != _feesGeneration) return;
      feesError = error.statusCode == 404
          ? 'Fee records are not available from the school yet.'
          : error.message;
    } finally {
      if (generation == _feesGeneration) {
        loadingFees = false;
        _notify();
      }
    }
  }

  Future<void> refreshAll() async {
    await loadStudents();
    if (selected == null) return;
    await Future.wait([loadProfile(), loadResults(), loadFees()]);
  }

  void reset() {
    _studentsGeneration++;
    _profileGeneration++;
    _resultsGeneration++;
    _feesGeneration++;
    profile = null;
    students = const [];
    selected = null;
    report = null;
    fees = null;
    loadingStudents = false;
    loadingProfile = false;
    loadingResults = false;
    loadingFees = false;
    studentsError = null;
    profileError = null;
    resultsError = null;
    feesError = null;
    _notify();
  }

  void close() {
    _closed = true;
  }

  void _notify() {
    if (_closed) return;
    notifyListeners();
  }
}
