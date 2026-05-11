import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  // ─── Currency formatting ──────────────────────────────────────────────────
  String get brl =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(this);

  String get brlCompact {
    if (abs() >= 1000000) {
      return 'R\$ ${(this / 1000000).toStringAsFixed(1)}M';
    }
    if (abs() >= 1000) {
      return 'R\$ ${(this / 1000).toStringAsFixed(1)}K';
    }
    return brl;
  }

  String get brlNoSymbol =>
      NumberFormat.currency(locale: 'pt_BR', symbol: '').format(this).trim();

  String currencyFormatted({String symbol = 'R\$', String locale = 'pt_BR'}) =>
      NumberFormat.currency(locale: locale, symbol: symbol).format(this);

  // ─── Percentage ───────────────────────────────────────────────────────────
  String get percent => '${(this * 100).toStringAsFixed(1)}%';
  String get percentRaw => '${toStringAsFixed(1)}%';
  String get percentDisplay => '${(this * 100).toStringAsFixed(0)}%';

  // ─── General formatting ───────────────────────────────────────────────────
  String toFixed(int decimals) => toStringAsFixed(decimals);
  String get twoDecimals => toStringAsFixed(2);

  // ─── Financial helpers ────────────────────────────────────────────────────
  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;

  double get absValue => abs();

  // ─── Progress ─────────────────────────────────────────────────────────────
  double clampedProgress(double max) =>
      max > 0 ? (this / max).clamp(0.0, 1.0) : 0.0;
}

extension IntExtensions on int {
  String get brl => toDouble().brl;
  String get brlCompact => toDouble().brlCompact;
  String get ordinal {
    if (this >= 11 && this <= 13) return '$thisº';
    switch (this % 10) {
      case 1:
        return '$thisº';
      case 2:
        return '$thisº';
      case 3:
        return '$thisº';
      default:
        return '$thisº';
    }
  }

  String get daysLabel => this == 1 ? '1 dia' : '$this dias';
  String get monthsLabel => this == 1 ? '1 mês' : '$this meses';
}

extension NullableDoubleExtensions on double? {
  String get brlOrZero => (this ?? 0.0).brl;
  bool get isNullOrZero => this == null || this == 0.0;
}
