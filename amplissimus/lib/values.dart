import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AmpStrings {
  static String appTitle = 'Amplissimus';
  static List<String> authors = ['miruslavus', 'chrissx'];
}

class AmpColors {
  static MaterialColor primaryBlack = MaterialColor(
    blackPrimaryValue,
    <int, Color>{
      50: Color(0xFF000000),
      100: Color(0xFF000000),
      200: Color(0xFF000000),
      300: Color(0xFF000000),
      400: Color(0xFF000000),
      500: Color(blackPrimaryValue),
      600: Color(0xFF000000),
      700: Color(0xFF000000),
      800: Color(0xFF000000),
      900: Color(0xFF000000),
    },
  );
  static int blackPrimaryValue = 0xFF000000;

  static MaterialColor primaryWhite = MaterialColor(
    whitePrimaryValue,
    <int, Color>{
      50: Color(0xFFFFFFFF),
      100: Color(0xFFFFFFFF),
      200: Color(0xFFFFFFFF),
      300: Color(0xFFFFFFFF),
      400: Color(0xFFFFFFFF),
      500: Color(whitePrimaryValue),
      600: Color(0xFFFFFFFF),
      700: Color(0xFFFFFFFF),
      800: Color(0xFFFFFFFF),
      900: Color(0xFFFFFFFF),
    },
  );
  static int whitePrimaryValue = 0xFFFFFFFF;

  static MaterialColor materialColor = primaryWhite;
  static Color blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static Color blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static Color blankGrey = Color.fromRGBO(127, 127, 127, 1);
  static Color colorBackground = blankBlack;
  static Color colorForeground = blankWhite;
  static bool isDarkMode = true;
  static void changeMode() {
    isDarkMode = !isDarkMode;
    ampInfo(ctx: 'AmpColors', message: 'set isDarkMode = $isDarkMode');
    Prefs.saveCurrentDesignMode(isDarkMode);
    if(!isDarkMode) {
      materialColor = primaryBlack;
      colorForeground = blankBlack;
      colorBackground = blankWhite;
    } else {
      
      colorForeground = blankWhite;
      colorBackground = blankBlack;
    }
  }
  
}