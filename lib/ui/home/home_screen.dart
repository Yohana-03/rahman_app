import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/core/mark_scale.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/features/portal/fee_statement.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:finalrahman/features/portal/student.dart';
import 'package:finalrahman/ui/shell/shell_scope.dart';
import 'package:finalrahman/ui/students/student_selector_screen.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<PortalController>();
    final student = portal.selected;
    final activities = recentActivities(portal);
    final ordered = newestExaminations(portal.report?.examinations ?? const []);
    final latest = ordered.isEmpty ? null : ordered.first;
    final previous = ordered.length < 2 ? null : ordered[1];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          _HomeHeader(portal: portal),
          Expanded(
            child: RefreshIndicator(
              onRefresh: portal.refreshAll,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
            const SliverToBoxAdapter(child: _HeroBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Student Overview',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: portalInk(context),
                        ),
                      ),
                    ),
                    ArrowLink(
                      label: 'See all',
                      onPressed: () => _openStudents(context),
                    ),
                  ],
                ),
              ),
            ),
            if (student != null)
              SliverToBoxAdapter(child: _StudentCard(student: student)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
                child: Text(
                  'Quick Access',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: portalInk(context),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    QuickAction(
                      icon: Icons.receipt_long_rounded,
                      label: 'School Fees',
                      color: AppColors.brand,
                      onTap: () => ShellScope.maybeOf(context)?.openTab(1),
                    ),
                    QuickAction(
                      icon: Icons.menu_book_rounded,
                      label: 'Results',
                      color: AppColors.green,
                      onTap: () => ShellScope.maybeOf(context)?.openTab(2),
                    ),
                    QuickAction(
                      icon: Icons.child_care_outlined,
                      label: 'My Children',
                      color: AppColors.orange,
                      onTap: () => _openStudents(context),
                    ),
                    QuickAction(
                      icon: Icons.campaign_rounded,
                      label: 'Updates',
                      color: Colors.purple,
                      onTap: () => _showUpdates(context, activities),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Financial Overview',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: portalInk(context),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: _FinanceRow(portal: portal)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 12, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Academic Performance',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: portalInk(context),
                        ),
                      ),
                    ),
                    ArrowLink(
                      label: 'View all',
                      onPressed: () => ShellScope.maybeOf(context)?.openTab(2),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _PerformanceCard(
                exam: latest,
                previous: previous,
                student: student ?? portal.report?.student,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Recent Activities',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: portalInk(context),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                child: activities.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: portalCard(context, radius: 15),
                        child: Text(
                          'Payments and published results will show up here.',
                          style: TextStyle(
                            color: portalMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          for (final activity in activities)
                            ActivityTile(
                              icon: activity.icon,
                              title: activity.title,
                              subtitle: activity.subtitle,
                              color: activity.color,
                            ),
                        ],
                      ),
              ),
            ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.portal});

  final PortalController portal;

  @override
  Widget build(BuildContext context) {
    final name = portal.profile?.name ?? '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 16),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: portalTint(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.school_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Parent Portal',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    letterSpacing: 0.5,
                    color: portalInk(context),
                  ),
                ),
                const SizedBox(height: 3),
                /*Text(
                  '',
                  style: TextStyle(color: portalMuted(context), fontSize: 12),
                ),*/
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showUpdates(context, recentActivities(portal)),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          GestureDetector(
            onTap: () => ShellScope.maybeOf(context)?.openTab(3),
            child: name.isEmpty
                ? CircleAvatar(
                    radius: 21,
                    backgroundColor: portalTint(context),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : InitialsAvatar(name: name, radius: 21),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.fromLTRB(22, 20, 8, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.brand, AppColors.brandDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'WELCOME TO YOUR PARENT PORTAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Your child's school journey,\nall in one place.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => ShellScope.maybeOf(context)?.openTab(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.brand,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Academic Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              flex: 5,
              child: Image(
                image: AssetImage('assets/images/hero_student.png'),
                height: 168,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final details = student.className;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: portalCard(context),
        child: Row(
          children: [
            InitialsAvatar(name: student.name, radius: 27),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: portalInk(context),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    details.isEmpty ? 'Student record' : details,
                    style: TextStyle(color: portalMuted(context), fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.verified_rounded, color: AppColors.green, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  const _FinanceRow({required this.portal});

  final PortalController portal;

  @override
  Widget build(BuildContext context) {
    final fees = portal.fees;
    final total = fees == null ? '—' : formatTzs(fees.netFee);
    final balance = fees == null ? '—' : formatTzs(fees.balance);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: 'Total Fees',
                  amount: total,
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  title: 'Due Amount',
                  amount: balance,
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.orange,
                ),
              ),
            ],
          ),
          if (portal.feesError != null && fees == null) ...[
            const SizedBox(height: 10),
            Text(
              portal.feesError!,
              style: TextStyle(color: portalMuted(context), fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  const _PerformanceCard({
    required this.exam,
    required this.previous,
    required this.student,
  });

  final ExaminationResult? exam;
  final ExaminationResult? previous;
  final Student? student;

  @override
  Widget build(BuildContext context) {
    final current = exam;
    final scale = current == null
        ? 100
        : markScale(
            scores: [
              current.average,
              for (final subject in current.subjects) subject.score,
            ],
            grades: [
              current.letterGrade,
              for (final subject in current.subjects) subject.grade,
            ],
            schoolLevel: student?.schoolClass?.schoolLevel,
            gradeLevel: student?.schoolClass?.gradeLevel,
            className: student?.className,
          );
    final average = current?.average ?? 0;
    final progress = markFraction(average, scale);
    final change = current == null
        ? null
        : performanceChangeLabel(current.average, previous?.average);
    final fell = change != null && change.startsWith('Fall');
    final flat = change != null && change.startsWith('No change');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: portalCard(context),
        child: current == null
            ? Text(
                'Published results will show here once the school releases them.',
                style: TextStyle(color: portalMuted(context), fontSize: 12),
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: portalTint(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Performance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: portalInk(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              current.title,
                              style: TextStyle(
                                color: portalMuted(context),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        current.letterGrade ?? '—',
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Average Score',
                        style: TextStyle(
                          fontSize: 12,
                          color: portalInk(context),
                        ),
                      ),
                      Text(
                        formatMark(average, scale),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 9,
                      backgroundColor: portalTint(context),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (change != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          flat
                              ? Icons.trending_flat
                              : fell
                              ? Icons.trending_down
                              : Icons.trending_up,
                          color: flat
                              ? portalMuted(context)
                              : fell
                              ? AppColors.red
                              : AppColors.green,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            change,
                            style: TextStyle(
                              color: flat
                                  ? portalMuted(context)
                                  : fell
                                  ? AppColors.red
                                  : AppColors.green,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class PortalActivity {
  const PortalActivity({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.when,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final DateTime? when;
}

List<PortalActivity> recentActivities(PortalController portal) {
  final items = <PortalActivity>[];
  final fees = portal.fees;
  if (fees != null) {
    for (final payment in fees.payments) {
      items.add(_paymentActivity(payment));
    }
  }
  for (final exam in portal.report?.examinations ?? const <ExaminationResult>[]) {
    final when = formatLongDate(exam.publishedAt);
    items.add(
      PortalActivity(
        icon: Icons.assignment_rounded,
        title: 'Examination results published',
        subtitle: [exam.title, if (when.isNotEmpty) when].join(' • '),
        color: AppColors.brand,
        when: DateTime.tryParse(exam.publishedAt ?? '')?.toLocal(),
      ),
    );
  }
  items.sort((a, b) {
    final left = a.when;
    final right = b.when;
    if (left == null && right == null) return 0;
    if (left == null) return 1;
    if (right == null) return -1;
    return right.compareTo(left);
  });
  if (items.length <= 4) return items;
  return items.sublist(0, 4);
}

PortalActivity _paymentActivity(FeePaymentRecord payment) {
  final when = formatLongDate(payment.paidAt);
  return PortalActivity(
    icon: Icons.payment_rounded,
    title: 'School fee payment recorded',
    subtitle: [
      if (payment.receiptNumber != null) payment.receiptNumber!,
      if (when.isNotEmpty) when else 'Payment received',
    ].join(' • '),
    color: AppColors.green,
    when: DateTime.tryParse(payment.paidAt ?? '')?.toLocal(),
  );
}

void _openStudents(BuildContext context) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const StudentSelectorScreen()),
  );
}

void _showUpdates(BuildContext context, List<PortalActivity> activities) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(
              'Updates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: portalInk(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Recent payments and published results',
              style: TextStyle(fontSize: 12, color: portalMuted(context)),
            ),
            const SizedBox(height: 16),
            if (activities.isEmpty)
              Text(
                'No updates yet.',
                style: TextStyle(color: portalMuted(context), fontSize: 12),
              )
            else
              for (final activity in activities)
                ActivityTile(
                  icon: activity.icon,
                  title: activity.title,
                  subtitle: activity.subtitle,
                  color: activity.color,
                ),
          ],
        ),
      );
    },
  );
}
