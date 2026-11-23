/// Currencies pegged to the euro at a fixed rate. The ECB does not publish
/// them, so their rates come from these parities and the ECB rates of the
/// day (for example CVE to USD goes through EUR).
///
/// Units of each currency for 1 EUR.
const Map<String, double> euroPegs = {
  // Cape Verdean escudo, Banco de Cabo Verde, since 1999.
  'CVE': 110.265,
  // CFA francs (BCEAO and BEAC) and Comorian franc, since 1999.
  'XOF': 655.957,
  'XAF': 655.957,
  'KMF': 491.96775,
  // CFP franc: 1,000 XPF = 8.38 EUR, since 1999.
  'XPF': 1000 / 8.38,
  // Bosnia and Herzegovina convertible mark (former Deutsche Mark parity).
  'BAM': 1.95583,
  // São Tomé and Príncipe dobra, since 2010.
  'STN': 24.5,
};

/// True when [currency] has a fixed parity with the euro.
bool isEuroPegged(String currency) => euroPegs.containsKey(currency);
