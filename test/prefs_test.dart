import 'dart:convert';

import 'package:Amplessimus/prefs.dart' as Prefs;

import 'testlib.dart';

const String expectedJson =
    '[{"k":"char","v":"c","t":0},{"k":"DSB_JSON_CACHE","v":"[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]","t":0},{"k":"grade","v":"10","t":0},{"k":"json_timetable","v":"[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]","t":0},{"k":"password_dsb","v":"password1","t":0},{"k":"lang","v":"cz","t":0},{"k":"username_dsb","v":"158681","t":0},{"k":"current_theme_id","v":42,"t":1},{"k":"sub_list_item_space","v":500.0,"t":2},{"k":"close_app_on_back_press","v":0,"t":3},{"k":"dev_options_enabled","v":1,"t":3},{"k":"dsb_use_language","v":0,"t":3},{"k":"filter_timetables","v":0,"t":3},{"k":"first_login","v":0,"t":3},{"k":"is_dark_mode","v":1,"t":3},{"k":"one_class_only","v":0,"t":3},{"k":"use_json_cache","v":0,"t":3},{"k":"use_system_theme","v":0,"t":3}]';

void main() {
  tests([
    expectTestCase(() async {
      Prefs.char = 'c';
      Prefs.closeAppOnBackPress = false;
      Prefs.currentThemeId = 42;
      Prefs.devOptionsEnabled = true;
      Prefs.dsbJsonCache = '[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]';
      Prefs.dsbUseLanguage = false;
      Prefs.filterTimetables = false;
      Prefs.firstLogin = false;
      Prefs.grade = '10';
      Prefs.isDarkMode = true;
      Prefs.jsonTimetable = '[[[[[[[[[[[[[[[[[[[[[[[[]]]]]]]]]]]]]]]]]]]]]]]]';
      Prefs.oneClassOnly = false;
      Prefs.password = 'password1';
      Prefs.savedLangCode = 'cz';
      Prefs.subListItemSpace = 500;
      Prefs.useJsonCache = false;
      Prefs.useSystemTheme = false;
      Prefs.username = '158681';
      await Prefs.waitForMutex();
      return jsonDecode(Prefs.toJson());
    }, jsonDecode(expectedJson), false)
  ], 'Prefs');
}
