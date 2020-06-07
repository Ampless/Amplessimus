import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;
Map<String, dynamic> edits = {};

void set(String key, dynamic value) {
  if(preferences == null) edits[key] = value;
  else if(value is int) preferences.setInt(key, value);
  else if(value is bool) preferences.setBool(key, value);
  else if(value is String) preferences.setString(key, value);
  else if(value is List<String>) preferences.setStringList(key, value);
  else if(value is double) preferences.setDouble(key, value);
  else throw '${value.runtimeType} cannot be saved in the SharedPreferences.';
}

int getInt(String key, int defaultValue) {
  if(preferences == null) throw 'PREFSI NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
  int i = preferences.getInt(key);
  if(i == null) i = defaultValue;
  return i;
}

String getString(String key, String defaultValue) {
  if(preferences == null) throw 'PREFSS NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
  String s = preferences.getString(key);
  if(s == null) s = defaultValue;
  return s;
}

bool getBool(String key, bool defaultValue) {
  if(preferences == null) throw 'PREFSB NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
  bool b = preferences.getBool(key);
  if(b == null) b = defaultValue;
  return b;
} 

int get counter => getInt('counter', 0);
set counter(int i) => set('counter', i);
String get username => getString('username_dsb', '');
set username(String s) => set('username_dsb', s);
String get password => getString('password_dsb', '');
set password(String s) => set('password_dsb', s);
String get grade => getString('grade', '').toLowerCase();
set grade(String s) => set('grade', s.toLowerCase());
String get char => getString('char', '').toLowerCase();
set char(String s) => set('char', s.toLowerCase());
bool get loadingBarEnabled => getBool('loading_bar_enabled', false);
set loadingBarEnabled(bool b) => set('loading_bar_enabled', b);
bool get oneClassOnly => getBool('one_class_only', false);
set oneClassOnly(bool b) => set('one_class_only', b);

set designMode(bool isDarkMode) => set('is_dark_mode', isDarkMode);

Future<void> loadPrefs() async {
  preferences = await SharedPreferences.getInstance();
  bool isDarkMode = preferences.getBool('is_dark_mode');
  ampInfo(ctx: 'Prefs', message: 'recognized isDarkMode = $isDarkMode');
  AmpColors.setMode(isDarkMode);
  edits.forEach((key, value) => set(key, value));
  edits.clear();
}

void clear() {
  if(preferences == null) throw '';
  preferences.clear();
  ampInfo(ctx: 'Prefs', message: 'Cleared SharedPreferences.');
}
