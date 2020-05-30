import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;

int get counter {
  int i = preferences.getInt('counter');
  if(i == null) i = 0;
  return i;
}
set counter(int i) {
  preferences.setInt('counter', i);
}
String get username {
  String s = preferences.getString('username_dsb');
  if(s == null) s = '';
  return s;
}
set username(String s) {
  preferences.setString('username_dsb', s);
}
String get password {
  String s = preferences.getString('password_dsb');
  if(s == null) s = '';
  return s;
}
set password(String s) {
  preferences.setString('password_dsb', s);
}
String get grade {
  String s = preferences.getString('grade');
  if(s == null) s = '';
  return s;
}
set grade(String s) {
  preferences.setString('grade', s);
}
String get char {
  String s = preferences.getString('char');
  if(s == null) s = '';
  return s;
}
set char(String s) {
  preferences.setString('char', s);
}
set designMode(bool isDarkMode) {
  preferences.setBool('is_dark_mode', isDarkMode);
}

void loadPrefs() async {
  preferences = await SharedPreferences.getInstance();
  bool isDarkMode = preferences.getBool('is_dark_mode');
  ampInfo(ctx: 'Prefs', message: 'recognized isDarkMode = $isDarkMode');
  if(isDarkMode == null) return;
  AmpColors.setMode(isDarkMode);
}

void clear() {
  preferences.clear();
  ampInfo(ctx: 'Prefs', message: 'Cleared SharedPreferences.');
}

