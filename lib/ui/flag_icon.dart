import 'dart:math' as math;

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
    if (country == 'EU') {
      // Not a country, so not in country_flags: drawn here.
      return EuFlag(width: width);
    }
    // The fixed box keeps the flag from taking all the width it is given.
    return SizedBox(
      width: width,
      height: height,
      child: CountryFlag.fromCountryCode(
        country,
        theme: ImageTheme(
          width: width,
          height: height,
          shape: const RoundedRectangle(3),
        ),
      ),
    );
  }
}

/// Flag of a language of the app.
class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.languageCode, {super.key, this.width = 24});

  static const _countries = {
    'en': 'GB',
    'fr': 'FR',
    'de': 'DE',
    'es': 'ES',
    'it': 'IT',
    'pl': 'PL',
    'ro': 'RO',
    'lt': 'LT',
  };

  final String languageCode;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width * 3 / 4,
        child: CountryFlag.fromCountryCode(
          _countries[languageCode] ?? languageCode.toUpperCase(),
          theme: ImageTheme(
            width: width,
            height: width * 3 / 4,
            shape: const RoundedRectangle(3),
          ),
        ),
      );
}

/// Flag of Europe: twelve gold stars in a circle on a blue field.
class EuFlag extends StatelessWidget {
  const EuFlag({super.key, this.width = 28});

  final double width;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: CustomPaint(
          size: Size(width, width * 3 / 4),
          painter: _EuFlagPainter(),
        ),
      );
}

class _EuFlagPainter extends CustomPainter {
  static const _blue = Color(0xFF003399);
  static const _gold = Color(0xFFFFCC00);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _blue);
    // Official proportions: circle radius 1/3 of the height, star radius
    // 1/18 of the height, one star at each hour of a clock face.
    final center = size.center(Offset.zero);
    final circle = size.height / 3;
    final star = size.height / 18;
    final paint = Paint()..color = _gold;
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final c = center +
          Offset(math.sin(angle) * circle, -math.cos(angle) * circle);
      canvas.drawPath(_star(c, star), paint);
    }
  }

  /// Five-pointed star, one point up.
  Path _star(Offset c, double r) {
    final inner = r * 0.382;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final radius = i.isEven ? r : inner;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(_EuFlagPainter old) => false;
}
