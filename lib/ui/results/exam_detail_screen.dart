import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/core/mark_scale.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/ui/results/subject_mark_chart.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';

class ExamDetailScreen extends StatelessWidget {
  const ExamDetailScreen({
    super.key,
    required this.exam,
    required this.className,
    required this.scale,
  });

  final ExaminationResult exam;
  final String className;
  final int scale;

  @override
  Widget build(BuildContext context) {
    final meta = examMeta(exam, className);
    return Scaffold(
      appBar: AppBar(title: Text(exam.title, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _ExamBanner(exam: exam, meta: meta, scale: scale),
          if (exam.subjects.isNotEmpty) ...[
            const SizedBox(height: 25),
            const SectionTitle('Performance chart', padding: EdgeInsets.zero),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
              decoration: portalCard(context),
              child: SubjectMarkChart(subjects: exam.subjects, scale: scale),
            ),
            const SizedBox(height: 25),
            const SectionTitle('Subject Performance', padding: EdgeInsets.zero),
            const SizedBox(height: 14),
            for (final subject in exam.subjects)
              _SubjectCard(subject: subject, scale: scale),
          ] else ...[
            const SizedBox(height: 20),
            Text(
              'Subject scores have not been published for this examination.',
              style: TextStyle(color: portalMuted(context), fontSize: 12),
            ),
          ],
          if (exam.feeStatus != null && !exam.feeStatus!.isEligible) ...[
            const SizedBox(height: 8),
            const Text(
              'Some papers may stay hidden until the term fee is cleared.',
              style: TextStyle(color: AppColors.orange, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

String totalMarksLabel(ExaminationResult exam) {
  if (exam.subjects.isEmpty) return '—';
  final total = exam.subjects.fold<double>(
    0,
    (sum, subject) => sum + subject.score,
  );
  return formatScore(total);
}

String examMeta(ExaminationResult exam, String className) {
  final detail = exam.subtitle.isNotEmpty
      ? stripAdmission(exam.subtitle)
      : [
          if (exam.term.isNotEmpty) exam.term,
          if (exam.academicYear.isNotEmpty) exam.academicYear,
        ].join(' ');
  return [
    if (className.isNotEmpty) className,
    if (detail.isNotEmpty) detail,
    if (formatLongDate(exam.publishedAt).isNotEmpty)
      formatLongDate(exam.publishedAt),
  ].join(' • ');
}

class _ExamBanner extends StatelessWidget {
  const _ExamBanner({
    required this.exam,
    required this.meta,
    required this.scale,
  });

  final ExaminationResult exam;
  final String meta;
  final int scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brand,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exam.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              meta,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              _ResultMetric(
                label: 'Average',
                value: formatMark(exam.average, scale),
              ),
              _ResultMetric(label: 'Grade', value: exam.letterGrade ?? '—'),
              _ResultMetric(label: 'Total Marks', value: totalMarksLabel(exam)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _ResultMetric(
                label: 'Position',
                value: exam.position?.toString() ?? '—',
              ),
              _ResultMetric(
                label: 'Out of',
                value: exam.classSize > 0 ? '${exam.classSize}' : '—',
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultMetric extends StatelessWidget {
  const _ResultMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject, required this.scale});

  final SubjectScore subject;
  final int scale;

  @override
  Widget build(BuildContext context) {
    final fraction = markFraction(subject.score, scale);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: portalCard(context, radius: 15),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  subject.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: portalInk(context),
                  ),
                ),
              ),
              Text(
                formatMark(subject.score, scale),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              if (subject.grade != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: portalTint(context),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    subject.grade!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 6,
              backgroundColor: portalTint(context),
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
