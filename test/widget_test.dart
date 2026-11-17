import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moneyconverter/app.dart';
import 'package:moneyconverter/data/rates_cache.dart';
import 'package:moneyconverter/data/rates_repository.dart';
import 'package:moneyconverter/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

void main() {
  setUpAll(() => initializeDateFormatting());

  Future<void> pumpApp(WidgetTester tester, List<FakeSource> sources) async {
    SharedPreferences.setMockInitialValues({
      'from': 'EUR',
      'to': 'USD',
      'amount': '100',
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ratesRepositoryProvider.overrideWithValue(
            RatesRepository(sources: sources, cache: RatesCache(prefs)),
          ),
        ],
        child: const MoneyConverterApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  String resultText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('result'))).data!;

  testWidgets('converts live while typing and swaps the pair', (tester) async {
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);

    expect(resultText(tester), '200.00 USD');

    await tester.enterText(find.byKey(const Key('amount')), '50');
    await tester.pump();
    expect(resultText(tester), '100.00 USD');

    await tester.enterText(find.byKey(const Key('amount')), '12,5');
    await tester.pump();
    expect(resultText(tester), '25.00 USD');

    await tester.tap(find.byKey(const Key('swap')));
    await tester.pump();
    expect(resultText(tester), '6.25 EUR');

    await tester.enterText(find.byKey(const Key('amount')), '');
    await tester.pump();
    expect(resultText(tester), '—');
  });

  testWidgets('lets the user pick any currency', (tester) async {
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);

    await tester.tap(find.byKey(const Key('to-currency')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('currency-search')), 'rand');
    await tester.pumpAndSettle();
    await tester.tap(find.text('ZAR'));
    await tester.pumpAndSettle();

    expect(resultText(tester), '2,000.00 ZAR');
  });

  testWidgets('shows an error with a retry button when nothing loads',
      (tester) async {
    final source = FakeSource('ecb', null);
    await pumpApp(tester, [source]);

    expect(find.text('Could not load the exchange rates.'), findsOneWidget);

    source.days = sampleDays();
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(resultText(tester), '200.00 USD');
  });
}
