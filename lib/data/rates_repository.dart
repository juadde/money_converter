import '../models/rates.dart';
import 'rates_cache.dart';
import 'rates_source.dart';

class RatesUnavailableException implements Exception {
  RatesUnavailableException(this.cause);

  final Object? cause;

  @override
  String toString() => 'RatesUnavailableException($cause)';
}

/// Loads the rates: fresh cache, then each source in order, then stale cache.
class RatesRepository {
  RatesRepository({
    required this.sources,
    required this.cache,
    this.cacheTtl = const Duration(hours: 1),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final List<RatesSource> sources;
  final RatesCache cache;
  final Duration cacheTtl;
  final DateTime Function() _now;

  Future<RatesSnapshot> load({bool forceRefresh = false}) async {
    final cached = cache.read();
    if (!forceRefresh &&
        cached != null &&
        _now().difference(cached.fetchedAt).abs() < cacheTtl) {
      return cached;
    }

    Object? lastError;
    for (final source in sources) {
      try {
        final days = await source.fetch();
        if (days.isEmpty) throw const FormatException('Empty rates');
        final snapshot = RatesSnapshot(
          days: days,
          origin: source.id,
          fetchedAt: _now(),
        );
        await cache.write(snapshot);
        return snapshot;
      } catch (e) {
        lastError = e;
      }
    }

    if (cached != null) return cached.copyWith(stale: true);
    throw RatesUnavailableException(lastError);
  }
}
