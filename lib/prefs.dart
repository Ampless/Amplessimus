import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/logging.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _prefs;

dynamic _get(String key, dynamic dflt, Function(String) f) {
  if (_prefs == null) {
    ampWarn('PrefCache', 'Getting $key before initialization is done.');
    return dflt;
  }

  return _prefs.containsKey(key) ? f(key) : dflt;
}

int _getInt(String k, int d) => _get(k, d, _prefs.getInt);
String _getString(String k, String d) => _get(k, d, _prefs.getString);
bool _getBool(String k, bool d) => _get(k, d, _prefs.getBool);
List<String> _getStringList(String k, List<String> d) =>
    _get(k, d, _prefs.getStringList);

//this is just a checksum basically so md5 is fine (collisions are next to impossible)
//but because it is only 128 bits, it saves 128 bits compared to sha256,
//which translates to 384 bits / 48 bytes saved per cached url
//(and also it saves quite a bit of cpu)
//still there is one consideration: if a school wanted to break this app, they
//would just have to create collisions. we will switch to something better, once
//we notice something like that happening.
String _hashCache(String s) => md5.convert(utf8.encode(s)).toString();

String getCache(String url) {
  final hash = _hashCache(url);
  final cachedHashes = _getStringList('CACHE_URLS', []);
  if (!cachedHashes.contains(hash)) {
    ampInfo('Prefs', 'HTTP Cache miss: $url');
    return null;
  }
  final ttl = _getInt('CACHE_TTL_$hash', 0);
  if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch)
    return _getString('CACHE_VAL_$hash', null);
  _prefs.setString('CACHE_VAL_$hash', null);
  ampInfo('Prefs', 'HTTP Cache TTL reached: $url');
  return null;
}

void setCache(String url, String html, Duration ttl) {
  final hash = _hashCache(url);
  final cachedHashes = _getStringList('CACHE_URLS', []);
  if (!cachedHashes.contains(hash)) cachedHashes.add(hash);
  _prefs.setStringList('CACHE_URLS', cachedHashes);
  _prefs.setString('CACHE_VAL_$hash', html);
  _prefs.setInt(
      'CACHE_TTL_$hash', DateTime.now().add(ttl).millisecondsSinceEpoch);
}

void clearCache() {
  final cachedHashes = _getStringList('CACHE_URLS', []);
  if (cachedHashes.isEmpty) return;
  for (final hash in cachedHashes) {
    _prefs.setString('CACHE_VAL_$hash', null);
    _prefs.setInt('CACHE_TTL_$hash', null);
    ampInfo('CACHE', 'Removed $hash');
  }
  _prefs.setStringList('CACHE_URLS', []);
}

void listCache() {
  ampRawLog('{');
  for (final hash in _getStringList('CACHE_URLS', []))
    ampRawLog(jsonEncode({
      'hash': hash,
      'len': _getString('CACHE_VAL_$hash', '').length,
      'ttl': _getInt('CACHE_TTL_$hash', -1),
    }));
  ampRawLog('}');
}

int _toggleDarkModePressed = 0;
int _lastToggleDarkModePress = 0;

void toggleDarkModePressed() {
  if (DateTime.now().millisecondsSinceEpoch > _lastToggleDarkModePress + 10000)
    _toggleDarkModePressed = 0;

  _toggleDarkModePressed++;
  _lastToggleDarkModePress = DateTime.now().millisecondsSinceEpoch;

  if (_toggleDarkModePressed >= 10) {
    devOptionsEnabled = !devOptionsEnabled;
    _toggleDarkModePressed = 0;
  }
}

int get currentThemeId => _getInt('current_theme_id', 0);
set currentThemeId(int i) => _prefs.setInt('current_theme_id', i);
String get username => _getString('username_dsb', '');
set username(String s) => _prefs.setString('username_dsb', s);
String get password => _getString('password_dsb', '');
set password(String s) => _prefs.setString('password_dsb', s);
String get grade => _getString('grade', '5').trim().toLowerCase();
set grade(String s) => _prefs.setString('grade', s.trim().toLowerCase());
String get char => _getString('char', 'a').trim().toLowerCase();
set char(String s) => _prefs.setString('char', s.trim().toLowerCase());
bool get oneClassOnly => _getBool('one_class_only', false);
set oneClassOnly(bool b) => _prefs.setBool('one_class_only', b);
bool get devOptionsEnabled => _getBool('dev_options_enabled', false);
set devOptionsEnabled(bool b) => _prefs.setBool('dev_options_enabled', b);
bool get firstLogin => _getBool('first_login', true);
set firstLogin(bool b) => _prefs.setBool('first_login', b);
bool get useJsonCache => _getBool('use_json_cache', false);
set useJsonCache(bool b) => _prefs.setBool('use_json_cache', b);
bool get useSystemTheme => _getBool('use_system_theme', false);
set useSystemTheme(bool b) => _prefs.setBool('use_system_theme', b);
bool get filterTimetables => _getBool('filter_timetables', true);
set filterTimetables(bool b) => _prefs.setBool('filter_timetables', b);
String get dsbJsonCache => _getString('DSB_JSON_CACHE', null);
set dsbJsonCache(String s) => _prefs.setString('DSB_JSON_CACHE', s);
String get wpeDomain => _getString('wpemaildomain', '');
set wpeDomain(String s) => _prefs.setString('wpemaildomain', s);
String get savedLangCode => _getString('lang', Platform.localeName);
set savedLangCode(String s) => _prefs.setString('lang', s);
String get jsonTimetable => _getString('json_timetable', null);
set jsonTimetable(String s) => _prefs.setString('json_timetable', s);
bool get updatePopup => _getBool('update_popup', true);
set updatePopup(bool b) => _prefs.setBool('update_popup', b);

//this is only temporary; the log should be shared pref saved soon
String log = '';

bool get dsbUseLanguage => _getBool('dsb_use_language', false);
set dsbUseLanguage(bool b) => _prefs.setBool('dsb_use_language', b);

String get dsbLanguage => dsbUseLanguage ? savedLangCode : 'de';

Timer _updateTimer;
Function() _timerFunction;
void timerInit(Function() f) {
  _timerFunction = f;
  _updateUpdateTimer(timer);
}

int get timer => _getInt('update_dsb_timer', 15);
set timer(int i) {
  _prefs.setInt('update_dsb_timer', i);
  _updateUpdateTimer(i);
}

void _updateUpdateTimer(int i) {
  if (_updateTimer != null) _updateTimer.cancel();
  _updateTimer = testing
      ? null
      : Timer.periodic(Duration(minutes: i), (_) => _timerFunction());
}

set isDarkMode(bool b) => _prefs.setBool('is_dark_mode', b);
bool get isDarkMode => _getBool('is_dark_mode', true);

Future<Null> load() async {
  _prefs = await SharedPreferences.getInstance();
}

Future<bool> clear() async {
  final success = await _prefs.clear();
  if (success) ampInfo('Prefs', 'Cleared SharedPreferences.');
  return success;
}

bool get isInitialized => _prefs != null;
