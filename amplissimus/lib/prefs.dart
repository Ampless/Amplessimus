import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static int counter = 0;
  static SharedPreferences preferences;

  static void loadPrefs() async {
    preferences = await SharedPreferences.getInstance();
    loadVariables();
  }

  static void loadVariables() {
    loadCounter();
    loadCurrentDesignMode();
  }

  static void loadCounter() {
    counter = preferences.getInt('counter');
    if(counter == null) counter = 0;
    ampLog(ctx: 'Prefs', message: 'saved counter = $counter');
  }

  static void saveCounter(int saveCounter) {
    counter = saveCounter;
    preferences.setInt('counter', counter);
  }

  static void loadCurrentDesignMode() {
    bool tempBool = preferences.getBool('is_dark_mode');
    ampLog(ctx: 'Prefs', message: 'recognized isDarkMode = $tempBool');
    if(tempBool) {
      if(AmpColors.isDarkMode) return;
      AmpColors.changeMode();
    } else {
      if(!AmpColors.isDarkMode) return;
      AmpColors.changeMode();
    }
  }

  static void saveCurrentDesignMode(bool isDarkMode) {
    preferences.setBool('is_dark_mode', isDarkMode);
    ampLog(ctx: 'Prefs', message: 'saved isDarkMode = $isDarkMode');
  }
}

