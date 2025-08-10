import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyUtil {
  // Exchange rates (simplified for demo purposes)
  // In a real app, these would be fetched from an API
  static const Map<String, Map<String, double>> _exchangeRates = {
    'ZMW': {
      'ZMW': 1.0,
      'USD': 0.05,
      'CNY': 0.35,
    },
    'USD': {
      'ZMW': 20.0,
      'USD': 1.0,
      'CNY': 7.0,
    },
    'CNY': {
      'ZMW': 2.85,
      'USD': 0.14,
      'CNY': 1.0,
    },
  };

  // Convert amount from one currency to another
  static double convert(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    if (_exchangeRates.containsKey(fromCurrency) &&
        _exchangeRates[fromCurrency]!.containsKey(toCurrency)) {
      return amount * _exchangeRates[fromCurrency]![toCurrency]!;
    }

    // Fallback if direct conversion not available
    return amount;
  }

  // Format currency for display
  static String format(double amount, String currency) {
    final symbol = AppConstants.currencySymbols[currency] ?? currency;
    
    // Format with 2 decimal places
    final formatter = NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 2,
    );
    
    return formatter.format(amount);
  }

  // Get available currencies
  static List<String> get availableCurrencies => 
      AppConstants.currencySymbols.keys.toList();

  // Get currency symbol
  static String getSymbol(String currency) => 
      AppConstants.currencySymbols[currency] ?? currency;
}