String formatTzs(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return 'TZS ${negative ? '-' : ''}$buffer';
}

String formatScore(double value) {
  if (value == value.roundToDouble()) return value.toInt().toString();
  return value.toStringAsFixed(1);
}

/// Whole numbers stay whole. Other values show one decimal place.
String formatPlainNumber(double value) {
  if (!value.isFinite) return '0';
  final rounded = (value * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.toInt().toString();
  return rounded.toStringAsFixed(1);
}

String stripAdmission(String value) {
  final cleaned = value.replaceAll(
    RegExp(r'\bADM[-/\s]*\d[\d/\-]*', caseSensitive: false),
    '',
  );
  return cleaned
      .replaceAll(RegExp(r'(?:\s*[•·]\s*){2,}'), ' • ')
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .replaceAll(RegExp(r'^[\s•·]+|[\s•·]+$'), '')
      .trim();
}

String formatLongDate(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  final date = DateTime.tryParse(iso)?.toLocal();
  if (date == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String titleCase(String? value) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '';
  return text
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
