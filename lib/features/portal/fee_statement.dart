import 'package:finalrahman/core/json_utils.dart';

class FeePaymentRecord {
  const FeePaymentRecord({
    required this.id,
    required this.amount,
    this.receiptNumber,
    this.bankName,
    this.academicYear,
    this.paidAt,
    this.notes,
  });

  final int id;
  final double amount;
  final String? receiptNumber;
  final String? bankName;
  final String? academicYear;
  final String? paidAt;
  final String? notes;

  factory FeePaymentRecord.fromJson(Map<String, dynamic> json) {
    return FeePaymentRecord(
      id: readInt(json['id']) ?? 0,
      amount: readDouble(json['amount']),
      receiptNumber: readOptionalString(json['receipt_number']),
      bankName: readOptionalString(json['bank_name']),
      academicYear: readOptionalString(json['academic_year']),
      paidAt: readOptionalString(json['paid_at']),
      notes: readOptionalString(json['notes']),
    );
  }
}

class FeeStatement {
  const FeeStatement({
    required this.studentId,
    required this.currency,
    required this.yearlyFee,
    required this.discount,
    required this.netFee,
    required this.paidAmount,
    required this.balance,
    required this.paymentsPerYear,
    required this.payments,
    this.academicYear,
  });

  final int studentId;
  final String? academicYear;
  final String currency;
  final double yearlyFee;
  final double discount;
  final double netFee;
  final double paidAmount;
  final double balance;
  final int paymentsPerYear;
  final List<FeePaymentRecord> payments;

  double get progress {
    if (netFee <= 0) return paidAmount > 0 ? 1 : 0;
    final value = paidAmount / netFee;
    if (value < 0) return 0;
    if (value > 1) return 1;
    return value;
  }

  bool get isPaidInFull => balance <= 0 && (netFee > 0 || paidAmount > 0);

  factory FeeStatement.fromApiBody(Map<String, dynamic> body) {
    final json = readEnvelope(body);
    return FeeStatement(
      studentId: readInt(json['student_id']) ?? 0,
      academicYear: readOptionalString(json['academic_year']),
      currency: readString(json['currency'], fallback: 'TZS'),
      yearlyFee: readDouble(json['yearly_fee']),
      discount: readDouble(json['discount']),
      netFee: readDouble(json['net_fee']),
      paidAmount: readDouble(json['paid_amount']),
      balance: readDouble(json['balance']),
      paymentsPerYear: readInt(json['payments_per_year']) ?? 1,
      payments: [
        for (final item in readList(json['payments']))
          if (item is Map)
            FeePaymentRecord.fromJson(Map<String, dynamic>.from(item)),
      ],
    );
  }
}
