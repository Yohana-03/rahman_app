import 'package:finalrahman/core/json_utils.dart';

class SchoolClassInfo {
  const SchoolClassInfo({
    required this.id,
    required this.name,
    this.gradeLevel,
    this.schoolLevel,
  });

  final int id;
  final String name;
  final int? gradeLevel;
  final String? schoolLevel;

  factory SchoolClassInfo.fromJson(Map<String, dynamic> json) {
    return SchoolClassInfo(
      id: readInt(json['id']) ?? 0,
      name: readString(json['name']),
      gradeLevel: readInt(json['grade_level']),
      schoolLevel: readOptionalString(json['school_level']),
    );
  }
}

class Student {
  const Student({
    required this.id,
    required this.admissionNumber,
    required this.name,
    this.age,
    this.gender,
    this.grade,
    this.classTeacher,
    this.schoolClass,
  });

  final int id;
  final String admissionNumber;
  final String name;
  final int? age;
  final String? gender;
  final String? grade;
  final String? classTeacher;
  final SchoolClassInfo? schoolClass;

  String get className {
    final name = schoolClass?.name;
    if (name != null && name.isNotEmpty) return name;
    return grade ?? '';
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: readInt(json['id']) ?? 0,
      admissionNumber: readString(json['admission_number']),
      name: readString(json['name'], fallback: 'Student'),
      age: readInt(json['age']),
      gender: readOptionalString(json['gender']),
      grade: readOptionalString(json['grade']),
      classTeacher: readOptionalString(json['class_teacher']),
      schoolClass: readMap(json['school_class']) == null
          ? null
          : SchoolClassInfo.fromJson(readMap(json['school_class'])!),
    );
  }
}
