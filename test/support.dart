import 'package:moneyconverter/data/rates_source.dart';
import 'package:moneyconverter/models/rates.dart';

/// A source that returns canned days, or fails when [days] is null.
class FakeSource implements RatesSource {
  FakeSource(this.id, this.days);

  @override
  final String id;
  List<DailyRates>? days;
  int calls = 0;

  @override
  Future<List<DailyRates>> fetch() async {
    calls++;
    final result = days;
    if (result == null) throw Exception('$id unreachable');
    return result;
  }
}

List<DailyRates> sampleDays() => [
      DailyRates(
        date: DateTime(2026, 11, 13),
        rates: const {'EUR': 1.0, 'USD': 2.0, 'ZAR': 20.0},
      ),
      DailyRates(
        date: DateTime(2026, 11, 12),
        rates: const {'EUR': 1.0, 'USD': 1.9, 'ZAR': 21.0},
      ),
      DailyRates(
        date: DateTime(2026, 11, 11),
        rates: const {'EUR': 1.0, 'USD': 1.8, 'ZAR': 22.0},
      ),
    ];
