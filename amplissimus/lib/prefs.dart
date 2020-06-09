import 'package:amplissimus/logging.dart';
import 'package:amplissimus/values.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences preferences;
Map<String, String> editsString = {};
Map<String, int> editsInt = {};
Map<String, double> editsDouble = {};
Map<String, bool> editsBool = {};
Map<String, List<String>> editsStrings = {};

void setString(String key, String value) {
  if(preferences == null) editsString[key] = value;
  else preferences.setString(key, value);
}

void setInt(String key, int value) {
  if(preferences == null) editsInt[key] = value;
  else preferences.setInt(key, value);
}

void setDouble(String key, double value) {
  if(preferences == null) editsDouble[key] = value;
  else preferences.setDouble(key, value);
}

void setStringList(String key, List<String> value) {
  if(preferences == null) editsStrings[key] = value;
  else preferences.setStringList(key, value);
}

void setBool(String key, bool value) {
  if(preferences == null) editsBool[key] = value;
  else preferences.setBool(key, value);
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

List<String> getStringList(String key, List<String> defaultValue) {
  if(preferences == null) throw 'PREFSB NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
  List<String> s = preferences.getStringList(key);
  if(s == null) s = defaultValue;
  return s;
}

String getCache(String url) => getString('CACHE_VAL_$url', null);

void setCache(String url, String html, {Duration ttl = Duration.zero}) {
  List<String> cacheUrls = getStringList('CACHE_URLS', []);
  cacheUrls.add(url);
  setStringList('CACHE_URLS', cacheUrls);
  setString('CACHE_VAL_$url', html);
  setInt('CACHE_TTL_$url', ttl == Duration.zero ? 0
    : DateTime.now().add(ttl).millisecondsSinceEpoch);
}

void flushCache() {
  List<String> urlsToRemove = [];
  List<String> cachedUrls = getStringList('CACHE_URLS', []);
  for(String url in cachedUrls) {
    int ttl = getInt('CACHE_TTL_$url', 0);
    if(ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) continue;
    urlsToRemove.add(url);
    setString('CACHE_VAL_$url', null);
    setInt('CACHE_TTL_$url', null);
  }
  if(urlsToRemove.length == 0) return;
  cachedUrls.removeWhere((element) => urlsToRemove.contains(element));
  setStringList('CACHE_URLS', cachedUrls);
}

void clearCache() {
  List<String> cachedUrls = getStringList('CACHE_URLS', []);
  if(cachedUrls.length == 0) return;
  for(String url in cachedUrls) {
    setString('CACHE_VAL_$url', null);
    setInt('CACHE_TTL_$url', null);
    ampInfo(ctx: 'CACHE', message: 'Removed $url');
  }
  setStringList('CACHE_URLS', []);
}

String listCache() {
  List<String> cachedUrls = getStringList('CACHE_URLS', []);
  if(cachedUrls.length == 0) return '{}';
  String s = '';
  for(String url in cachedUrls)
    s += '{url=\'$url\',val.length=${getString('CACHE_VAL_$url', '').length},ttl=${getInt('CACHE_TTL_$url', -1)}},';
  return '{$s}';
}

void devOptionsTimerCache() {
  if(DateTime.now().millisecondsSinceEpoch < getInt('last_pressed_tgl_drk_mode', 0) + 10000) {
    setInt('times_tgl_drk_mode_pressed', getInt('times_tgl_drk_mode_pressed', 1)+1);
  } else {
    setInt('times_tgl_drk_mode_pressed', 1);
  }
  setInt('last_pressed_tgl_drk_mode', DateTime.now().millisecondsSinceEpoch);
  print('$timesToggleDarkModePressed');
  print('${getInt('last_pressed_tgl_drk_mode', -1)}');
}

int get counter => getInt('counter', 0);
set counter(int i) => setInt('counter', i);
int get timesToggleDarkModePressed => getInt('times_tgl_drk_mode_pressed', 1);
set timesToggleDarkModePressed(int i) => setInt('times_tgl_drk_mode_pressed', i);
int get subListItemSpace => getInt('sub_list_item_space', 0);
set subListItemSpace(int i) => setInt('sub_list_item_space', i);
int get currentThemeId => getInt('current_theme_id', 0);
set currentThemeId(int i) => setInt('current_theme_id', i);
String get username => getString('username_dsb', '');
set username(String s) => setString('username_dsb', s);
String get password => getString('password_dsb', '');
set password(String s) => setString('password_dsb', s);
String get grade => getString('grade', '').toLowerCase();
set grade(String s) => setString('grade', s.toLowerCase());
String get char => getString('char', '').toLowerCase();
set char(String s) => setString('char', s.toLowerCase());
bool get loadingBarEnabled => getBool('loading_bar_enabled', false);
set loadingBarEnabled(bool b) => setBool('loading_bar_enabled', b);
bool get oneClassOnly => getBool('one_class_only', false);
set oneClassOnly(bool b) => setBool('one_class_only', b);
bool get closeAppOnBackPress => getBool('close_app_on_back_press', false);
set closeAppOnBackPress(bool b) => setBool('close_app_on_back_press', b);
bool get devOptionsEnabled => getBool('dev_options_enabled', false);
set devOptionsEnabled(bool b) => setBool('dev_options_enabled', b);
bool get counterEnabled => getBool('counter_enabled', false);
set counterEnabled(bool b) => setBool('counter_enabled', b);

set designMode(bool isDarkMode) => setBool('is_dark_mode', isDarkMode);

Future<void> loadPrefs() async {
  preferences = await SharedPreferences.getInstance();
  bool isDarkMode = preferences.getBool('is_dark_mode');
  ampInfo(ctx: 'Prefs', message: 'recognized isDarkMode = $isDarkMode');
  AmpColors.setMode(isDarkMode);
  editsString.forEach((key, value) => preferences.setString(key, value));
  editsInt.forEach((key, value) => preferences.setInt(key, value));
  editsDouble.forEach((key, value) => preferences.setDouble(key, value));
  editsBool.forEach((key, value) => preferences.setBool(key, value));
  editsStrings.forEach((key, value) => preferences.setStringList(key, value));
  editsString.clear();
  editsInt.clear();
  editsDouble.clear();
  editsBool.clear();
  editsStrings.clear();
}

void clear() {
  if(preferences == null) throw '';
  preferences.clear();
  ampInfo(ctx: 'Prefs', message: 'Cleared SharedPreferences.');
}
