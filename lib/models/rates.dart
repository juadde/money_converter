import 'euro_pegs.dart';

/// ECB reference rates published for one business day.
class DailyRates {
  const DailyRates({required this.date, required this.rates});

  final DateTime date;

  /// Units of each currency for 1 EUR. Always contains `EUR: 1`.
  final Map<String, double> rates;

  /// Units of [currency] for 1 EUR: ECB rate, or fixed parity with the euro.
  double? perEuro(String currency) => rates[currency] ?? euroPegs[currency];

  /// How many [to] you get for one [from], or null if a currency is missing.
  double? rate(String from, String to) {
    final f = perEuro(from);
    final t = perEuro(to);
    if (f == null || t == null || f <= 0) return null;
    return t / f;
  }
}

class RatePoint {
  const RatePoint(this.date, this.value);

  final DateTime date;
  final double value;
}

/// A set of daily rates together with where and when it was obtained.
class RatesSnapshot {
  const RatesSnapshot({
    required this.days,
    required this.origin,
    required this.fetchedAt,
    this.stale = false,
  });

  /// Newest first, never empty.
  final List<DailyRates> days;

  /// Identifier of the source the data came from (see `config.dart`).
  final String origin;
  final DateTime fetchedAt;

  /// True when the network was unreachable and an old cached copy is shown.
  final bool stale;

  DailyRates get latest => days.first;

  /// ECB currencies plus the currencies pegged to the euro, sorted.
  List<String> get currencies =>
      {...latest.rates.keys, ...euroPegs.keys}.toList()..sort();

  /// Rate history for a pair, oldest first, limited to the last [maxDays]
  /// calendar days before the latest publication.
  List<RatePoint> history(String from, String to, {int? maxDays}) {
    final limit = maxDays == null
        ? null
        : latest.date.subtract(Duration(days: maxDays));
    final points = <RatePoint>[];
    for (final day in days.reversed) {
      if (limit != null && day.date.isBefore(limit)) continue;
      final value = day.rate(from, to);
      if (value != null) points.add(RatePoint(day.date, value));
    }
    return points;
  }

  RatesSnapshot copyWith({bool? stale}) => RatesSnapshot(
        days: days,
        origin: origin,
        fetchedAt: fetchedAt,
        stale: stale ?? this.stale,
      );
}
