import 'package:xml/xml.dart';

import '../models/rates.dart';

/// Parses the ECB `eurofxref` XML feeds (daily, 90 days or full history).
///
/// Returns the days newest first. Throws a [FormatException] when the
/// document holds no rate.
List<DailyRates> parseEcbXml(String body) {
  final XmlDocument document;
  try {
    document = XmlDocument.parse(body);
  } on XmlException catch (e) {
    throw FormatException('Invalid ECB XML: ${e.message}');
  }

  final days = <DailyRates>[];
  for (final cube in document.findAllElements('Cube')) {
    final time = cube.getAttribute('time');
    if (time == null) continue;
    final date = DateTime.tryParse(time);
    if (date == null) continue;

    final rates = <String, double>{'EUR': 1.0};
    for (final child in cube.children.whereType<XmlElement>()) {
      final currency = child.getAttribute('currency');
      final rate = double.tryParse(child.getAttribute('rate') ?? '');
      if (currency != null && rate != null && rate > 0) {
        rates[currency] = rate;
      }
    }
    if (rates.length > 1) days.add(DailyRates(date: date, rates: rates));
  }

  if (days.isEmpty) throw const FormatException('No rates in ECB XML');
  days.sort((a, b) => b.date.compareTo(a.date));
  return days;
}
