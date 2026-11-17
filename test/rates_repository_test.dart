import 'package:flutter_test/flutter_test.dart';
import 'package:moneyconverter/data/rates_cache.dart';
import 'package:moneyconverter/data/rates_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RatesCache cache;
  late DateTime clock;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = RatesCache(await SharedPreferences.getInstance());
    clock = DateTime(2026, 11, 14, 12);
  });

  RatesRepository repository(List<FakeSource> sources) => RatesRepository(
        sources: sources,
        cache: cache,
        now: () => clock,
      );

  test('uses the first source when it answers', () async {
    final ecb = FakeSource('ecb', sampleDays());
    final github = FakeSource('github', sampleDays());

    final snapshot = await repository([ecb, github]).load();

    expect(snapshot.origin, 'ecb');
    expect(snapshot.stale, isFalse);
    expect(github.calls, 0);
  });

  test('falls back to the next source when the first one fails', () async {
    final ecb = FakeSource('ecb', null);
    final github = FakeSource('github', sampleDays());

    final snapshot = await repository([ecb, github]).load();

    expect(snapshot.origin, 'github');
    expect(ecb.calls, 1);
    expect(github.calls, 1);
  });

  test('serves a recent cache without touching the network', () async {
    final ecb = FakeSource('ecb', sampleDays());
    final repo = repository([ecb]);
    await repo.load();

    clock = clock.add(const Duration(minutes: 30));
    final snapshot = await repo.load();

    expect(ecb.calls, 1);
    expect(snapshot.stale, isFalse);
    expect(snapshot.days, hasLength(3));
  });

  test('downloads again once the cache expired or on forced refresh',
      () async {
    final ecb = FakeSource('ecb', sampleDays());
    final repo = repository([ecb]);
    await repo.load();

    await repo.load(forceRefresh: true);
    expect(ecb.calls, 2);

    clock = clock.add(const Duration(hours: 2));
    await repo.load();
    expect(ecb.calls, 3);
  });

  test('returns the stale cache when every source fails', () async {
    final ecb = FakeSource('ecb', sampleDays());
    final repo = repository([ecb]);
    await repo.load();

    ecb.days = null;
    clock = clock.add(const Duration(days: 2));
    final snapshot = await repo.load();

    expect(snapshot.stale, isTrue);
    expect(snapshot.latest.rates['USD'], 2.0);
  });

  test('throws when nothing is available', () async {
    final repo = repository([FakeSource('ecb', null)]);
    expect(repo.load(), throwsA(isA<RatesUnavailableException>()));
  });
}
