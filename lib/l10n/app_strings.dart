import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/widgets.dart';

import '../data/config.dart';

/// Hand-written localizations: English, French, German, Spanish, Italian,
/// Polish, Romanian and Lithuanian.
class AppStrings {
  const AppStrings(this.localeName);

  /// Language code (see [supportedLocales]); also the locale for number and
  /// date formats.
  final String localeName;

  static const supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('de'),
    Locale('es'),
    Locale('it'),
    Locale('pl'),
    Locale('ro'),
    Locale('lt'),
  ];

  /// Each language is named in itself, so it can be found whatever the
  /// current language.
  static const languageNames = {
    'en': 'English',
    'fr': 'Français',
    'de': 'Deutsch',
    'es': 'Español',
    'it': 'Italiano',
    'pl': 'Polski',
    'ro': 'Română',
    'lt': 'Lietuvių',
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
    required String it,
    required String pl,
    required String ro,
    required String lt,
  }) =>
      switch (localeName) {
        'fr' => fr,
        'de' => de,
        'es' => es,
        'it' => it,
        'pl' => pl,
        'ro' => ro,
        'lt' => lt,
        _ => en,
      };

  String get appTitle => _t(
        en: 'Currency converter',
        fr: 'Convertisseur de devises',
        de: 'Währungsrechner',
        es: 'Conversor de divisas',
        it: 'Convertitore di valute',
        pl: 'Przelicznik walut',
        ro: 'Convertor valutar',
        lt: 'Valiutų keitiklis',
      );
  String get amount => _t(
        en: 'Amount',
        fr: 'Montant',
        de: 'Betrag',
        es: 'Importe',
        it: 'Importo',
        pl: 'Kwota',
        ro: 'Sumă',
        lt: 'Suma',
      );
  String get result => _t(
        en: 'Result',
        fr: 'Résultat',
        de: 'Ergebnis',
        es: 'Resultado',
        it: 'Risultato',
        pl: 'Wynik',
        ro: 'Rezultat',
        lt: 'Rezultatas',
      );
  String get swap => _t(
        en: 'Swap currencies',
        fr: 'Inverser les devises',
        de: 'Währungen tauschen',
        es: 'Intercambiar divisas',
        it: 'Inverti le valute',
        pl: 'Zamień waluty',
        ro: 'Inversează valutele',
        lt: 'Sukeisti valiutas',
      );
  String get refresh => _t(
        en: 'Refresh',
        fr: 'Actualiser',
        de: 'Aktualisieren',
        es: 'Actualizar',
        it: 'Aggiorna',
        pl: 'Odśwież',
        ro: 'Actualizează',
        lt: 'Atnaujinti',
      );
  String get retry => _t(
        en: 'Retry',
        fr: 'Réessayer',
        de: 'Erneut versuchen',
        es: 'Reintentar',
        it: 'Riprova',
        pl: 'Spróbuj ponownie',
        ro: 'Reîncearcă',
        lt: 'Bandyti dar kartą',
      );
  String get chooseCurrency => _t(
        en: 'Choose a currency',
        fr: 'Choisir une devise',
        de: 'Währung wählen',
        es: 'Elegir una divisa',
        it: 'Scegli una valuta',
        pl: 'Wybierz walutę',
        ro: 'Alege o valută',
        lt: 'Pasirinkite valiutą',
      );
  String get search => _t(
        en: 'Search',
        fr: 'Rechercher',
        de: 'Suchen',
        es: 'Buscar',
        it: 'Cerca',
        pl: 'Szukaj',
        ro: 'Caută',
        lt: 'Ieškoti',
      );
  String get noCurrencyFound => _t(
        en: 'No currency found',
        fr: 'Aucune devise trouvée',
        de: 'Keine Währung gefunden',
        es: 'No se encontró ninguna divisa',
        it: 'Nessuna valuta trovata',
        pl: 'Nie znaleziono waluty',
        ro: 'Nicio valută găsită',
        lt: 'Valiuta nerasta',
      );
  String get history => _t(
        en: 'History',
        fr: 'Évolution',
        de: 'Verlauf',
        es: 'Evolución',
        it: 'Andamento',
        pl: 'Historia',
        ro: 'Evoluție',
        lt: 'Kitimas',
      );
  String get oneWeek => _t(
        en: '1W',
        fr: '1 sem.',
        de: '1 W.',
        es: '1 sem.',
        it: '1 sett.',
        pl: '1 tydz.',
        ro: '1 săpt.',
        lt: '1 sav.',
      );
  String get oneMonth => _t(
        en: '1M',
        fr: '1 mois',
        de: '1 M.',
        es: '1 mes',
        it: '1 mese',
        pl: '1 mies.',
        ro: '1 lună',
        lt: '1 mėn.',
      );
  String get threeMonths => _t(
        en: '3M',
        fr: '3 mois',
        de: '3 M.',
        es: '3 meses',
        it: '3 mesi',
        pl: '3 mies.',
        ro: '3 luni',
        lt: '3 mėn.',
      );
  String get notEnoughHistory => _t(
        en: 'Not enough data to draw a chart.',
        fr: 'Pas assez de données pour tracer un graphique.',
        de: 'Nicht genug Daten für ein Diagramm.',
        es: 'No hay suficientes datos para dibujar un gráfico.',
        it: 'Dati insufficienti per tracciare un grafico.',
        pl: 'Za mało danych, aby narysować wykres.',
        ro: 'Nu sunt suficiente date pentru a desena un grafic.',
        lt: 'Nepakanka duomenų grafikui nubraižyti.',
      );
  String get loadError => _t(
        en: 'Could not load the exchange rates.',
        fr: 'Impossible de récupérer les taux de change.',
        de: 'Die Wechselkurse konnten nicht geladen werden.',
        es: 'No se pudieron cargar los tipos de cambio.',
        it: 'Impossibile caricare i tassi di cambio.',
        pl: 'Nie udało się pobrać kursów walut.',
        ro: 'Cursurile de schimb nu au putut fi încărcate.',
        lt: 'Nepavyko įkelti valiutų kursų.',
      );
  String get loadErrorHint => _t(
        en: 'Check your connection and try again.',
        fr: 'Vérifiez votre connexion puis réessayez.',
        de: 'Prüfe deine Verbindung und versuche es erneut.',
        es: 'Comprueba tu conexión e inténtalo de nuevo.',
        it: 'Controlla la connessione e riprova.',
        pl: 'Sprawdź połączenie i spróbuj ponownie.',
        ro: 'Verifică conexiunea și încearcă din nou.',
        lt: 'Patikrinkite ryšį ir bandykite dar kartą.',
      );
  String get offline => _t(
        en: 'Offline: showing the last saved rates.',
        fr: 'Hors ligne : derniers taux enregistrés affichés.',
        de: 'Offline: Die zuletzt gespeicherten Kurse werden angezeigt.',
        es: 'Sin conexión: se muestran los últimos tipos guardados.',
        it: 'Offline: vengono mostrati gli ultimi tassi salvati.',
        pl: 'Offline: wyświetlane są ostatnio zapisane kursy.',
        ro: 'Offline: sunt afișate ultimele cursuri salvate.',
        lt: 'Neprisijungta: rodomi paskutiniai išsaugoti kursai.',
      );
  String get disclaimer => _t(
        en: 'European Central Bank reference rates, published every working day around 16:00 CET. For information only.',
        fr: 'Taux de référence de la Banque centrale européenne, publiés chaque jour ouvré vers 16 h (CET). Valeurs indicatives.',
        de: 'Referenzkurse der Europäischen Zentralbank, veröffentlicht an jedem Arbeitstag gegen 16:00 Uhr MEZ. Nur zur Information.',
        es: 'Tipos de referencia del Banco Central Europeo, publicados cada día hábil hacia las 16:00 (CET). Valores orientativos.',
        it: 'Tassi di riferimento della Banca centrale europea, pubblicati ogni giorno lavorativo verso le 16:00 (CET). Valori indicativi.',
        pl: 'Kursy referencyjne Europejskiego Banku Centralnego, publikowane w każdy dzień roboczy około 16:00 CET. Wartości orientacyjne.',
        ro: 'Cursuri de referință ale Băncii Centrale Europene, publicate în fiecare zi lucrătoare în jurul orei 16:00 CET. Valori orientative.',
        lt: 'Europos Centrinio Banko orientaciniai kursai, skelbiami kiekvieną darbo dieną apie 16:00 CET. Informacinio pobūdžio.',
      );
  String get language => _t(
        en: 'Language',
        fr: 'Langue',
        de: 'Sprache',
        es: 'Idioma',
        it: 'Lingua',
        pl: 'Język',
        ro: 'Limbă',
        lt: 'Kalba',
      );
  String get deviceLanguage => _t(
        en: 'Device language',
        fr: 'Langue de l\'appareil',
        de: 'Gerätesprache',
        es: 'Idioma del dispositivo',
        it: 'Lingua del dispositivo',
        pl: 'Język urządzenia',
        ro: 'Limba dispozitivului',
        lt: 'Įrenginio kalba',
      );
  String get fixedParity => _t(
        en: 'fixed parity',
        fr: 'parité fixe',
        de: 'fester Kurs',
        es: 'paridad fija',
        it: 'parità fissa',
        pl: 'stały kurs',
        ro: 'paritate fixă',
        lt: 'fiksuotas kursas',
      );

  /// For example "CVE : parité fixe avec l'euro, 1 EUR = 110,265 CVE".
  String parityNote(String code, String perEuro) => _t(
        en: '$code: fixed parity with the euro, 1 EUR = $perEuro $code',
        fr: '$code : parité fixe avec l\'euro, 1 EUR = $perEuro $code',
        de: '$code: fester Kurs zum Euro, 1 EUR = $perEuro $code',
        es: '$code: paridad fija con el euro, 1 EUR = $perEuro $code',
        it: '$code: parità fissa con l\'euro, 1 EUR = $perEuro $code',
        pl: '$code: stały kurs wobec euro, 1 EUR = $perEuro $code',
        ro: '$code: paritate fixă cu euro, 1 EUR = $perEuro $code',
        lt: '$code: fiksuotas kursas euro atžvilgiu, 1 EUR = $perEuro $code',
      );

  String ratesOf(String date) => _t(
        en: 'Rates of $date',
        fr: 'Taux du $date',
        de: 'Kurse vom $date',
        es: 'Tipos del $date',
        it: 'Tassi del $date',
        pl: 'Kursy z dnia $date',
        ro: 'Cursurile din $date',
        lt: '$date kursai',
      );

  String sourceLabel(String origin) {
    switch (origin) {
      case ecbOrigin:
        return _t(
          en: 'Source: ECB (direct)',
          fr: 'Source : BCE (direct)',
          de: 'Quelle: EZB (direkt)',
          es: 'Fuente: BCE (directo)',
          it: 'Fonte: BCE (diretta)',
          pl: 'Źródło: EBC (bezpośrednio)',
          ro: 'Sursă: BCE (direct)',
          lt: 'Šaltinis: ECB (tiesiogiai)',
        );
      case githubOrigin:
        return _t(
          en: 'Source: ECB (GitHub copy)',
          fr: 'Source : BCE (copie GitHub)',
          de: 'Quelle: EZB (GitHub-Kopie)',
          es: 'Fuente: BCE (copia en GitHub)',
          it: 'Fonte: BCE (copia GitHub)',
          pl: 'Źródło: EBC (kopia w GitHub)',
          ro: 'Sursă: BCE (copie GitHub)',
          lt: 'Šaltinis: ECB (GitHub kopija)',
        );
      default:
        return _t(
          en: 'Source: ECB',
          fr: 'Source : BCE',
          de: 'Quelle: EZB',
          es: 'Fuente: BCE',
          it: 'Fonte: BCE',
          pl: 'Źródło: EBC',
          ro: 'Sursă: BCE',
          lt: 'Šaltinis: ECB',
        );
    }
  }

  String currencyName(String code) {
    final names = switch (localeName) {
      'fr' => _namesFr,
      'de' => _namesDe,
      'es' => _namesEs,
      'it' => _namesIt,
      'pl' => _namesPl,
      'ro' => _namesRo,
      'lt' => _namesLt,
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

  static const _namesIt = <String, String>{
    'AUD': 'Dollaro australiano',
    'BAM': 'Marco convertibile bosniaco',
    'BGN': 'Lev bulgaro',
    'BRL': 'Real brasiliano',
    'CAD': 'Dollaro canadese',
    'CHF': 'Franco svizzero',
    'CNY': 'Renminbi cinese',
    'CVE': 'Escudo capoverdiano',
    'CZK': 'Corona ceca',
    'DKK': 'Corona danese',
    'EUR': 'Euro',
    'GBP': 'Sterlina britannica',
    'HKD': 'Dollaro di Hong Kong',
    'HUF': 'Fiorino ungherese',
    'IDR': 'Rupia indonesiana',
    'ILS': 'Shekel israeliano',
    'INR': 'Rupia indiana',
    'ISK': 'Corona islandese',
    'JPY': 'Yen giapponese',
    'KMF': 'Franco delle Comore',
    'KRW': 'Won sudcoreano',
    'MXN': 'Peso messicano',
    'MYR': 'Ringgit malese',
    'NOK': 'Corona norvegese',
    'NZD': 'Dollaro neozelandese',
    'PHP': 'Peso filippino',
    'PLN': 'Złoty polacco',
    'RON': 'Leu rumeno',
    'SEK': 'Corona svedese',
    'SGD': 'Dollaro di Singapore',
    'STN': 'Dobra di São Tomé e Príncipe',
    'THB': 'Baht thailandese',
    'TRY': 'Lira turca',
    'USD': 'Dollaro statunitense',
    'XAF': 'Franco CFA (BEAC)',
    'XOF': 'Franco CFA (BCEAO)',
    'XPF': 'Franco CFP',
    'ZAR': 'Rand sudafricano',
  };

  static const _namesPl = <String, String>{
    'AUD': 'Dolar australijski',
    'BAM': 'Marka zamienna Bośni i Hercegowiny',
    'BGN': 'Lew bułgarski',
    'BRL': 'Real brazylijski',
    'CAD': 'Dolar kanadyjski',
    'CHF': 'Frank szwajcarski',
    'CNY': 'Juan chiński',
    'CVE': 'Escudo Zielonego Przylądka',
    'CZK': 'Korona czeska',
    'DKK': 'Korona duńska',
    'EUR': 'Euro',
    'GBP': 'Funt szterling',
    'HKD': 'Dolar hongkoński',
    'HUF': 'Forint węgierski',
    'IDR': 'Rupia indonezyjska',
    'ILS': 'Nowy szekel izraelski',
    'INR': 'Rupia indyjska',
    'ISK': 'Korona islandzka',
    'JPY': 'Jen japoński',
    'KMF': 'Frank Komorów',
    'KRW': 'Won południowokoreański',
    'MXN': 'Peso meksykańskie',
    'MYR': 'Ringgit malezyjski',
    'NOK': 'Korona norweska',
    'NZD': 'Dolar nowozelandzki',
    'PHP': 'Peso filipińskie',
    'PLN': 'Złoty polski',
    'RON': 'Lej rumuński',
    'SEK': 'Korona szwedzka',
    'SGD': 'Dolar singapurski',
    'STN': 'Dobra Wysp Świętego Tomasza i Książęcej',
    'THB': 'Bat tajski',
    'TRY': 'Lira turecka',
    'USD': 'Dolar amerykański',
    'XAF': 'Frank CFA (BEAC)',
    'XOF': 'Frank CFA (BCEAO)',
    'XPF': 'Frank CFP',
    'ZAR': 'Rand południowoafrykański',
  };

  static const _namesRo = <String, String>{
    'AUD': 'Dolar australian',
    'BAM': 'Marcă convertibilă bosniacă',
    'BGN': 'Leva bulgărească',
    'BRL': 'Real brazilian',
    'CAD': 'Dolar canadian',
    'CHF': 'Franc elvețian',
    'CNY': 'Yuan renminbi chinezesc',
    'CVE': 'Escudo capverdian',
    'CZK': 'Coroană cehă',
    'DKK': 'Coroană daneză',
    'EUR': 'Euro',
    'GBP': 'Liră sterlină',
    'HKD': 'Dolar din Hong Kong',
    'HUF': 'Forint maghiar',
    'IDR': 'Rupie indoneziană',
    'ILS': 'Shekel israelian',
    'INR': 'Rupie indiană',
    'ISK': 'Coroană islandeză',
    'JPY': 'Yen japonez',
    'KMF': 'Franc comorian',
    'KRW': 'Won sud-coreean',
    'MXN': 'Peso mexican',
    'MYR': 'Ringgit malaezian',
    'NOK': 'Coroană norvegiană',
    'NZD': 'Dolar neozeelandez',
    'PHP': 'Peso filipinez',
    'PLN': 'Zlot polonez',
    'RON': 'Leu românesc',
    'SEK': 'Coroană suedeză',
    'SGD': 'Dolar singaporez',
    'STN': 'Dobra din São Tomé și Príncipe',
    'THB': 'Baht thailandez',
    'TRY': 'Liră turcească',
    'USD': 'Dolar american',
    'XAF': 'Franc CFA (BEAC)',
    'XOF': 'Franc CFA (BCEAO)',
    'XPF': 'Franc CFP',
    'ZAR': 'Rand sud-african',
  };

  static const _namesLt = <String, String>{
    'AUD': 'Australijos doleris',
    'BAM': 'Bosnijos ir Hercegovinos konvertuojamoji markė',
    'BGN': 'Bulgarijos levas',
    'BRL': 'Brazilijos realas',
    'CAD': 'Kanados doleris',
    'CHF': 'Šveicarijos frankas',
    'CNY': 'Kinijos ženminbi juanis',
    'CVE': 'Žaliojo Kyšulio eskudas',
    'CZK': 'Čekijos krona',
    'DKK': 'Danijos krona',
    'EUR': 'Euras',
    'GBP': 'Svaras sterlingas',
    'HKD': 'Honkongo doleris',
    'HUF': 'Vengrijos forintas',
    'IDR': 'Indonezijos rupija',
    'ILS': 'Izraelio šekelis',
    'INR': 'Indijos rupija',
    'ISK': 'Islandijos krona',
    'JPY': 'Japonijos jena',
    'KMF': 'Komorų frankas',
    'KRW': 'Pietų Korėjos vonas',
    'MXN': 'Meksikos pesas',
    'MYR': 'Malaizijos ringitas',
    'NOK': 'Norvegijos krona',
    'NZD': 'Naujosios Zelandijos doleris',
    'PHP': 'Filipinų pesas',
    'PLN': 'Lenkijos zlotas',
    'RON': 'Rumunijos lėja',
    'SEK': 'Švedijos krona',
    'SGD': 'Singapūro doleris',
    'STN': 'San Tomė ir Prinsipės dobra',
    'THB': 'Tailando batas',
    'TRY': 'Turkijos lira',
    'USD': 'JAV doleris',
    'XAF': 'CFA frankas (BEAC)',
    'XOF': 'CFA frankas (BCEAO)',
    'XPF': 'CFP frankas',
    'ZAR': 'Pietų Afrikos randas',
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
