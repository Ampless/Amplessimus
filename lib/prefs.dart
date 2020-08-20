import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/pref_cache.dart';
import 'package:Amplessimus/utils.dart';
import 'package:crypto/crypto.dart';

CachedSharedPreferences _prefs;

//this is just a checksum basically so md5 is fine (collisions are next to impossible)
//but because it is only 128 bits, it saves 128 bits compared to sha256,
//which translates to 384 bits / 48 bytes saved per cached url
//(and also it saves quite a bit of cpu)
String _hashCache(String s) => md5.convert(utf8.encode(s)).toString();

String getCache(String url) =>
    _prefs.getString('CACHE_VAL_${_hashCache(url)}', null);

void setCache(String url, String html, Duration ttl) {
  var hash = _hashCache(url);
  var cachedHashes = _prefs.getStringList('CACHE_URLS', []);
  if (!cachedHashes.contains(hash)) cachedHashes.add(hash);
  _prefs.setStringList('CACHE_URLS', cachedHashes);
  _prefs.setString('CACHE_VAL_$hash', html);
  _prefs.setInt(
      'CACHE_TTL_$hash', DateTime.now().add(ttl).millisecondsSinceEpoch);
}

void flushCache() {
  var toRemove = <String>[];
  var cachedHashes = _prefs.getStringList('CACHE_URLS', []);
  for (var hash in cachedHashes) {
    var ttl = _prefs.getInt('CACHE_TTL_$hash', 0);
    if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) continue;
    toRemove.add(hash);
    _prefs.setString('CACHE_VAL_$hash', null);
    _prefs.setInt('CACHE_TTL_$hash', null);
  }
  if (toRemove.isEmpty) return;
  cachedHashes.removeWhere((element) => toRemove.contains(element));
  _prefs.setStringList('CACHE_URLS', cachedHashes);
}

void clearCache() {
  var cachedHashes = _prefs.getStringList('CACHE_URLS', []);
  if (cachedHashes.isEmpty) return;
  for (var hash in cachedHashes) {
    _prefs.setString('CACHE_VAL_$hash', null);
    _prefs.setInt('CACHE_TTL_$hash', null);
    ampInfo('CACHE', 'Removed $hash');
  }
  _prefs.setStringList('CACHE_URLS', []);
}

void listCache() {
  ampInfo('Cache', '{');
  for (var hash in _prefs.getStringList('CACHE_URLS', []))
    ampRawLog(jsonEncode({
      'hash': hash,
      'len': _prefs.getString('CACHE_VAL_$hash', '').length,
      'ttl': _prefs.getInt('CACHE_TTL_$hash', -1)
    }));
  ampInfo('Cache', '}');
}

int timesToggleDarkModePressed = 0;
int lastPressedToggleDarkMode = 0;

void devOptionsTimerCache() {
  if (DateTime.now().millisecondsSinceEpoch > lastPressedToggleDarkMode + 10000)
    timesToggleDarkModePressed = 0;
  timesToggleDarkModePressed += 1;
  lastPressedToggleDarkMode = DateTime.now().millisecondsSinceEpoch;
}

double get subListItemSpace => _prefs.getDouble('sub_list_item_space', 0);
set subListItemSpace(double d) => _prefs.setDouble('sub_list_item_space', d);
int get currentThemeId => _prefs.getInt('current_theme_id', 0);
set currentThemeId(int i) => _prefs.setInt('current_theme_id', i);
String get username => _prefs.getString('username_dsb', '');
set username(String s) => _prefs.setString('username_dsb', s);
String get password => _prefs.getString('password_dsb', '');
set password(String s) => _prefs.setString('password_dsb', s);
String get grade => _prefs.getString('grade', '5').toLowerCase();
set grade(String s) => _prefs.setString('grade', s.toLowerCase());
String get char => _prefs.getString('char', 'a').toLowerCase();
set char(String s) => _prefs.setString('char', s.toLowerCase());
bool get oneClassOnly => _prefs.getBool('one_class_only', false);
set oneClassOnly(bool b) => _prefs.setBool('one_class_only', b);
bool get closeAppOnBackPress =>
    _prefs.getBool('close_app_on_back_press', false);
set closeAppOnBackPress(bool b) => _prefs.setBool('close_app_on_back_press', b);
bool get devOptionsEnabled => _prefs.getBool('dev_options_enabled', false);
set devOptionsEnabled(bool b) => _prefs.setBool('dev_options_enabled', b);
bool get firstLogin => _prefs.getBool('first_login', true);
set firstLogin(bool b) => _prefs.setBool('first_login', b);
bool get useJsonCache => _prefs.getBool('use_json_cache', false);
set useJsonCache(bool b) => _prefs.setBool('use_json_cache', b);
bool get useSystemTheme => _prefs.getBool('use_system_theme', false);
set useSystemTheme(bool b) => _prefs.setBool('use_system_theme', b);
bool get filterTimetables => _prefs.getBool('filter_timetables', true);
set filterTimetables(bool b) => _prefs.setBool('filter_timetables', b);
String get dsbJsonCache => _prefs.getString('DSB_JSON_CACHE', null);
set dsbJsonCache(String s) => _prefs.setString('DSB_JSON_CACHE', s);
String get savedLangCode => _prefs.getString('lang', Platform.localeName);
set savedLangCode(String s) => _prefs.setString('lang', s);
String get jsonTimetable => _prefs.getString('json_timetable', null);
set jsonTimetable(String s) => _prefs.setString('json_timetable', s);

//this is only temporary
//the temporary windows shared prefs just don't allow this to work well
String log = '';

bool get dsbUseLanguage => _prefs.getBool('dsb_use_language', false);
set dsbUseLanguage(bool b) => _prefs.setBool('dsb_use_language', b);

String get dsbLanguage => dsbUseLanguage ? savedLangCode : 'de';

Timer _updateTimer;
int get timer => _prefs.getInt('update_dsb_timer', 15);
void setTimer(int i, Function() f) {
  _prefs.setInt('update_dsb_timer', i);
  if (_updateTimer != null) _updateTimer.cancel();
  _updateTimer = FirstLoginValues.testing
      ? null
      : Timer.periodic(Duration(minutes: i), (timer) => f());
}

set isDarkMode(bool b) => _prefs.setBool('is_dark_mode', b);

bool get isDarkMode {
  if (!_prefs.isInitialized) return true;
  return _prefs.getBool('is_dark_mode', true);
}

String toJson() => _prefs.toJson();

//This does practically nothing (it is internally called when setting
//any value), but it waits for any set operations in progress to finish.
Future<Null> waitForMutex() => _prefs.waitForMutex();

void initTest() {
  _prefs = CachedSharedPreferences();
  _prefs.platformSharedPrefSupportFalse();
}

Future<Null> load() async {
  _prefs = CachedSharedPreferences();
  try {
    await _prefs.ctor();
  } catch (e) {
    ampErr('Prefs', 'Initialization failed: ${errorString(e)}');
  }
}

void clear() async {
  if (_prefs == null)
    throw 'HOLY SHIT YOU FUCKED EVERYTHING UP WITH PREFS CLEAR';
  await _prefs.clear();
  ampInfo('Prefs', 'Cleared SharedPreferences.');
}
