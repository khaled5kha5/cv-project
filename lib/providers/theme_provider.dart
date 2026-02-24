import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _mode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from saved preference
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool(_themeKey) ?? false;
    _mode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _isInitialized = true;
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggle() async {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _savePreference();
  }

  /// Set specific theme mode
  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    await _savePreference();
  }

  /// Save theme preference to storage
  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}


class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThemeProvider>();

    return IconButton(
      tooltip: provider.isDark ? 'Light mode' : 'Dark mode',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            RotationTransition(turns: anim, child: child),
        child: Icon(
          provider.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(provider.isDark),
        ),
      ),
      onPressed: provider.toggle,
    );
  }
}