import 'package:intl/intl.dart';

/// Supported currencies with symbols and fixed local FX snapshots relative to USD.
class CurrencyService {
  static const Map<String, CurrencyInfo> currencies = {
    'USD': CurrencyInfo(code: 'USD', symbol: r'$', name: 'US Dollar', rate: 1.0),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '\u20AC', name: 'Euro', rate: 0.92),
    'GBP': CurrencyInfo(code: 'GBP', symbol: '\u00A3', name: 'British Pound', rate: 0.79),
    'JPY': CurrencyInfo(code: 'JPY', symbol: '\u00A5', name: 'Japanese Yen', rate: 149.50),
    'SAR': CurrencyInfo(code: 'SAR', symbol: 'SR', name: 'Saudi Riyal', rate: 3.75),
    'INR': CurrencyInfo(code: 'INR', symbol: '\u20B9', name: 'Indian Rupee', rate: 83.12),
    'CAD': CurrencyInfo(code: 'CAD', symbol: 'C\$', name: 'Canadian Dollar', rate: 1.36),
    'AUD': CurrencyInfo(code: 'AUD', symbol: 'A\$', name: 'Australian Dollar', rate: 1.53),
    'CHF': CurrencyInfo(code: 'CHF', symbol: 'Fr', name: 'Swiss Franc', rate: 0.88),
    'CNY': CurrencyInfo(code: 'CNY', symbol: '\u00A5', name: 'Chinese Yuan', rate: 7.24),
    'BRL': CurrencyInfo(code: 'BRL', symbol: 'R\$', name: 'Brazilian Real', rate: 4.97),
  };

  static CurrencyInfo info(String currencyCode) =>
      currencies[currencyCode] ?? currencies['USD']!;

  static double fxRate(String from, String to) {
    final fromRate = info(from).rate;
    final toRate = info(to).rate;
    return toRate / fromRate;
  }

  static String format(double amount, String currencyCode) {
    final details = info(currencyCode);
    final formatter = NumberFormat.currency(
      symbol: details.symbol,
      decimalDigits: currencyCode == 'JPY' ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static double convert(double amount, String from, String to) {
    final fromRate = info(from).rate;
    final toRate = info(to).rate;
    return amount / fromRate * toRate;
  }

  static String formatCompact(double amount, String currencyCode) {
    final details = info(currencyCode);
    if (amount.abs() >= 1000000) {
      return '${details.symbol}${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount.abs() >= 1000) {
      return '${details.symbol}${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '${details.symbol}${amount.toStringAsFixed(2)}';
  }
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final double rate;

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.rate,
  });
}

