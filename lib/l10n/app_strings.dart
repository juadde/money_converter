import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

import '../data/config.dart';

/// Hand-written localizations: English, French, German and Spanish.
class AppStrings {
  const AppStrings(this.localeName);

  /// Language code (`en`, `fr`, `de`, `es`); also the locale for number and
  /// date formats.
  final String localeName;

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('de'),
    Locale('es'),
  ];

  /// Each language is named in itself, so it can be found whatever the
  /// current language.
  static const languageNames = {
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
  };

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) =>
      Localizations.of<AppStrings>(context, AppStrings)!;

  static bool isSupported(String languageCode) =>
      supportedLocales.any((locale) => locale.languageCode == languageCode);

  /// Picks the first device language that has a translation, else English.
  static Locale resolve(List<Locale>? deviceLocales) {
    for (final device in deviceLocales ?? const <Locale>[]) {
      if (isSupported(device.languageCode)) return Locale(device.languageCode);
    }
    return const Locale('en');
  }

  String _t({
    required String en,
    required String fr,
    required String de,
    required String es,
  }) =>
      switch (localeName) {
        'fr' => fr,
        'de' => de,
        'es' => es,
        _ => en,
      };

  String get appTitle => _t(
        en: 'Currency converter',
        fr: 'Convertisseur de devises',
        de: 'Währungsrechner',
        es: 'Conversor de divisas',
      );
  String get amount => _t(
        en: 'Amount',
        fr: 'Montant',
        de: 'Betrag',
        es: 'Importe',
      );
  String get result => _t(
        en: 'Result',
        fr: 'Résultat',
        de: 'Ergebnis',
        es: 'Resultado',
      );
  String get swap => _t(
        en: 'Swap currencies',
        fr: 'Inverser les devises',
        de: 'Währungen tauschen',
        es: 'Intercambiar divisas',
      );
  String get refresh => _t(
        en: 'Refresh',
        fr: 'Actualiser',
        de: 'Aktualisieren',
        es: 'Actualizar',
      );
  String get retry => _t(
        en: 'Retry',
        fr: 'Réessayer',
        de: 'Erneut versuchen',
        es: 'Reintentar',
      );
  String get chooseCurrency => _t(
        en: 'Choose a currency',
        fr: 'Choisir une devise',
        de: 'Währung wählen',
        es: 'Elegir una divisa',
      );
  String get search => _t(
        en: 'Search',
        fr: 'Rechercher',
        de: 'Suchen',
        es: 'Buscar',
      );
  String get noCurrencyFound => _t(
        en: 'No currency found',
        fr: 'Aucune devise trouvée',
        de: 'Keine Währung gefunden',
        es: 'No se encontró ninguna divisa',
      );
  String get history => _t(
        en: 'History',
        fr: 'Évolution',
        de: 'Verlauf',
        es: 'Evolución',
      );
  String get oneWeek => _t(
        en: '1W',
        fr: '1 sem.',
        de: '1 W.',
        es: '1 sem.',
      );
  String get oneMonth => _t(
        en: '1M',
        fr: '1 mois',
        de: '1 M.',
        es: '1 mes',
      );
  String get threeMonths => _t(
        en: '3M',
        fr: '3 mois',
        de: '3 M.',
        es: '3 meses',
      );
  String get notEnoughHistory => _t(
        en: 'Not enough data to draw a chart.',
        fr: 'Pas assez de données pour tracer un graphique.',
        de: 'Nicht genug Daten für ein Diagramm.',
        es: 'No hay suficientes datos para dibujar un gráfico.',
      );
  String get loadError => _t(
        en: 'Could not load the exchange rates.',
        fr: 'Impossible de récupérer les taux de change.',
        de: 'Die Wechselkurse konnten nicht geladen werden.',
        es: 'No se pudieron cargar los tipos de cambio.',
      );
  String get loadErrorHint => _t(
        en: 'Check your connection and try again.',
        fr: 'Vérifiez votre connexion puis réessayez.',
        de: 'Prüfe deine Verbindung und versuche es erneut.',
        es: 'Comprueba tu conexión e inténtalo de nuevo.',
      );
  String get offline => _t(
        en: 'Offline: showing the last saved rates.',
        fr: 'Hors ligne : derniers taux enregistrés affichés.',
        de: 'Offline: Die zuletzt gespeicherten Kurse werden angezeigt.',
        es: 'Sin conexión: se muestran los últimos tipos guardados.',
      );
  String get disclaimer => _t(
        en: 'European Central Bank reference rates, published every working day around 16:00 CET. For information only.',
        fr: 'Taux de référence de la Banque centrale européenne, publiés chaque jour ouvré vers 16 h (CET). Valeurs indicatives.',
        de: 'Referenzkurse der Europäischen Zentralbank, veröffentlicht an jedem Arbeitstag gegen 16:00 Uhr MEZ. Nur zur Information.',
        es: 'Tipos de referencia del Banco Central Europeo, publicados cada día hábil hacia las 16:00 (CET). Valores orientativos.',
      );
  String get language => _t(
        en: 'Language',
        fr: 'Langue',
        de: 'Sprache',
        es: 'Idioma',
      );
  String get deviceLanguage => _t(
        en: 'Device language',
        fr: 'Langue de l\'appareil',
        de: 'Gerätesprache',
        es: 'Idioma del dispositivo',
      );
  String get fixedParity => _t(
        en: 'fixed parity',
        fr: 'parité fixe',
        de: 'fester Kurs',
        es: 'paridad fija',
      );

  /// For example "CVE : parité fixe avec l'euro, 1 EUR = 110,265 CVE".
  String parityNote(String code, String perEuro) => _t(
        en: '$code: fixed parity with the euro, 1 EUR = $perEuro $code',
        fr: '$code : parité fixe avec l\'euro, 1 EUR = $perEuro $code',
        de: '$code: fester Kurs zum Euro, 1 EUR = $perEuro $code',
        es: '$code: paridad fija con el euro, 1 EUR = $perEuro $code',
      );

  String ratesOf(String date) => _t(
        en: 'Rates of $date',
        fr: 'Taux du $date',
        de: 'Kurse vom $date',
        es: 'Tipos del $date',
      );

  String sourceLabel(String origin) {
    switch (origin) {
      case ecbOrigin:
        return _t(
          en: 'Source: ECB (direct)',
          fr: 'Source : BCE (direct)',
          de: 'Quelle: EZB (direkt)',
          es: 'Fuente: BCE (directo)',
        );
      case githubOrigin:
        return _t(
          en: 'Source: ECB (GitHub copy)',
          fr: 'Source : BCE (copie GitHub)',
          de: 'Quelle: EZB (GitHub-Kopie)',
          es: 'Fuente: BCE (copia en GitHub)',
        );
      default:
        return _t(
          en: 'Source: ECB',
          fr: 'Source : BCE',
          de: 'Quelle: EZB',
          es: 'Fuente: BCE',
        );
    }
  }

  String currencyName(String code) {
    final names = switch (localeName) {
      'fr' => _namesFr,
      'de' => _namesDe,
      'es' => _namesEs,
      _ => _namesEn,
    };
    return names[code] ?? code;
  }

  static const _namesEn = <String, String>{
    'AUD': 'Australian dollar',
    'BAM': 'Bosnia-Herzegovina convertible mark',
    'BGN': 'Bulgarian lev',
    'BRL': 'Brazilian real',
    'CAD': 'Canadian dollar',
    'CHF': 'Swiss franc',
    'CNY': 'Chinese yuan renminbi',
    'CVE': 'Cape Verdean escudo',
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
    'KMF': 'Comorian franc',
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
    'STN': 'São Tomé and Príncipe dobra',
    'THB': 'Thai baht',
    'TRY': 'Turkish lira',
    'USD': 'US dollar',
    'XAF': 'Central African CFA franc',
    'XOF': 'West African CFA franc',
    'XPF': 'CFP franc',
    'ZAR': 'South African rand',
  };

  static const _namesFr = <String, String>{
    'AUD': 'Dollar australien',
    'BAM': 'Mark convertible bosnien',
    'BGN': 'Lev bulgare',
    'BRL': 'Réal brésilien',
    'CAD': 'Dollar canadien',
    'CHF': 'Franc suisse',
    'CNY': 'Yuan renminbi chinois',
    'CVE': 'Escudo cap-verdien',
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
    'KMF': 'Franc comorien',
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
    'STN': 'Dobra de Sao Tomé-et-Principe',
    'THB': 'Baht thaïlandais',
    'TRY': 'Livre turque',
    'USD': 'Dollar américain',
    'XAF': 'Franc CFA (CEMAC)',
    'XOF': 'Franc CFA (UEMOA)',
    'XPF': 'Franc pacifique',
    'ZAR': 'Rand sud-africain',
  };

  static const _namesDe = <String, String>{
    'AUD': 'Australischer Dollar',
    'BAM': 'Konvertible Mark (Bosnien und Herzegowina)',
    'BGN': 'Bulgarischer Lew',
    'BRL': 'Brasilianischer Real',
    'CAD': 'Kanadischer Dollar',
    'CHF': 'Schweizer Franken',
    'CNY': 'Chinesischer Renminbi Yuan',
    'CVE': 'Kap-Verde-Escudo',
    'CZK': 'Tschechische Krone',
    'DKK': 'Dänische Krone',
    'EUR': 'Euro',
    'GBP': 'Pfund Sterling',
    'HKD': 'Hongkong-Dollar',
    'HUF': 'Ungarischer Forint',
    'IDR': 'Indonesische Rupiah',
    'ILS': 'Israelischer Schekel',
    'INR': 'Indische Rupie',
    'ISK': 'Isländische Krone',
    'JPY': 'Japanischer Yen',
    'KMF': 'Komoren-Franc',
    'KRW': 'Südkoreanischer Won',
    'MXN': 'Mexikanischer Peso',
    'MYR': 'Malaysischer Ringgit',
    'NOK': 'Norwegische Krone',
    'NZD': 'Neuseeland-Dollar',
    'PHP': 'Philippinischer Peso',
    'PLN': 'Polnischer Złoty',
    'RON': 'Rumänischer Leu',
    'SEK': 'Schwedische Krone',
    'SGD': 'Singapur-Dollar',
    'STN': 'São-toméischer Dobra',
    'THB': 'Thailändischer Baht',
    'TRY': 'Türkische Lira',
    'USD': 'US-Dollar',
    'XAF': 'CFA-Franc (BEAC)',
    'XOF': 'CFA-Franc (BCEAO)',
    'XPF': 'CFP-Franc',
    'ZAR': 'Südafrikanischer Rand',
  };

  static const _namesEs = <String, String>{
    'AUD': 'Dólar australiano',
    'BAM': 'Marco convertible de Bosnia y Herzegovina',
    'BGN': 'Lev búlgaro',
    'BRL': 'Real brasileño',
    'CAD': 'Dólar canadiense',
    'CHF': 'Franco suizo',
    'CNY': 'Yuan renminbi chino',
    'CVE': 'Escudo caboverdiano',
    'CZK': 'Corona checa',
    'DKK': 'Corona danesa',
    'EUR': 'Euro',
    'GBP': 'Libra esterlina',
    'HKD': 'Dólar de Hong Kong',
    'HUF': 'Forinto húngaro',
    'IDR': 'Rupia indonesia',
    'ILS': 'Séquel israelí',
    'INR': 'Rupia india',
    'ISK': 'Corona islandesa',
    'JPY': 'Yen japonés',
    'KMF': 'Franco comorense',
    'KRW': 'Won surcoreano',
    'MXN': 'Peso mexicano',
    'MYR': 'Ringit malasio',
    'NOK': 'Corona noruega',
    'NZD': 'Dólar neozelandés',
    'PHP': 'Peso filipino',
    'PLN': 'Esloti polaco',
    'RON': 'Leu rumano',
    'SEK': 'Corona sueca',
    'SGD': 'Dólar de Singapur',
    'STN': 'Dobra santotomense',
    'THB': 'Baht tailandés',
    'TRY': 'Lira turca',
    'USD': 'Dólar estadounidense',
    'XAF': 'Franco CFA (BEAC)',
    'XOF': 'Franco CFA (BCEAO)',
    'XPF': 'Franco CFP',
    'ZAR': 'Rand sudafricano',
  };
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.isSupported(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture<AppStrings>(AppStrings(locale.languageCode));

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
