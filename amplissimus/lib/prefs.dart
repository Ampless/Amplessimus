import 'dart:io';

import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;

void waitForPrefs() {
  while(preferences == null) sleep(Duration(milliseconds: 10));
}

int get counter {
  waitForPrefs();
  int i = preferences.getInt('counter');
  if(i == null) i = 0;
  return i;
}
set counter(int i) {
  waitForPrefs();
  preferences.setInt('counter', i);
}
String get username {
  waitForPrefs();
  String s = preferences.getString('username_dsb');
  if(s == null) s = '';
  return s;
}
set username(String s) {
  waitForPrefs();
  preferences.setString('username_dsb', s);
}
String get password {
  waitForPrefs();
  String s = preferences.getString('password_dsb');
  if(s == null) s = '';
  return s;
}
set password(String s) {
  waitForPrefs();
  preferences.setString('password_dsb', s);
}
String get grade {
  waitForPrefs();
  String s = preferences.getString('grade');
  if(s == null) s = '';
  return s;
}
set grade(String s) {
  waitForPrefs();
  preferences.setString('grade', s);
}
String get char {
  waitForPrefs();
  String s = preferences.getString('char');
  if(s == null) s = '';
  return s;
}
set char(String s) {
  waitForPrefs();
  preferences.setString('char', s);
}
set designMode(bool isDarkMode) {
  waitForPrefs();
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
  waitForPrefs();
  preferences.clear();
  ampInfo(ctx: 'Prefs', message: 'Cleared SharedPreferences.');
}

