import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class CustomValues {
  static bool isAprilFools = false;
  static void checkForAprilFools() {
    var now = DateTime.now();
    if(now.day == 1 && now.month == 4) isAprilFools = true;
  }
  static PackageInfo packageInfo;
  static Future<void> loadPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
  }
}

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

  //static MaterialColor materialColor = primaryWhite;
  static Color blankBlack = Color.fromRGBO(0, 0, 0, 1);
  static Color blankWhite = Color.fromRGBO(255, 255, 255, 1);
  static Color blankGrey = Color.fromRGBO(75, 75, 75, 1);
  static Color lightForeground = Color.fromRGBO(25, 25, 25, 1);
  static Color colorBackground = blankBlack;
  static Color colorForeground = blankWhite;
  static bool isDarkMode = true;
  static void changeMode() {
    setMode(!isDarkMode);
    ampInfo(ctx: 'AmpColors', message: 'set isDarkMode = $isDarkMode');
  }
  static void setMode(bool _isDarkMode) {
    if(_isDarkMode == null) return;
    isDarkMode = _isDarkMode;
    Prefs.designMode = isDarkMode;
    if(isDarkMode) {
      blankGrey = Color.fromRGBO(75, 75, 75, 1);
      lightForeground = Color.fromRGBO(25, 25, 25, 1);
      colorForeground = blankWhite;
      colorBackground = blankBlack;
    } else {
      blankGrey = Color.fromRGBO(200, 200, 200, 1);
      lightForeground = Color.fromRGBO(220, 220, 220, 1);
      colorForeground = blankBlack;
      colorBackground = blankWhite;
    }
  }

  static final Animatable<Color> rainbowBackgroundAnimation = TweenSequence<Color>(
    [
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.red,
          end: Colors.green,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.green,
          end: Colors.blue,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.blue,
          end: Colors.pink,
        ),
      ),
    ],
  );
  
}