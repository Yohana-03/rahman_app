import 'package:finalrahman/core/mark_scale.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/features/portal/student.dart';
import 'package:finalrahman/ui/results/exam_detail_screen.dart';
import 'package:finalrahman/ui/results/performance_tracker.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String? _year;

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<PortalController>();
    final report = portal.report;
    final years = _years(report);

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeader(title: 'Academic Results'),
          ),
          if (years.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                children: [
                  _YearChip(
                    label: 'All years',
                    selected: _year == null,
                    onSelected: () => setState(() => _year = null),
                  ),
                  for (final year in years)
                    _YearChip(
                      label: year,
                      selected: _year == year,
                      onSelected: () => setState(() => _year = year),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(child: _body(portal, report)),
        ],
      ),
    );
  }

  Widget _body(PortalController portal, ResultReport? report) {
    if (portal.loadingResults && report == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (portal.resultsError != null && report == null) {
      return Center(
        child: StatusMessage(
          message: portal.resultsError!,
          icon: Icons.cloud_off_outlined,
          actionLabel: 'Try again',
          onAction: portal.loadResults,
        ),
      );
    }
    if (report == null || report.examinations.isEmpty) {
      return const Center(
        child: StatusMessage(
          message:
              'No published results yet. If a paper is missing, the school may still be publishing it, or the fee for that term may be outstanding.',
          icon: Icons.school_outlined,
        ),
      );
    }

    final visible = newestExaminations(
      _year == null
          ? report.examinations
          : report.examinations
                .where((item) => item.academicYear == _year)
                .toList(),
    );
    final className = portal.selected?.className ?? report.student.className;
    final studentName = portal.selected?.name ?? report.student.name;
    final chartExams = _year == null ? _latestYear(visible) : visible;
    final points = trackerPoints(chartExams);
    final scale = scaleForExams(
      chartExams.isEmpty ? visible : chartExams,
      portal.selected ?? report.student,
    );

    return RefreshIndicator(
      onRefresh: portal.loadResults,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          if (points.isNotEmpty) ...[
            Text(
              'Student performance tracker — ${studentName.toUpperCase()}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            PerformanceTracker(points: points, scale: scale),
            const SizedBox(height: 28),
          ],
          Text(
            'Recent Results',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: portalInk(context),
            ),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('No published examinations for this year.'),
            )
          else
            for (final exam in visible) ...[
              _ExamTile(
                exam: exam,
                className: className,
                scale: scaleForExam(exam, portal.selected ?? report.student),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExamDetailScreen(
                        exam: exam,
                        className: className,
                        scale: scaleForExam(
                          exam,
                          portal.selected ?? report.student,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  List<ExaminationResult> _latestYear(List<ExaminationResult> exams) {
    if (exams.isEmpty) return exams;
    final dated = exams
        .map((exam) => DateTime.tryParse(exam.publishedAt ?? '')?.toLocal())
        .whereType<DateTime>()
        .toList();
    if (dated.isEmpty) {
      final year = exams.first.academicYear;
      if (year.isEmpty) return exams;
      return exams.where((exam) => exam.academicYear == year).toList();
    }
    final latest = dated.reduce((a, b) => a.isAfter(b) ? a : b).year;
    return exams.where((exam) {
      final published = DateTime.tryParse(exam.publishedAt ?? '')?.toLocal();
      return published != null && published.year == latest;
    }).toList();
  }

  List<String> _years(ResultReport? report) {
    if (report == null) return const [];
    if (report.availableYears.isNotEmpty) return report.availableYears;
    return report.examinations
        .map((item) => item.academicYear)
        .where((year) => year.isNotEmpty)
        .toSet()
        .toList();
  }
}

int scaleForExam(ExaminationResult exam, Student? student) {
  return scaleForExams([exam], student);
}

int scaleForExams(List<ExaminationResult> exams, Student? student) {
  return markScale(
    scores: [
      for (final exam in exams) ...[
        exam.average,
        for (final subject in exam.subjects) subject.score,
      ],
    ],
    grades: [
      for (final exam in exams) ...[
        exam.letterGrade,
        for (final subject in exam.subjects) subject.grade,
      ],
    ],
    schoolLevel: student?.schoolClass?.schoolLevel,
    gradeLevel: student?.schoolClass?.gradeLevel,
    className: student?.className,
  );
}

class _YearChip extends StatelessWidget {
  const _YearChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: selected,
        onSelected: (_) => onSelected(),
        selectedColor: portalTint(context),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: selected
              ? Theme.of(context).colorScheme.primary
              : portalMuted(context),
        ),
      ),
    );
  }
}

class _ExamTile extends StatelessWidget {
  const _ExamTile({
    required this.exam,
    required this.className,
    required this.scale,
    required this.onTap,
  });

  final ExaminationResult exam;
  final String className;
  final int scale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = examMeta(exam, className);
    final standing = exam.position == null
        ? null
        : exam.classSize > 0
        ? '${exam.position} out of ${exam.classSize}'
        : 'Position ${exam.position}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(15),
          decoration: portalCard(context, radius: 15),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: portalInk(context),
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta,
                        style: TextStyle(
                          color: portalMuted(context),
                          fontSize: 11,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      [
                        formatMark(exam.average, scale),
                        ?exam.letterGrade,
                        ?standing,
                      ].join('  •  '),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: portalMuted(context)),
            ],
          ),
        ),
      ),
    );
  }
}
