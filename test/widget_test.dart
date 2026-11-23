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

  Future<void> pumpApp(
    WidgetTester tester,
    List<FakeSource> sources, {
    Map<String, Object> savedPrefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues({
      'from': 'EUR',
      'to': 'USD',
      'amount': '100',
      ...savedPrefs,
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

  testWidgets('converts to a currency pegged to the euro', (tester) async {
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);

    await tester.tap(find.byKey(const Key('to-currency')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('currency-search')), 'cape');
    await tester.pumpAndSettle();
    expect(find.text('Cape Verdean escudo · fixed parity'), findsOneWidget);
    await tester.tap(find.text('CVE'));
    await tester.pumpAndSettle();

    expect(resultText(tester), '11,026.50 CVE');
    expect(
      find.text('CVE: fixed parity with the euro, 1 EUR = 110.265 CVE'),
      findsOneWidget,
    );
  });

  void setDeviceLocales(WidgetTester tester, List<Locale> locales) {
    tester.platformDispatcher.localesTestValue = locales;
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  }

  Future<void> pickLanguage(WidgetTester tester, String value) async {
    await tester.tap(find.byKey(const Key('language-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('language-$value')));
    await tester.pumpAndSettle();
  }

  testWidgets('follows the device language when it is translated',
      (tester) async {
    setDeviceLocales(tester, const [Locale('fr', 'FR')]);
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);

    expect(find.text('Montant'), findsOneWidget);
    expect(resultText(tester), '200,00 USD');
  });

  testWidgets('falls back to English for an untranslated device language',
      (tester) async {
    setDeviceLocales(tester, const [Locale('de', 'DE')]);
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);

    expect(find.text('Amount'), findsOneWidget);
  });

  testWidgets('switches language and remembers the choice', (tester) async {
    setDeviceLocales(tester, const [Locale('de', 'DE')]);
    await pumpApp(tester, [FakeSource('ecb', sampleDays())]);
    final prefs = await SharedPreferences.getInstance();

    await pickLanguage(tester, 'fr');
    expect(find.text('Montant'), findsOneWidget);
    expect(prefs.getString('language'), 'fr');

    await pickLanguage(tester, 'system');
    expect(find.text('Amount'), findsOneWidget);
    expect(prefs.getString('language'), isNull);
  });

  testWidgets('starts in the saved language', (tester) async {
    setDeviceLocales(tester, const [Locale('en', 'US')]);
    await pumpApp(
      tester,
      [FakeSource('ecb', sampleDays())],
      savedPrefs: {'language': 'fr'},
    );

    expect(find.text('Montant'), findsOneWidget);
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
