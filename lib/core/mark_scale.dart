import 'package:finalrahman/core/formatters.dart';

/// Papers are marked out of 50 or out of 100.
/// A mark above 50 can only belong to the 100-point scale.
/// An A or B at 50 or below belongs to the 50-point scale.
int markScale({
  required Iterable<double> scores,
  Iterable<String?> grades = const [],
  String? schoolLevel,
  int? gradeLevel,
  String? className,
}) {
  var maxScore = 0.0;
  for (final score in scores) {
    if (score.isFinite && score > maxScore) maxScore = score;
  }
  if (maxScore > 50) return 100;
  if (grades.any(isHighGrade)) return 50;

  final level = classifyLevel(schoolLevel, gradeLevel, className);
  if (level == StudyLevel.secondary) return 100;
  if (level == StudyLevel.primary) return 50;
  if (hasFailingGradeAbovePrimaryRange(scores, grades)) return 100;
  return 50;
}

enum StudyLevel { primary, secondary, unknown }

StudyLevel classifyLevel(String? schoolLevel, int? gradeLevel, String? className) {
  final text = '${schoolLevel ?? ''} ${className ?? ''}'.toLowerCase();
  if (RegExp(r'\bform\b|\bkidato\b|secondary|o-level|a-level').hasMatch(text)) {
    return StudyLevel.secondary;
  }
  if (RegExp(r'standard|darasa|\bstd\b|primary').hasMatch(text)) {
    return StudyLevel.primary;
  }
  final gradeMatch = RegExp(r'grade\s*(\d+)').firstMatch(text);
  if (gradeMatch != null) {
    final level = int.tryParse(gradeMatch.group(1)!);
    if (level != null) {
      return level <= 7 ? StudyLevel.primary : StudyLevel.secondary;
    }
  }
  if (gradeLevel != null) {
    return gradeLevel <= 7 ? StudyLevel.primary : StudyLevel.secondary;
  }
  return StudyLevel.unknown;
}

bool isHighGrade(String? grade) {
  final letter = grade?.trim().toUpperCase() ?? '';
  return letter.startsWith('A') || letter.startsWith('B');
}

bool hasFailingGradeAbovePrimaryRange(
  Iterable<double> scores,
  Iterable<String?> grades,
) {
  final markList = scores.toList();
  final gradeList = grades.toList();
  final count = markList.length < gradeList.length
      ? markList.length
      : gradeList.length;
  for (var index = 0; index < count; index++) {
    final letter = gradeList[index]?.trim().toUpperCase() ?? '';
    final failing =
        letter.startsWith('D') ||
        letter.startsWith('E') ||
        letter.startsWith('F');
    if (failing && markList[index] >= 21) return true;
  }
  return false;
}

String formatMark(double value, int scale) {
  final number = formatScore(value);
  if (scale >= 100) return '$number%';
  return number;
}

double markFraction(double value, int scale) {
  if (scale <= 0) return 0;
  final fraction = value / scale;
  if (fraction < 0) return 0;
  if (fraction > 1) return 1;
  return fraction;
}

String? performanceChangeLabel(double recent, double? previous) {
  if (previous == null) return null;
  final delta = recent - previous;
  if (delta.abs() < 0.05) return 'No change from previous examination';
  if (previous.abs() < 0.05) {
    return delta > 0
        ? 'Increase from previous examination'
        : 'Fall from previous examination';
  }
  final amount = formatPlainNumber(delta.abs() / previous.abs() * 100);
  if (delta > 0) return 'Increase by $amount% from previous examination';
  return 'Fall by $amount% from previous examination';
}
