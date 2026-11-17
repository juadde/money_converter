import 'dart:convert';

import '../models/rates.dart';

/// JSON layout shared by the GitHub fallback file and the local cache:
///
/// ```json
/// {"days": [{"date": "2026-11-13", "rates": {"USD": 1.08}}]}
/// ```

String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

List<DailyRates> daysFromJson(Object? json) {
  if (json is! List) throw const FormatException('"days" must be a list');
  final days = <DailyRates>[];
  for (final entry in json) {
    if (entry is! Map) continue;
    final date = DateTime.tryParse('${entry['date']}');
    final rawRates = entry['rates'];
    if (date == null || rawRates is! Map) continue;
    final rates = <String, double>{'EUR': 1.0};
    rawRates.forEach((key, value) {
      if (value is num && value > 0) rates['$key'] = value.toDouble();
    });
    if (rates.length > 1) days.add(DailyRates(date: date, rates: rates));
  }
  if (days.isEmpty) throw const FormatException('No rates in JSON');
  days.sort((a, b) => b.date.compareTo(a.date));
  return days;
}

List<Map<String, Object?>> daysToJson(List<DailyRates> days) => [
      for (final day in days)
        {'date': dateKey(day.date), 'rates': day.rates},
    ];

List<DailyRates> parseRatesJson(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! Map) throw const FormatException('Unexpected JSON root');
  return daysFromJson(decoded['days']);
}
