import 'package:flutter/material.dart';

class AppConstants {
  // App name
  static const String appName = 'Fundio';
  
  // Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Green
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  
  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textColor,
  );
  
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );
  
  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: secondaryTextColor,
  );
  
  // Currency Symbols
  static const Map<String, String> currencySymbols = {
    'ZMW': 'ZMW',
    'USD': '\$',
    'CNY': '¥',
  };
  
  // Default Currency
  static const String defaultCurrency = 'ZMW';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 500);
  static const Duration longAnimationDuration = Duration(milliseconds: 800);
  
  // Paddings
  static const double smallPadding = 8.0;
  static const double mediumPadding = 16.0;
  static const double largePadding = 24.0;
  
  // Border Radius
  static const double borderRadius = 8.0;
  static const double buttonRadius = 12.0;
  static const double cardRadius = 16.0;
}