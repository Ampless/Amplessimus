import 'package:amplissimus/logging.dart';
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
  }

  static void loadCounter() {
    counter = preferences.getInt('counter');
    if(counter == null) counter = 0;
    ampLog(ctx: 'Prefs', message: 'assigned counter amount of $counter');
  }

  static void saveCounter(int saveCounter) {
    counter = saveCounter;
    preferences.setInt('counter', counter);
  }
}

