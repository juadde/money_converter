import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'ecb_parser.dart';
import 'rates_json.dart';
import 'rates_source.dart';

const ecbOrigin = 'ecb';
const githubOrigin = 'github';

/// Last 90 days of ECB euro foreign exchange reference rates.
final ecbHistoryUri = Uri.parse(
  'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-hist-90d.xml',
);

/// JSON copy of the ECB feed, rebuilt by the `Deploy` GitHub workflow and
/// served by GitHub Pages next to the web app.
const defaultFallbackUrl = 'https://juadde.github.io/money_converter/rates.json';

/// Override with `--dart-define=RATES_FALLBACK_URL=...`.
const _fallbackOverride = String.fromEnvironment('RATES_FALLBACK_URL');

Uri fallbackUri() {
  if (_fallbackOverride.isNotEmpty) return Uri.parse(_fallbackOverride);
  // On the web the JSON is deployed with the app: same origin, no CORS.
  if (kIsWeb) return Uri.base.resolve('rates.json');
  return Uri.parse(defaultFallbackUrl);
}

/// Sources in priority order: ECB first, GitHub copy as a fallback.
///
/// The ECB server sends no CORS header, so a browser can never read it:
/// the web build goes straight to the fallback.
List<RatesSource> defaultSources(http.Client client) => [
      if (!kIsWeb)
        HttpRatesSource(
          id: ecbOrigin,
          uri: ecbHistoryUri,
          parse: parseEcbXml,
          client: client,
        ),
      HttpRatesSource(
        id: githubOrigin,
        uri: fallbackUri(),
        parse: parseRatesJson,
        client: client,
      ),
    ];
