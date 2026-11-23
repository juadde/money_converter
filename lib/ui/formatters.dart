import 'package:intl/intl.dart' show DateFormat, NumberFormat;

String _fixed(double value, int digits, String locale) {
  final format = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = digits
    ..maximumFractionDigits = digits;
  return format.format(value);
}

/// A converted amount: always two decimals.
String formatAmount(double value, String locale) => _fixed(value, 2, locale);

/// An exchange rate: more decimals for small values.
String formatRate(double value, String locale) {
  final digits = value >= 100
      ? 2
      : value >= 1
          ? 4
          : value >= 0.01
              ? 5
              : 6;
  return _fixed(value, digits, locale);
}

/// A fixed parity, with all its significant decimals (110.265, 655.957).
String formatParity(double value, String locale) {
  final format = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = 5;
  return format.format(value);
}

/// A signed percentage such as `+1.25 %`.
String formatPercent(double value, String locale) {
  final sign = value > 0 ? '+' : '';
  return '$sign${_fixed(value, 2, locale)} %';
}

String formatDate(DateTime date, String locale) =>
    DateFormat.yMMMd(locale).format(date);

String formatShortDate(DateTime date, String locale) =>
    DateFormat.MMMd(locale).format(date);

/// Reads what the user typed, accepting both `,` and `.` as decimal mark.
double? parseAmount(String text) {
  final cleaned =
      text.replaceAll(RegExp(r'[\s  ]'), '').replaceAll(',', '.');
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return null;
  }
  return value;
}

/// Country whose flag stands for a currency: the first two letters of an
/// ISO 4217 code are the country code, EUR gives the EU flag. Null for the
/// currencies shared by several countries (CFA and CFP francs).
String? flagCountryOf(String currency) {
  if (currency == 'EUR') return 'EU';
  if (const {'XOF', 'XAF', 'XPF'}.contains(currency)) return null;
  if (!RegExp(r'^[A-Z]{2}').hasMatch(currency)) return null;
  return currency.substring(0, 2);
}
