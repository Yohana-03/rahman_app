import 'package:finalrahman/features/auth/auth_tokens.dart';
import 'package:finalrahman/features/portal/fee_statement.dart';
import 'package:finalrahman/features/portal/result_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login payload keeps a rotating access token', () {
    final tokens = AuthTokens.fromApiBody({
      'success': true,
      'data': {
        'token': 'access-1',
        'access_token': 'access-1',
        'refresh_token': 'refresh-1',
        'token_type': 'Bearer',
        'expires_in': 900,
      },
    });

    expect(tokens.accessToken, 'access-1');
    expect(tokens.refreshToken, 'refresh-1');
    expect(tokens.canRefresh, isTrue);
    expect(tokens.shouldRefresh, isFalse);
    expect(
      tokens.accessExpiresAt!.isAfter(
        DateTime.now().add(const Duration(minutes: 14)),
      ),
      isTrue,
    );
  });

  test('a token near expiry is ready to refresh', () {
    final tokens = AuthTokens.fromApiBody({
      'access_token': 'access-2',
      'refresh_token': 'refresh-2',
      'expires_in': 10,
    });

    expect(tokens.shouldRefresh, isTrue);
  });

  test('legacy sanctum token is accepted without a refresh token', () {
    final tokens = AuthTokens.fromApiBody({
      'data': {'token': 'plain-token', 'token_type': 'Bearer'},
    });

    expect(tokens.accessToken, 'plain-token');
    expect(tokens.canRefresh, isFalse);
    expect(tokens.shouldRefresh, isFalse);
    expect(tokens.isAccessExpired, isFalse);
  });

  test('results and fees parse the school payload', () {
    final report = ResultReport.fromApiBody({
      'success': true,
      'data': {
        'student': {
          'id': 4,
          'admission_number': 'R-100',
          'name': 'Amina Juma',
          'grade': 'Grade 4 Blue',
        },
        'available_years': ['2026'],
        'examinations': [
          {
            'key': 'exam-1',
            'title': 'Term 1 Assessment',
            'subtitle': 'Term 1 2026',
            'term': 'Term 1',
            'academic_year': '2026',
            'average': 80,
            'letter_grade': 'A',
            'position': 2,
            'class_size': 30,
            'subjects': [
              {'name': 'Mathematics', 'score': 80, 'grade': 'A'},
            ],
          },
        ],
      },
    });
    final fees = FeeStatement.fromApiBody({
      'data': {
        'student_id': 4,
        'academic_year': '2026',
        'currency': 'TZS',
        'yearly_fee': 100000,
        'discount': 0,
        'net_fee': 100000,
        'paid_amount': 30000,
        'balance': 70000,
        'payments_per_year': 4,
        'payments': [
          {
            'id': 9,
            'receipt_number': 'RCP-1',
            'amount': 30000,
            'paid_at': '2026-02-01',
          },
        ],
      },
    });

    expect(report.student.name, 'Amina Juma');
    expect(report.examinations.single.subjects.single.score, 80);
    expect(fees.balance, 70000);
    expect(fees.payments.single.receiptNumber, 'RCP-1');
    expect(fees.progress, closeTo(0.3, 0.001));
  });
}
