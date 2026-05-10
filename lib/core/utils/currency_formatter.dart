import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _brlFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _brlNoSymbolFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: '',
    decimalDigits: 2,
  );

  static final _percentFormatter = NumberFormat.percentPattern('pt_BR')
    ..maximumFractionDigits = 1;

  static String format(double value) => _brlFormatter.format(value);

  static String formatNoSymbol(double value) =>
      _brlNoSymbolFormatter.format(value).trim();

  static String formatCompact(double value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000) {
      return '$sign R\$ ${(abs / 1000000).toStringAsFixed(1)}M';
    }
    if (abs >= 1000) {
      return '$sign R\$ ${(abs / 1000).toStringAsFixed(1)}K';
    }
    return format(value);
  }

  static String formatPercent(double value) => _percentFormatter.format(value);

  static String formatDifference(double current, double previous) {
    if (previous == 0) return '+0%';
    final diff = (current - previous) / previous;
    final formatted = formatPercent(diff.abs());
    return diff >= 0 ? '+$formatted' : '-$formatted';
  }

  static double? tryParse(String value) {
    try {
      final cleaned = value
          .replaceAll('R\$', '')
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll(',', '.');
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  static String obfuscate(double value) {
    final formatted = format(value);
    return formatted.replaceAll(RegExp(r'\d'), '•');
  }
}
