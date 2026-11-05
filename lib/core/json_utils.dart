int? readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double readDouble(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String? readOptionalString(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String readString(Object? value, {String fallback = ''}) {
  return readOptionalString(value) ?? fallback;
}

Map<String, dynamic>? readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic> readList(Object? value) {
  if (value is List) return value;
  return const [];
}

Map<String, dynamic> readEnvelope(Map<String, dynamic> body) {
  return readMap(body['data']) ?? body;
}
