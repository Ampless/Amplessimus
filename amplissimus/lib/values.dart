import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AmpStrings {
  static String appTitle = 'Amplissimus';
  static List<String> authors = ['miruslavus', 'chrissx'];
}

class AmpColors {
  static Map<int, Color> colorMapWhite = {
    50:Color.fromRGBO(255,255,255, .1),
    100:Color.fromRGBO(255,255,255, .2),
    200:Color.fromRGBO(255,255,255, .3),
    300:Color.fromRGBO(255,255,255, .4),
    400:Color.fromRGBO(255,255,255, .5),
    500:Color.fromRGBO(255,255,255, .6),
    600:Color.fromRGBO(255,255,255, .7),
    700:Color.fromRGBO(255,255,255, .8),
    800:Color.fromRGBO(255,255,255, .9),
    900:Color.fromRGBO(255,255,255, 1),
  };
  static Map<int, Color> colorMapBlack = {
    50:Color.fromRGBO(0,0,0, .1),
    100:Color.fromRGBO(0,0,0, .2),
    200:Color.fromRGBO(0,0,0, .3),
    300:Color.fromRGBO(0,0,0, .4),
    400:Color.fromRGBO(0,0,0, .5),
    500:Color.fromRGBO(0,0,0, .6),
    600:Color.fromRGBO(0,0,0, .7),
    700:Color.fromRGBO(0,0,0, .8),
    800:Color.fromRGBO(0,0,0, .9),
    900:Color.fromRGBO(0,0,0, 1),
  };
  static Color blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static Color blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static Color blankGrey = Color.fromRGBO(127, 127, 127, 1);
  static Color colorBackground = blankBlack;
  static Color colorForeground = blankWhite;
  static MaterialColor materialColor = MaterialColor(0x000000FF, colorMapBlack);
  static bool isDarkMode = true;
  static void changeMode() {
    if(isDarkMode) {
      isDarkMode = false;
      ampLog(ctx: 'AmpColors', message: 'set isDarkMode = $isDarkMode');
      colorForeground = blankBlack;
      colorBackground = blankWhite;
      materialColor = MaterialColor(0xFFFFFFFF, colorMapWhite);
      Prefs.saveCurrentDesignMode(isDarkMode);
    } else {
      isDarkMode = true;
      ampLog(ctx: 'AmpColors', message: 'set isDarkMode = $isDarkMode');
      colorForeground = blankWhite;
      colorBackground = blankBlack;
      materialColor = MaterialColor(0x000000FF, colorMapBlack);
      Prefs.saveCurrentDesignMode(isDarkMode);
    }
  }
}