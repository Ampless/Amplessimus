import 'package:amplissimus/prefs.dart';
import 'package:flutter/cupertino.dart';

class AmpStrings {
  static String appTitle = 'Amplissimus';
  static List<String> authors = ['miruslavus', 'chrissx'];
}

class AmpColors {
  static Color blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static Color blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static Color colorBackground = blankBlack;
  static Color colorForeground = blankWhite;
  static bool isDarkMode = true;
  static void changeMode() {
    if(isDarkMode) {
      isDarkMode = false;
      colorForeground = blankBlack;
      colorBackground = blankWhite;
      Prefs.saveCurrentDesignMode(isDarkMode);
    } else {
      isDarkMode = true;
      colorForeground = blankWhite;
      colorBackground = blankBlack;
      Prefs.saveCurrentDesignMode(isDarkMode);
    }
  }
}