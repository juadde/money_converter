import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_strings.dart';
import '../models/euro_pegs.dart';
import '../models/rates.dart';
import '../state/providers.dart';
import 'currency_picker.dart';
import 'flag_icon.dart';
import 'formatters.dart';
import 'rate_chart.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  late final TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    _amountController =
        TextEditingController(text: ref.read(converterProvider).amountText);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _refresh() => ref.read(ratesProvider.notifier).refresh();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final rates = ref.watch(ratesProvider);
    final width = MediaQuery.sizeOf(context).width;
    final padding = EdgeInsets.symmetric(
      horizontal: math.max(16.0, (width - 560) / 2),
      vertical: 16,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          const _LanguageMenu(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: strings.refresh,
            onPressed: () => _refreshKey.currentState?.show(),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          children: rates.when(
            data: (snapshot) => _content(context, snapshot),
            loading: () => const [
              SizedBox(
                height: 320,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [_ErrorView(onRetry: _refresh)],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, RatesSnapshot snapshot) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final locale = strings.localeName;
    final converter = ref.watch(converterProvider);
    final controller = ref.read(converterProvider.notifier);
    final currencies = snapshot.currencies;

    // A remembered currency may have been dropped by the ECB since.
    final from = currencies.contains(converter.from) ? converter.from : 'EUR';
    final to = currencies.contains(converter.to) ? converter.to : 'EUR';

    final rate = snapshot.latest.rate(from, to);
    final amount = parseAmount(converter.amountText);
    final resultText = (rate == null || amount == null)
        ? '—'
        : '${formatAmount(amount * rate, locale)} $to';

    Future<void> pick(String current, void Function(String) onPicked) async {
      final code = await showCurrencyPicker(
        context,
        currencies: currencies,
        selected: current,
      );
      if (code != null) onPicked(code);
    }

    return [
      if (snapshot.stale) ...[
        _OfflineBanner(text: strings.offline),
        const SizedBox(height: 12),
      ],
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _CurrencyButton(
                    key: const Key('from-currency'),
                    code: from,
                    onPressed: () => pick(from, controller.setFrom),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      key: const Key('amount'),
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9.,\s]'),
                        ),
                      ],
                      textAlign: TextAlign.end,
                      style: theme.textTheme.headlineSmall,
                      decoration: InputDecoration(
                        labelText: strings.amount,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: controller.setAmount,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: IconButton.filledTonal(
                  key: const Key('swap'),
                  icon: const Icon(Icons.swap_vert),
                  tooltip: strings.swap,
                  onPressed: controller.swap,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _CurrencyButton(
                    key: const Key('to-currency'),
                    code: to,
                    onPressed: () => pick(to, controller.setTo),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: strings.result,
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        resultText,
                        key: const Key('result'),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (rate != null) ...[
                const SizedBox(height: 12),
                Text(
                  '1 $from = ${formatRate(rate, locale)} $to',
                  key: const Key('unit-rate'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              for (final code in {from, to})
                if (isEuroPegged(code)) ...[
                  const SizedBox(height: 4),
                  Text(
                    strings.parityNote(
                      code,
                      formatParity(euroPegs[code]!, locale),
                    ),
                    key: Key('parity-$code'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _HistoryCard(snapshot: snapshot, from: from, to: to),
      const SizedBox(height: 16),
      Text(
        '${strings.ratesOf(formatDate(snapshot.latest.date, locale))} · '
        '${strings.sourceLabel(snapshot.origin)}',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall,
      ),
      const SizedBox(height: 4),
      Text(
        strings.disclaimer,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }
}

class _CurrencyButton extends StatelessWidget {
  const _CurrencyButton({super.key, required this.code, this.onPressed});

  final String code;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Tooltip(
      message: strings.currencyName(code),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(116, 60),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CurrencyFlag(code),
            const SizedBox(width: 6),
            Text(code, style: Theme.of(context).textTheme.titleMedium),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            strings.loadError,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(strings.loadErrorHint, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(strings.retry),
          ),
        ],
      ),
    );
  }
}

/// Past values of the selected pair, with a period selector.
class _HistoryCard extends StatefulWidget {
  const _HistoryCard({
    required this.snapshot,
    required this.from,
    required this.to,
  });

  final RatesSnapshot snapshot;
  final String from;
  final String to;

  @override
  State<_HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<_HistoryCard> {
  int _periodDays = 30;
  int? _selected;

  @override
  void didUpdateWidget(_HistoryCard old) {
    super.didUpdateWidget(old);
    if (old.from != widget.from ||
        old.to != widget.to ||
        old.snapshot != widget.snapshot) {
      _selected = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final theme = Theme.of(context);
    final locale = strings.localeName;
    final points = widget.snapshot
        .history(widget.from, widget.to, maxDays: _periodDays);
    final selected =
        (_selected != null && _selected! < points.length) ? _selected : null;

    final children = <Widget>[
      Text(
        '${strings.history} · ${widget.from} → ${widget.to}',
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: SegmentedButton<int>(
          showSelectedIcon: false,
          style: const ButtonStyle(visualDensity: VisualDensity.compact),
          segments: [
            ButtonSegment(value: 7, label: Text(strings.oneWeek)),
            ButtonSegment(value: 30, label: Text(strings.oneMonth)),
            ButtonSegment(value: 90, label: Text(strings.threeMonths)),
          ],
          selected: {_periodDays},
          onSelectionChanged: (value) => setState(() {
            _periodDays = value.first;
            _selected = null;
          }),
        ),
      ),
      const SizedBox(height: 12),
    ];

    if (points.length < 2) {
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(strings.notEnoughHistory, textAlign: TextAlign.center),
        ),
      );
    } else {
      final values = [for (final p in points) p.value];
      final shown = points[selected ?? points.length - 1];
      final change = (points.last.value - points.first.value) /
          points.first.value *
          100;
      var low = values.first;
      var high = values.first;
      for (final v in values) {
        low = math.min(low, v);
        high = math.max(high, v);
      }

      children.addAll([
        Row(
          children: [
            Expanded(
              child: Text(
                '${formatDate(shown.date, locale)} · '
                '${formatRate(shown.value, locale)}',
                key: const Key('chart-value'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Text(
              formatPercent(change, locale),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: RateChart(
            values: values,
            minLabel: formatRate(low, locale),
            maxLabel: formatRate(high, locale),
            selectedIndex: selected,
            onSelect: (index) => setState(() => _selected = index),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              formatShortDate(points.first.date, locale),
              style: theme.textTheme.labelSmall,
            ),
            Text(
              formatShortDate(points.last.date, locale),
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ]);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

/// App bar menu to pick the language; the choice is remembered.
class _LanguageMenu extends ConsumerWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final current = ref.watch(languageProvider)?.languageCode;

    PopupMenuItem<String> item(String value, Widget leading, String label) {
      return PopupMenuItem<String>(
        key: Key('language-$value'),
        value: value,
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: leading,
              ),
            ),
            Expanded(child: Text(label)),
            if (value == (current ?? 'system'))
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(Icons.check, size: 20),
              ),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      key: const Key('language-menu'),
      icon: const Icon(Icons.translate),
      tooltip: strings.language,
      onSelected: (value) => ref
          .read(languageProvider.notifier)
          .set(value == 'system' ? null : Locale(value)),
      itemBuilder: (context) => [
        item(
          'system',
          const Icon(Icons.smartphone, size: 20),
          strings.deviceLanguage,
        ),
        const PopupMenuDivider(),
        for (final locale in AppStrings.supportedLocales)
          item(
            locale.languageCode,
            LanguageFlag(locale.languageCode),
            AppStrings.languageNames[locale.languageCode] ??
                locale.languageCode,
          ),
      ],
    );
  }
}
