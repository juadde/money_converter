import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:moneyconverter/data/ecb_parser.dart';
import 'package:moneyconverter/data/rates_json.dart';
import 'package:moneyconverter/models/rates.dart';
import 'package:moneyconverter/ui/formatters.dart';

void main() {
  final xml = File('test/fixtures/eurofxref-hist-sample.xml').readAsStringSync();

  group('parseEcbXml', () {
    test('reads every day, newest first, and adds EUR', () {
      final days = parseEcbXml(xml);
      expect(days, hasLength(3));
      expect(dateKey(days.first.date), '2026-11-13');
      expect(dateKey(days.last.date), '2026-11-11');
      expect(days.first.rates['USD'], 1.2);
      expect(days.first.rates['EUR'], 1.0);
      expect(days.first.rates.keys, containsAll(['EUR', 'USD', 'JPY', 'ZAR']));
    });

    test('rejects documents without rates', () {
      expect(() => parseEcbXml('<a/>'), throwsFormatException);
      expect(() => parseEcbXml('not xml'), throwsFormatException);
    });
  });

  group('JSON', () {
    test('round-trips the parsed days', () {
      final days = parseEcbXml(xml);
      final body = jsonEncode({'days': daysToJson(days)});
      final back = parseRatesJson(body);
      expect(back, hasLength(3));
      expect(dateKey(back.first.date), '2026-11-13');
      expect(back.first.rates, days.first.rates);
    });

    test('rejects an empty file', () {
      expect(() => parseRatesJson('{"days": []}'), throwsFormatException);
      expect(() => parseRatesJson('[]'), throwsFormatException);
    });
  });

  group('rates', () {
    final snapshot = RatesSnapshot(
      days: parseEcbXml(xml),
      origin: 'test',
      fetchedAt: DateTime(2026, 11, 14),
    );

    test('converts through the euro', () {
      final day = snapshot.latest;
      expect(day.rate('EUR', 'USD'), closeTo(1.2, 1e-12));
      expect(day.rate('USD', 'EUR'), closeTo(1 / 1.2, 1e-12));
      expect(day.rate('ZAR', 'USD'), closeTo(0.06, 1e-12));
      expect(day.rate('USD', 'USD'), 1.0);
      expect(day.rate('USD', 'XXX'), isNull);
    });

    test('lists currencies sorted, with the euro-pegged ones', () {
      expect(snapshot.currencies, [
        'BAM', 'CVE', 'EUR', 'JPY', 'KMF', 'STN', //
        'USD', 'XAF', 'XOF', 'XPF', 'ZAR',
      ]);
    });

    test('builds the history oldest first', () {
      final all = snapshot.history('EUR', 'USD');
      expect([for (final p in all) p.value], [1.0, 1.1, 1.2]);
      final lastDay = snapshot.history('EUR', 'USD', maxDays: 1);
      expect([for (final p in lastDay) p.value], [1.1, 1.2]);
    });
  });

  group('formatters', () {
    test('parseAmount accepts comma and dot', () {
      expect(parseAmount('12,5'), 12.5);
      expect(parseAmount('12.5'), 12.5);
      expect(parseAmount('1 000'), 1000);
      expect(parseAmount(''), isNull);
      expect(parseAmount('1,2,3'), isNull);
    });

    test('formats amounts and rates per locale', () {
      expect(formatAmount(1234.5, 'en'), '1,234.50');
      expect(formatAmount(0.5, 'fr'), '0,50');
      expect(formatRate(0.051234, 'en'), '0.05123');
      expect(formatRate(1.23456, 'en'), '1.2346');
      expect(formatPercent(1.5, 'en'), '+1.50 %');
    });

    test('flagOf builds regional indicator pairs', () {
      expect(flagOf('EUR'), '\u{1F1EA}\u{1F1FA}');
      expect(flagOf('1'), '');
    });
  });
}
