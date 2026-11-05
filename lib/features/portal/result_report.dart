import 'package:finalrahman/core/json_utils.dart';
import 'package:finalrahman/features/portal/student.dart';

class SubjectScore {
  const SubjectScore({
    required this.name,
    required this.score,
    this.grade,
    this.remark,
  });

  final String name;
  final double score;
  final String? grade;
  final String? remark;

  factory SubjectScore.fromJson(Map<String, dynamic> json) {
    return SubjectScore(
      name: readString(json['name'], fallback: 'Subject'),
      score: readDouble(json['score']),
      grade: readOptionalString(json['grade']),
      remark: readOptionalString(json['remark']),
    );
  }
}

class FeeStatus {
  const FeeStatus({
    required this.periodNumber,
    required this.paymentsPerYear,
    required this.yearlyFee,
    required this.paidAmount,
    required this.requiredAmount,
    required this.isEligible,
  });

  final int periodNumber;
  final int paymentsPerYear;
  final double yearlyFee;
  final double paidAmount;
  final double requiredAmount;
  final bool isEligible;

  factory FeeStatus.fromJson(Map<String, dynamic> json) {
    return FeeStatus(
      periodNumber: readInt(json['period_number']) ?? 1,
      paymentsPerYear: readInt(json['payments_per_year']) ?? 1,
      yearlyFee: readDouble(json['yearly_fee']),
      paidAmount: readDouble(json['paid_amount']),
      requiredAmount: readDouble(json['required_amount']),
      isEligible: json['is_eligible'] == true,
    );
  }
}

class ExaminationResult {
  const ExaminationResult({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.term,
    required this.academicYear,
    required this.average,
    required this.classSize,
    required this.subjects,
    this.publishedAt,
    this.letterGrade,
    this.position,
    this.feeStatus,
  });

  final String key;
  final String title;
  final String subtitle;
  final String term;
  final String academicYear;
  final String? publishedAt;
  final double average;
  final String? letterGrade;
  final int? position;
  final int classSize;
  final List<SubjectScore> subjects;
  final FeeStatus? feeStatus;

  factory ExaminationResult.fromJson(Map<String, dynamic> json) {
    return ExaminationResult(
      key: readString(json['key']),
      title: readString(json['title'], fallback: 'Examination'),
      subtitle: readString(json['subtitle']),
      term: readString(json['term']),
      academicYear: readString(json['academic_year']),
      publishedAt: readOptionalString(json['published_at']),
      average: readDouble(json['average']),
      letterGrade: readOptionalString(json['letter_grade']),
      position: readInt(json['position']),
      classSize: readInt(json['class_size']) ?? 0,
      feeStatus: readMap(json['fee_status']) == null
          ? null
          : FeeStatus.fromJson(readMap(json['fee_status'])!),
      subjects: [
        for (final item in readList(json['subjects']))
          if (item is Map)
            SubjectScore.fromJson(Map<String, dynamic>.from(item)),
      ],
    );
  }
}

class ResultReport {
  const ResultReport({
    required this.student,
    required this.examinations,
    required this.availableYears,
  });

  final Student student;
  final List<ExaminationResult> examinations;
  final List<String> availableYears;

  factory ResultReport.fromApiBody(Map<String, dynamic> body) {
    final json = readEnvelope(body);
    final studentMap = readMap(json['student']) ?? const {};
    return ResultReport(
      student: Student.fromJson(studentMap),
      examinations: [
        for (final item in readList(json['examinations']))
          if (item is Map)
            ExaminationResult.fromJson(Map<String, dynamic>.from(item)),
      ],
      availableYears: [
        for (final year in readList(json['available_years'])) year.toString(),
      ],
    );
  }
}

List<ExaminationResult> newestExaminations(List<ExaminationResult> exams) {
  final dated = exams.any(
    (exam) => DateTime.tryParse(exam.publishedAt ?? '') != null,
  );
  if (!dated) return exams;
  final copy = [...exams];
  copy.sort((a, b) {
    final left = DateTime.tryParse(a.publishedAt ?? '');
    final right = DateTime.tryParse(b.publishedAt ?? '');
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return right.compareTo(left);
  });
  return copy;
}
