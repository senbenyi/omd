int customerParseInt(dynamic value, {int def = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? def;
  return def;
}
