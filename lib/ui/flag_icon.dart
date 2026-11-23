import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import 'formatters.dart';

/// Flag of a currency, drawn from SVG so it shows on every platform
/// (emoji flags are missing on Windows and on many Linux systems).
class CurrencyFlag extends StatelessWidget {
  const CurrencyFlag(this.currency, {super.key, this.width = 28});

  final String currency;
  final double width;

  @override
  Widget build(BuildContext context) {
    final country = flagCountryOf(currency);
    final height = width * 3 / 4;
    if (country == null) {
      // Shared currency: a globe instead of a flag.
      return SizedBox(
        width: width,
        height: height,
        child: Icon(
          Icons.public,
          size: height,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
    return CountryFlag.fromCountryCode(
      country,
      theme: ImageTheme(
        width: width,
        height: height,
        shape: const RoundedRectangle(3),
      ),
    );
  }
}

/// Flag of a language of the app.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.languageCode, {super.key, this.width = 24});

  static const _countries = {'en': 'GB', 'fr': 'FR'};

  final String languageCode;
  final double width;

  @override
  Widget build(BuildContext context) => CountryFlag.fromCountryCode(
        _countries[languageCode] ?? languageCode.toUpperCase(),
        theme: ImageTheme(
          width: width,
          height: width * 3 / 4,
          shape: const RoundedRectangle(3),
        ),
      );
}
