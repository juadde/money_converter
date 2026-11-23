import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/config.dart';
import '../data/rates_cache.dart';
import '../data/rates_repository.dart';
import '../l10n/app_strings.dart';
import '../models/rates.dart';

/// Overridden in `main()` with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not set'),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final ratesRepositoryProvider = Provider<RatesRepository>((ref) {
  return RatesRepository(
    sources: defaultSources(ref.watch(httpClientProvider)),
    cache: RatesCache(ref.watch(sharedPreferencesProvider)),
  );
});

final ratesProvider =
    AsyncNotifierProvider<RatesController, RatesSnapshot>(RatesController.new);

class RatesController extends AsyncNotifier<RatesSnapshot> {
  @override
  Future<RatesSnapshot> build() => ref.watch(ratesRepositoryProvider).load();

  /// Forces a download, keeping what is on screen if it fails.
  Future<void> refresh() async {
    final previous = state.valueOrNull;
    if (previous == null) state = const AsyncLoading();
    try {
      final snapshot =
          await ref.read(ratesRepositoryProvider).load(forceRefresh: true);
      state = AsyncData(snapshot);
    } catch (e, stack) {
      if (previous == null) state = AsyncError(e, stack);
    }
  }
}

class ConverterState {
  const ConverterState({
    required this.from,
    required this.to,
    required this.amountText,
  });

  final String from;
  final String to;
  final String amountText;

  ConverterState copyWith({String? from, String? to, String? amountText}) =>
      ConverterState(
        from: from ?? this.from,
        to: to ?? this.to,
        amountText: amountText ?? this.amountText,
      );
}

final converterProvider =
    NotifierProvider<ConverterController, ConverterState>(
  ConverterController.new,
);

/// Selected pair and typed amount, remembered between launches.
class ConverterController extends Notifier<ConverterState> {
  static const _fromKey = 'from';
  static const _toKey = 'to';
  static const _amountKey = 'amount';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  ConverterState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return ConverterState(
      from: prefs.getString(_fromKey) ?? 'EUR',
      to: prefs.getString(_toKey) ?? 'AUD',
      amountText: prefs.getString(_amountKey) ?? '100',
    );
  }

  void setAmount(String text) {
    state = state.copyWith(amountText: text);
    _prefs.setString(_amountKey, text);
  }

  void setFrom(String code) {
    if (code == state.to) return swap();
    _setPair(code, state.to);
  }

  void setTo(String code) {
    if (code == state.from) return swap();
    _setPair(state.from, code);
  }

  void swap() => _setPair(state.to, state.from);

  void _setPair(String from, String to) {
    state = state.copyWith(from: from, to: to);
    _prefs.setString(_fromKey, from);
    _prefs.setString(_toKey, to);
  }
}

/// Language chosen in the app: null follows the device (English when the
/// device language has no translation).
final languageProvider =
    NotifierProvider<LanguageController, Locale?>(LanguageController.new);

class LanguageController extends Notifier<Locale?> {
  static const _key = 'language';

  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_key);
    return code != null && AppStrings.isSupported(code) ? Locale(code) : null;
  }

  /// [locale] null means "device language".
  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}
