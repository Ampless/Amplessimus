import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'logging.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _prefs;

T _get<T>(String key, T dflt, Function(String) f) {
  if (_prefs == null) {
    ampErr('PrefCache', 'Getting $key before initialization is done.');
    throw 'u tried to get $key ($dflt) before init was done wtf is wrong with u';
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
  if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) {
    return _getString('CACHE_VAL_$hash', null);
  }
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
  for (final hash in _getStringList('CACHE_URLS', [])) {
    ampRawLog(jsonEncode({
      'hash': hash,
      'len': _getString('CACHE_VAL_$hash', '').length,
      'ttl': _getInt('CACHE_TTL_$hash', -1),
    }));
  }
  ampRawLog('}');
}

int _toggleDarkModePressed = 0;
int _lastToggleDarkModePress = 0;

void toggleDarkModePressed() {
  if (DateTime.now().millisecondsSinceEpoch >
      _lastToggleDarkModePress + 10000) {
    _toggleDarkModePressed = 0;
  }

  _toggleDarkModePressed++;
  _lastToggleDarkModePress = DateTime.now().millisecondsSinceEpoch;

  if (_toggleDarkModePressed >= 10) {
    devOptionsEnabled = !devOptionsEnabled;
    _toggleDarkModePressed = 0;
  }
}

bool get altTheme => _getBool('alttheme', false);
set altTheme(bool i) => _prefs.setBool('alttheme', i);
String get username => _getString('dsbuser', '');
set username(String s) => _prefs.setString('dsbuser', s);
String get password => _getString('dsbpass', '');
set password(String s) => _prefs.setString('dsbpass', s);

//TODO: find a better way to do
String get grade => _getString('grade', '5').trim().toLowerCase();
set grade(String s) => _prefs.setString('grade', s.trim().toLowerCase());
String get char => _getString('char', 'a').trim().toLowerCase();
set char(String s) => _prefs.setString('char', s.trim().toLowerCase());

bool get oneClassOnly => _getBool('oneclass', false);
set oneClassOnly(bool b) => _prefs.setBool('oneclass', b);
bool get devOptionsEnabled => _getBool('devoptions', false);
set devOptionsEnabled(bool b) => _prefs.setBool('devoptions', b);
bool get firstLogin => _getBool('firstlogin', true);
set firstLogin(bool b) => _prefs.setBool('firstlogin', b);
bool get useJsonCache => _getBool('alwaysjsoncache', false);
set useJsonCache(bool b) => _prefs.setBool('alwaysjsoncache', b);
bool get useSystemTheme => _getBool('systheme', false);
set useSystemTheme(bool b) => _prefs.setBool('systheme', b);
String get dsbJsonCache => _getString('jsoncache', null);
set dsbJsonCache(String s) => _prefs.setString('jsoncache', s);
String get wpeDomain => _getString('wpedomain', '');
set wpeDomain(String s) => _prefs.setString('wpedomain', s);
String get savedLangCode => _getString('lang', Platform.localeName);
set savedLangCode(String s) => _prefs.setString('lang', s);
bool get updatePopup => _getBool('update', true);
set updatePopup(bool b) => _prefs.setBool('update', b);
bool get dsbUseLanguage => _getBool('usedsblang', false);
set dsbUseLanguage(bool b) => _prefs.setBool('usedsblang', b);
bool get parseSubjects => _getBool('parsesubs', true);
set parseSubjects(bool b) => _prefs.setBool('parsesubs', b);

String get dsbLanguage => dsbUseLanguage ? savedLangCode : 'de';

Timer _updateTimer;
Function() _timerFunction;
void timerInit(Function() f) {
  _timerFunction = f;
  _updateUpdateTimer(timer);
}

int get timer => _getInt('timer', 15);
set timer(int i) {
  _prefs.setInt('timer', i);
  _updateUpdateTimer(i);
}

void _updateUpdateTimer(int i) {
  if (_updateTimer != null) _updateTimer.cancel();
  _updateTimer = Timer.periodic(Duration(minutes: i), (_) => _timerFunction());
}

Future<Null> load() async {
  ampInfo('Prefs', 'Loading SharedPreferences...');
  _prefs = await SharedPreferences.getInstance();
  ampInfo('Prefs', 'SharedPreferences (hopefully successfully) loaded.');
}

Future<bool> clear() async {
  final success = await _prefs.clear();
  if (success) ampInfo('Prefs', 'Cleared SharedPreferences.');
  return success;
}

bool get isInitialized => _prefs != null;

//COLORS

const Color _blankBlack = Color.fromRGBO(0, 0, 0, 1);
const Color _blankWhite = Color.fromRGBO(255, 255, 255, 1);
const Color _greyBlack = Color.fromRGBO(75, 75, 75, 1);
const Color _lightWhite = Color.fromRGBO(25, 25, 25, 1);
const Color _greyWhite = Color.fromRGBO(200, 200, 200, 1);
const Color _lightBlack = Color.fromRGBO(220, 220, 220, 1);

Color get blankGrey => isDarkMode ? _greyBlack : _greyWhite;
Color get lightBackground => isDarkMode ? _lightWhite : _lightBlack;
Color get lightForeground => isDarkMode ? _greyWhite : _greyBlack;
Color get colorBackground => isDarkMode ? _blankBlack : _blankWhite;
Color get colorForeground => isDarkMode ? _blankWhite : _blankBlack;

TextStyle get textStyleForeground => TextStyle(color: colorForeground);

Brightness get brightness => isDarkMode ? Brightness.dark : Brightness.light;
set brightness(Brightness b) {
  if (Brightness.values.length > 2) {
    ampWarn('AmpColors.brightness', 'more than 2 Brightness states exist.');
  }
  if (b == null) return;
  isDarkMode = b != Brightness.light;
  ampInfo('AmpColors', 'set brightness = $b');
}

bool get isDarkMode => isInitialized ? _getBool('darkmode', true) : true;
set isDarkMode(bool b) {
  if (b == null) return;
  _prefs.setBool('darkmode', b);
  ampInfo('AmpColors', 'set isDarkMode = $isDarkMode');
}

void switchMode() => isDarkMode = !isDarkMode;
