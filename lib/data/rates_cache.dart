import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/rates.dart';
import 'rates_json.dart';

/// Keeps the last downloaded rates on the device for offline use.
class RatesCache {
  RatesCache(this._prefs);

  static const _key = 'rates_cache_v1';

  final SharedPreferences _prefs;

  RatesSnapshot? read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return RatesSnapshot(
        days: daysFromJson(map['days']),
        origin: map['origin'] as String,
        fetchedAt: DateTime.parse(map['fetchedAt'] as String),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> write(RatesSnapshot snapshot) => _prefs.setString(
        _key,
        jsonEncode({
          'origin': snapshot.origin,
          'fetchedAt': snapshot.fetchedAt.toIso8601String(),
          'days': daysToJson(snapshot.days),
        }),
      );
}
