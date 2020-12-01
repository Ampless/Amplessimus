import 'package:flutter/material.dart';

import 'logging.dart';
import 'prefs.dart' as Prefs;

const Color _blankBlack = Color.fromRGBO(0, 0, 0, 1);
const Color _blankWhite = Color.fromRGBO(255, 255, 255, 1);
const Color _greyBlack = Color.fromRGBO(75, 75, 75, 1);
const Color _lightWhite = Color.fromRGBO(25, 25, 25, 1);
const Color _greyWhite = Color.fromRGBO(200, 200, 200, 1);
const Color _lightBlack = Color.fromRGBO(220, 220, 220, 1);

Color get blankGrey => isDarkMode ? _greyBlack : _greyWhite;
Color get lightBackground => isDarkMode ? _lightWhite : _lightBlack;
Color get lightForeground => isDarkMode ? _greyWhite : _greyBlack;
Color get colorBackground => isDarkMode ? _blankBlack : _blankWhite;
Color get colorForeground => isDarkMode ? _blankWhite : _blankBlack;

TextStyle get textStyleForeground => TextStyle(color: colorForeground);

Brightness get brightness => isDarkMode ? Brightness.dark : Brightness.light;
set brightness(Brightness b) {
  if (Brightness.values.length > 2)
    ampWarn('AmpColors.brightness', 'more than 2 Brightness states exist.');
  if (b == null) return;
  Prefs.isDarkMode = b != Brightness.light;
  ampInfo('AmpColors', 'set brightness = $b');
}

bool get isDarkMode => Prefs.isInitialized ? Prefs.isDarkMode : true;
set isDarkMode(bool b) {
  if (b == null) return;
  Prefs.isDarkMode = b;
  ampInfo('AmpColors', 'set isDarkMode = $isDarkMode');
}

void switchMode() => isDarkMode = !isDarkMode;
