import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:flutter/material.dart';

class AmpStrings {
  static const String appTitle = 'Amplessimus';
  static const String version = '0.0.0-1';
  static const List<String> authors = ['chrissx'];
}

class AmpColors {
  static final Color _blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static final Color _blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static final Color _greyBlack = Color.fromRGBO(75, 75, 75, 1);
  static final Color _lightWhite = Color.fromRGBO(25, 25, 25, 1);
  static final Color _greyWhite = Color.fromRGBO(200, 200, 200, 1);
  static final Color _lightBlack = Color.fromRGBO(220, 220, 220, 1);

  static Color get blankGrey => isDarkMode ? _greyBlack : _greyWhite;
  static Color get lightBackground => isDarkMode ? _lightWhite : _lightBlack;
  static Color get lightForeground => isDarkMode ? _greyWhite : _greyBlack;
  static Color get colorBackground => isDarkMode ? _blankBlack : _blankWhite;
  static Color get colorForeground => isDarkMode ? _blankWhite : _blankBlack;

  static TextStyle weightedTextStyleForeground(FontWeight weight) =>
      TextStyle(color: colorForeground, fontWeight: weight);
  static TextStyle get textStyleForeground => weightedTextStyleForeground(null);
  static TextStyle sizedTextStyleForeground(double size, {FontWeight weight}) =>
      TextStyle(color: colorForeground, fontSize: size, fontWeight: weight);
  static TextStyle get styleLightForeground => sizedStyleLightForeground(null);
  static TextStyle sizedStyleLightForeground(double size) =>
      TextStyle(color: lightForeground, fontSize: size);

  static Brightness get brightness =>
      isDarkMode ? Brightness.dark : Brightness.light;
  static set brightness(Brightness b) {
    if (Brightness.values.length > 2)
      ampWarn('set AmpColors.brightness', '>2 Brightness states exist.');
    if (b == null) return;
    Prefs.isDarkMode = b != Brightness.light;
    ampInfo('AmpColors', 'set brightness = $b');
  }

  static bool get isDarkMode => Prefs.isInitialized ? Prefs.isDarkMode : true;
  static set isDarkMode(bool b) {
    if (b == null) return;
    Prefs.isDarkMode = b;
    ampInfo('AmpColors', 'set isDarkMode = $isDarkMode');
  }

  static void switchMode() => isDarkMode = !isDarkMode;
}
