// ignore_for_file: invalid_use_of_visible_for_testing_member

// Store screenshots, rendered by a widget test with the real fonts and the
// real ECB rates of the day.
//
//   python3 tool/ecb_to_json.py --output screenshots/rates.json
//   flutter test --update-goldens screenshots/
//
// Writes, per listing language, 4 phone screenshots (1080 x 1920) into
// fastlane/metadata/android/<locale>/images/phoneScreenshots/ and 3 desktop
// screenshots (1920 x 1080) for the Microsoft Store into
// store/windows/<locale>/screenshots/.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moneyconverter/app.dart';
import 'package:moneyconverter/data/rates_cache.dart';
import 'package:moneyconverter/data/rates_json.dart';
import 'package:moneyconverter/data/rates_repository.dart';
import 'package:moneyconverter/data/rates_source.dart';
import 'package:moneyconverter/l10n/app_strings.dart';
import 'package:moneyconverter/models/rates.dart';
import 'package:moneyconverter/state/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App language → Google Play listing language.
const playLocales = {
  'en': 'en-US',
  'fr': 'fr-FR',
  'de': 'de-DE',
  'es': 'es-ES',
  'it': 'it-IT',
  'pl': 'pl-PL',
  'ro': 'ro',
  'lt': 'lt',
};

class _StaticSource implements RatesSource {
  _StaticSource(this.days);

  final List<DailyRates> days;

  @override
  String get id => 'ecb';

  @override
  Future<List<DailyRates>> fetch() async => days;
}

/// Material fonts shipped with the Flutter SDK (Roboto and the icons): the
/// test default font draws every letter as a box.
Future<void> _loadFonts() async {
  final candidates = <String>[
    if (Platform.environment['FLUTTER_ROOT'] case final root?)
      '$root/bin/cache/artifacts/material_fonts',
    // flutter_tester lives in bin/cache/artifacts/engine/<platform>/.
    '${File(Platform.resolvedExecutable).parent.parent.parent.path}'
        '/material_fonts',
  ];
  final dir = candidates.map(Directory.new).firstWhere(
        (d) => d.existsSync(),
        orElse: () => throw StateError('Material fonts not found in $candidates'),
      );
  ByteData bytesOf(File f) => ByteData.sublistView(f.readAsBytesSync());

  final roboto = FontLoader('Roboto');
  final icons = FontLoader('MaterialIcons');
  for (final file in dir.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (name.startsWith('Roboto-') && name.endsWith('.ttf')) {
      roboto.addFont(Future.value(bytesOf(file)));
    } else if (name.startsWith('MaterialIcons')) {
      icons.addFont(Future.value(bytesOf(file)));
    }
  }
  await roboto.load();
  await icons.load();
}

void main() {
  late List<DailyRates> days;

  setUpAll(() async {
    await initializeDateFormatting();
    await _loadFonts();
    final file = File('screenshots/rates.json');
    if (!file.existsSync()) {
      throw StateError(
        'Run python3 tool/ecb_to_json.py --output screenshots/rates.json',
      );
    }
    days = parseRatesJson(file.readAsStringSync());
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle();
    // Let the SVG flags load from the assets.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    required String language,
    required String from,
    required String to,
    required String amount,
  }) async {
    SharedPreferences.setMockInitialValues({
      'from': from,
      'to': to,
      'amount': amount,
      'language': language,
    });
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          ratesRepositoryProvider.overrideWithValue(
            RatesRepository(
              sources: [_StaticSource(days)],
              cache: RatesCache(prefs),
            ),
          ),
        ],
        child: const MoneyConverterApp(),
      ),
    );
    await settle(tester);
  }

  Future<void> shoot(String locale, String name) => expectLater(
        find.byType(MoneyConverterApp),
        matchesGoldenFile(
          '../fastlane/metadata/android/$locale/images/phoneScreenshots/'
          '$name.png',
        ),
      );

  Future<void> shootWindows(String locale, String name) => expectLater(
        find.byType(MoneyConverterApp),
        matchesGoldenFile('../store/windows/$locale/screenshots/$name.png'),
      );

  for (final MapEntry(key: language, value: locale) in playLocales.entries) {
    testWidgets('windows screenshots $locale', (tester) async {
      // A 1920 x 1080 desktop window (the Store asks for 1366 x 768 or more).
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.25;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final strings = AppStrings(language);
      debugDisableShadows = false;
      try {
        await pumpApp(tester,
            language: language, from: 'EUR', to: 'AUD', amount: '100');
        await tester.tap(find.text(strings.threeMonths));
        await settle(tester);
        await shootWindows(locale, '1_converter');

        await pumpApp(tester,
            language: language, from: 'EUR', to: 'CVE', amount: '250');
        await shootWindows(locale, '2_fixed_parity');

        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.dark;
        await pumpApp(tester,
            language: language, from: 'USD', to: 'JPY', amount: '50');
        await shootWindows(locale, '3_dark');
      } finally {
        debugDisableShadows = true;
      }
    });

    testWidgets('screenshots $locale', (tester) async {
      // A 1080 x 1920 phone.
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final strings = AppStrings(language);
      debugDisableShadows = false;
      try {
        // 1. Converter with the 3-month chart.
        await pumpApp(tester,
            language: language, from: 'EUR', to: 'AUD', amount: '100');
        await tester.tap(find.text(strings.threeMonths));
        await settle(tester);
        await shoot(locale, '1_converter');

        // 2. Currency picker.
        await tester.tap(find.byKey(const Key('to-currency')));
        await settle(tester);
        await shoot(locale, '2_currencies');

        // 3. A currency pegged to the euro.
        await pumpApp(tester,
            language: language, from: 'EUR', to: 'CVE', amount: '250');
        await shoot(locale, '3_fixed_parity');

        // 4. Dark theme.
        tester.platformDispatcher.platformBrightnessTestValue =
            Brightness.dark;
        await pumpApp(tester,
            language: language, from: 'USD', to: 'JPY', amount: '50');
        await shoot(locale, '4_dark');
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}
