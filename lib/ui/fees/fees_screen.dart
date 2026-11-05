import 'package:finalrahman/core/formatters.dart';
import 'package:finalrahman/core/theme/app_theme.dart';
import 'package:finalrahman/features/portal/fee_statement.dart';
import 'package:finalrahman/features/portal/portal_controller.dart';
import 'package:finalrahman/ui/widgets/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final portal = context.watch<PortalController>();
    final fees = portal.fees;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageHeader(
              title: 'School Fees',
              subtitle: studyYearLabel(fees?.academicYear),
            ),
          ),
          Expanded(child: _body(context, portal, fees)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    PortalController portal,
    FeeStatement? fees,
  ) {
    if (portal.loadingFees && fees == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (portal.feesError != null && fees == null) {
      return Center(
        child: StatusMessage(
          message: portal.feesError!,
          icon: Icons.account_balance_wallet_outlined,
          actionLabel: 'Try again',
          onAction: portal.loadFees,
        ),
      );
    }
    if (fees == null) {
      return const Center(
        child: StatusMessage(
          message: 'Fee records will appear here for the selected student.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: portal.loadFees,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
            _BalanceBanner(fees: fees),
            const SizedBox(height: 25),
            const SectionTitle('Payment Summary', padding: EdgeInsets.zero),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: 'Amount Paid',
                    amount: formatTzs(fees.paidAmount),
                    icon: Icons.check_circle_outline,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: 'Due Amount',
                    amount: formatTzs(fees.balance),
                    icon: Icons.pending_outlined,
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const SectionTitle(
              'Fee Payment Progress',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 12),
            _ProgressCard(fees: fees),
            const SizedBox(height: 25),
            const SectionTitle('Recent Transactions', padding: EdgeInsets.zero),
            const SizedBox(height: 12),
            if (fees.payments.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: portalCard(context, radius: 15),
                child: Text(
                  'No payments have been recorded for this year.',
                  style: TextStyle(color: portalMuted(context), fontSize: 12),
                ),
              )
            else
              for (final payment in fees.payments)
                _TransactionTile(payment: payment),
        ],
      ),
    );
  }
}

String studyYearLabel(String? academicYear) {
  final year = academicYear?.trim() ?? '';
  final value = year.isEmpty ? '${DateTime.now().year}' : year;
  return 'Academic year $value';
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.fees});

  final FeeStatement fees;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.brand, AppColors.brandDark],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Due Amount',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Text(
            formatTzs(fees.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Fee',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatTzs(fees.netFee),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (fees.discount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Discount',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  formatTzs(fees.discount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.fees});

  final FeeStatement fees;

  @override
  Widget build(BuildContext context) {
    final percent = formatPlainNumber(fees.progress * 100);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: portalCard(context, radius: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment completion',
                style: TextStyle(color: portalInk(context)),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: fees.progress,
              minHeight: 10,
              color: AppColors.green,
              backgroundColor: portalTint(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.payment});

  final FeePaymentRecord payment;

  @override
  Widget build(BuildContext context) {
    final when = formatLongDate(payment.paidAt);
    final reference = payment.receiptNumber ?? 'Payment';
    final bank = payment.bankName == null ? '' : titleCase(payment.bankName);
    final meta = [
      reference,
      if (bank.isNotEmpty) bank,
      if (when.isNotEmpty) when,
    ].join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: portalCard(context, radius: 15),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: AppColors.paid,
            child: Icon(Icons.payments, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'School Fees Payment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: portalInk(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: TextStyle(fontSize: 9, color: portalMuted(context)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatTzs(payment.amount),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }
}
