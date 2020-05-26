import 'package:flutter/cupertino.dart';

class AmpStrings {
  static String appTitle = 'Amplissimus';
  static List<String> authors = ['miruslavus', 'chrissx'];
}

class AmpColors {
  static Color blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static Color blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static Color colorBackground = Color.fromRGBO(0, 0, 0, 1);
  static Color colorForeground = Color.fromRGBO(255, 255, 255, 1);
  static bool isDarkMode = true;
  static void changeMode() {
    if(isDarkMode) {
      isDarkMode = false;
      colorForeground = blankBlack;
      colorBackground = blankWhite;
    } else {
      isDarkMode = true;
      colorForeground = blankWhite;
      colorBackground = blankBlack;
    }
  }
}