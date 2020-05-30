import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

int counter = 0;
SharedPreferences preferences;
String username = '';
String password = '';
String grade = '5';
String char = 'a';

void loadPrefs() async {
  preferences = await SharedPreferences.getInstance();
  loadVariables();
}

void loadVariables() {
  loadCounter();
  loadCurrentDesignMode();
  loadCredentials();
  loadClass();
}

void loadCounter() {
  counter = preferences.getInt('counter');
  if(counter == null) counter = 0;
  ampInfo(ctx: 'Prefs', message: 'loaded counter = $counter');
}

void saveCounter(int saveCounter) {
  counter = saveCounter;
  preferences.setInt('counter', counter);
}

void loadCurrentDesignMode() {
  bool tempBool = preferences.getBool('is_dark_mode');
  ampInfo(ctx: 'Prefs', message: 'recognized isDarkMode = $tempBool');
  if(tempBool == null) return;
  if(tempBool) {
    if(!AmpColors.isDarkMode) AmpColors.changeMode();
  } else {
    if(AmpColors.isDarkMode) AmpColors.changeMode();
  }
}

void saveCurrentDesignMode(bool isDarkMode) {
  preferences.setBool('is_dark_mode', isDarkMode);
  ampInfo(ctx: 'Prefs', message: 'saved isDarkMode = $isDarkMode');
}

void loadCredentials() {
  String tempUsername = preferences.getString('username_dsb');
  String tempPassword = preferences.getString('password_dsb');
  if(tempUsername == null || tempPassword == null) {
    tempUsername = '';
    tempPassword = '';
  }
  username = tempUsername;
  password = tempPassword;
  ampInfo(ctx: 'Prefs', message: 'loaded username = "$username"');
  ampInfo(ctx: 'Prefs', message: 'loaded password = "$password"');
}

void saveCredentials(String tempUsername, String tempPassword) {
  username = tempUsername;
  password = tempPassword;
  preferences.setString('username_dsb', username);
  preferences.setString('password_dsb', password);
  ampInfo(ctx: 'Prefs', message: 'saved username_dsb = "$username"');
  ampInfo(ctx: 'Prefs', message: 'saved password_dsb = "$password"');
}

void loadClass() {
  String tempGrade = preferences.getString('grade');
  String tempChar = preferences.getString('char');
  if(tempGrade == null || tempChar == null) {
    tempGrade = '';
    tempChar = '';
  }
  grade = tempGrade;
  char = tempChar;
  ampInfo(ctx: 'Prefs', message: 'loaded grade = "$grade"');
  ampInfo(ctx: 'Prefs', message: 'loaded char = "$char"');
}

void saveClass(String tempGrade, String tempChar) {
  grade = tempGrade;
  char = tempChar;
  preferences.setString('grade', grade);
  preferences.setString('char', char);
  ampInfo(ctx: 'Prefs', message: 'saved grade = "$grade"');
  ampInfo(ctx: 'Prefs', message: 'saved char = "$char"');
}

void clear() {
  preferences.clear();
  username = '';
  password = '';
  grade = '';
  char = '';
  counter = 0;
  ampInfo(ctx: 'Prefs', message: 'Cleared SharedPreferences');
}

