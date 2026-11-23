import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../models/euro_pegs.dart';
import 'formatters.dart';

/// Opens a searchable list of currencies and returns the chosen code.
Future<String?> showCurrencyPicker(
  BuildContext context, {
  required List<String> currencies,
  required String selected,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (context) =>
        _CurrencyPicker(currencies: currencies, selected: selected),
  );
}

class _CurrencyPicker extends StatefulWidget {
  const _CurrencyPicker({required this.currencies, required this.selected});

  final List<String> currencies;
  final String selected;

  @override
  State<_CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<_CurrencyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final query = _query.trim().toLowerCase();
    final matches = [
      for (final code in widget.currencies)
        if (query.isEmpty ||
            code.toLowerCase().contains(query) ||
            strings.currencyName(code).toLowerCase().contains(query))
          code,
    ];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                key: const Key('currency-search'),
                autofocus: false,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: strings.chooseCurrency,
                  hintText: strings.search,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text(strings.noCurrencyFound))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final code = matches[index];
                        return ListTile(
                          leading: Text(
                            flagOf(code),
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(code),
                          subtitle: Text(
                            isEuroPegged(code)
                                ? '${strings.currencyName(code)} · '
                                    '${strings.fixedParity}'
                                : strings.currencyName(code),
                          ),
                          trailing: code == widget.selected
                              ? const Icon(Icons.check)
                              : null,
                          selected: code == widget.selected,
                          onTap: () => Navigator.of(context).pop(code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
