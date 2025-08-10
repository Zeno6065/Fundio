import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ThemeToggleButton extends StatelessWidget {
  final Color? iconColor;
  final double size;

  const ThemeToggleButton({
    Key? key,
    this.iconColor,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isDarkMode = appProvider.themeMode == ThemeMode.dark;
    
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: iconColor,
        size: size,
      ),
      onPressed: () {
        appProvider.toggleThemeMode();
      },
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}