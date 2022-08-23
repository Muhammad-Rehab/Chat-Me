import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static ThemeMode currentThemeMode = ThemeMode.system;

  static initTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('isDark') == null) {
      currentThemeMode = ThemeMode.system;
    } else if (sharedPreferences.getBool('isDark') == true) {
      currentThemeMode = ThemeMode.dark;
    } else {
      currentThemeMode = ThemeMode.light;
    }
  }

  bool isDarkMode() {
    if (currentThemeMode == ThemeMode.dark) {
      return true;
    } else {
      return false;
    }
  }

  void setDark(bool isDark) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (isDark) {
      sharedPreferences.setBool('isDark', true);
      currentThemeMode = ThemeMode.dark;
    } else {
      sharedPreferences.setBool('isDark', false);
      currentThemeMode = ThemeMode.light;
    }
    notifyListeners();
  }
}
