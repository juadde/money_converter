import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/rates.dart';

/// Somewhere the rates can be downloaded from.
abstract class RatesSource {
  String get id;

  Future<List<DailyRates>> fetch();
}

class HttpRatesSource implements RatesSource {
  HttpRatesSource({
    required this.id,
    required this.uri,
    required this.parse,
    required this.client,
    this.timeout = const Duration(seconds: 10),
  });

  @override
  final String id;
  final Uri uri;
  final List<DailyRates> Function(String body) parse;
  final http.Client client;
  final Duration timeout;

  @override
  Future<List<DailyRates>> fetch() async {
    final response = await client.get(uri).timeout(timeout);
    if (response.statusCode != 200) {
      throw http.ClientException('HTTP ${response.statusCode}', uri);
    }
    return parse(utf8.decode(response.bodyBytes));
  }
}
