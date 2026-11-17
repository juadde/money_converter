import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

import '../data/config.dart';

/// Hand-written localizations (English and French).
class AppStrings {
  const AppStrings(this.localeName);

  /// `en` or `fr`; also used as the locale for number and date formats.
  final String localeName;

  static const supportedLocales = [Locale('en'), Locale('fr')];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  bool get _fr => localeName == 'fr';

  String get appTitle =>
      _fr ? 'Convertisseur de devises' : 'Currency converter';
  String get amount => _fr ? 'Montant' : 'Amount';
  String get result => _fr ? 'Résultat' : 'Result';
  String get swap => _fr ? 'Inverser les devises' : 'Swap currencies';
  String get refresh => _fr ? 'Actualiser' : 'Refresh';
  String get retry => _fr ? 'Réessayer' : 'Retry';
  String get chooseCurrency =>
      _fr ? 'Choisir une devise' : 'Choose a currency';
  String get search => _fr ? 'Rechercher' : 'Search';
  String get noCurrencyFound =>
      _fr ? 'Aucune devise trouvée' : 'No currency found';
  String get history => _fr ? 'Évolution' : 'History';
  String get oneWeek => _fr ? '1 sem.' : '1W';
  String get oneMonth => _fr ? '1 mois' : '1M';
  String get threeMonths => _fr ? '3 mois' : '3M';
  String get notEnoughHistory => _fr
      ? 'Pas assez de données pour tracer un graphique.'
      : 'Not enough data to draw a chart.';
  String get loadError => _fr
      ? 'Impossible de récupérer les taux de change.'
      : 'Could not load the exchange rates.';
  String get loadErrorHint => _fr
      ? 'Vérifiez votre connexion puis réessayez.'
      : 'Check your connection and try again.';
  String get offline => _fr
      ? 'Hors ligne : derniers taux enregistrés affichés.'
      : 'Offline: showing the last saved rates.';
  String get disclaimer => _fr
      ? 'Taux de référence de la Banque centrale européenne, publiés '
          'chaque jour ouvré vers 16 h (CET). Valeurs indicatives.'
      : 'European Central Bank reference rates, published every working '
          'day around 16:00 CET. For information only.';

  String ratesOf(String date) =>
      _fr ? 'Taux du $date' : 'Rates of $date';

  String sourceLabel(String origin) {
    switch (origin) {
      case ecbOrigin:
        return _fr ? 'Source : BCE (direct)' : 'Source: ECB (direct)';
      case githubOrigin:
        return _fr
            ? 'Source : BCE (copie GitHub)'
            : 'Source: ECB (GitHub copy)';
      default:
        return _fr ? 'Source : BCE' : 'Source: ECB';
    }
  }

  String currencyName(String code) =>
      (_fr ? _namesFr : _namesEn)[code] ?? code;

  static const _namesEn = <String, String>{
    'AUD': 'Australian dollar',
    'BGN': 'Bulgarian lev',
    'BRL': 'Brazilian real',
    'CAD': 'Canadian dollar',
    'CHF': 'Swiss franc',
    'CNY': 'Chinese yuan renminbi',
    'CZK': 'Czech koruna',
    'DKK': 'Danish krone',
    'EUR': 'Euro',
    'GBP': 'Pound sterling',
    'HKD': 'Hong Kong dollar',
    'HUF': 'Hungarian forint',
    'IDR': 'Indonesian rupiah',
    'ILS': 'Israeli shekel',
    'INR': 'Indian rupee',
    'ISK': 'Icelandic krona',
    'JPY': 'Japanese yen',
    'KRW': 'South Korean won',
    'MXN': 'Mexican peso',
    'MYR': 'Malaysian ringgit',
    'NOK': 'Norwegian krone',
    'NZD': 'New Zealand dollar',
    'PHP': 'Philippine peso',
    'PLN': 'Polish zloty',
    'RON': 'Romanian leu',
    'SEK': 'Swedish krona',
    'SGD': 'Singapore dollar',
    'THB': 'Thai baht',
    'TRY': 'Turkish lira',
    'USD': 'US dollar',
    'ZAR': 'South African rand',
  };

  static const _namesFr = <String, String>{
    'AUD': 'Dollar australien',
    'BGN': 'Lev bulgare',
    'BRL': 'Réal brésilien',
    'CAD': 'Dollar canadien',
    'CHF': 'Franc suisse',
    'CNY': 'Yuan renminbi chinois',
    'CZK': 'Couronne tchèque',
    'DKK': 'Couronne danoise',
    'EUR': 'Euro',
    'GBP': 'Livre sterling',
    'HKD': 'Dollar de Hong Kong',
    'HUF': 'Forint hongrois',
    'IDR': 'Roupie indonésienne',
    'ILS': 'Shekel israélien',
    'INR': 'Roupie indienne',
    'ISK': 'Couronne islandaise',
    'JPY': 'Yen japonais',
    'KRW': 'Won sud-coréen',
    'MXN': 'Peso mexicain',
    'MYR': 'Ringgit malaisien',
    'NOK': 'Couronne norvégienne',
    'NZD': 'Dollar néo-zélandais',
    'PHP': 'Peso philippin',
    'PLN': 'Zloty polonais',
    'RON': 'Leu roumain',
    'SEK': 'Couronne suédoise',
    'SGD': 'Dollar de Singapour',
    'THB': 'Baht thaïlandais',
    'TRY': 'Livre turque',
    'USD': 'Dollar américain',
    'ZAR': 'Rand sud-africain',
  };
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'fr';

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale.languageCode));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
