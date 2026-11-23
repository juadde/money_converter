import 'package:flutter_test/flutter_test.dart';
import 'package:moneyconverter/models/euro_pegs.dart';
import 'package:moneyconverter/models/rates.dart';
import 'package:moneyconverter/ui/formatters.dart';

import 'support.dart';

void main() {
  final snapshot = RatesSnapshot(
    days: sampleDays(),
    origin: 'test',
    fetchedAt: DateTime(2026, 11, 14),
  );

  test('pegged currencies convert at their fixed parity with the euro', () {
    final day = snapshot.latest;
    expect(day.rate('EUR', 'CVE'), 110.265);
    expect(day.rate('CVE', 'EUR'), closeTo(1 / 110.265, 1e-15));
    expect(day.rate('EUR', 'XOF'), 655.957);
    expect(day.rate('XOF', 'XAF'), 1.0);
    expect(day.rate('EUR', 'XPF'), closeTo(119.33174, 1e-5));
  });

  test('pegged currencies cross through the ECB rates of the day', () {
    // sampleDays: 1 EUR = 2 USD on the latest day, 1.8 USD two days before.
    expect(snapshot.latest.rate('CVE', 'USD'), closeTo(2 / 110.265, 1e-15));
    final history = snapshot.history('USD', 'CVE');
    expect([for (final p in history) p.value], [
      closeTo(110.265 / 1.8, 1e-9),
      closeTo(110.265 / 1.9, 1e-9),
      closeTo(110.265 / 2.0, 1e-9),
    ]);
  });

  test('pegged currencies are listed with the ECB ones', () {
    expect(snapshot.currencies, containsAll(euroPegs.keys));
    expect(snapshot.currencies, containsAll(['EUR', 'USD', 'ZAR']));
    expect(snapshot.currencies, orderedEquals([...snapshot.currencies]..sort()));
  });

  test('an ECB rate wins over a fixed parity', () {
    final day = DailyRates(
      date: DateTime(2026, 11, 13),
      rates: const {'EUR': 1.0, 'BAM': 2.0},
    );
    expect(day.rate('EUR', 'BAM'), 2.0);
  });

  test('parity and flag formatting', () {
    expect(formatParity(110.265, 'fr'), '110,265');
    expect(formatParity(491.96775, 'en'), '491.96775');
    expect(formatParity(24.5, 'en'), '24.5');
    expect(flagCountryOf('XOF'), isNull);
    expect(flagCountryOf('CVE'), 'CV');
  });
}
