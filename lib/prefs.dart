import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'logging.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrefs {
  dynamic _() {
    throw 'nope, this is about as fake as life.';
  }

  String? getCache(String url) => _();
  void setCache(String url, String html, Duration ttl) => _();
  void clearCache() => _();
  void listCache() => _();
  void toggleDarkModePressed() => _();
  bool get highContrast => _();
  set highContrast(bool i) => _();
  String get username => _();
  set username(String s) => _();
  String get password => _();
  set password(String s) => _();
  String get classGrade => _();
  set classGrade(String s) => _();
  void Function() setClassGrade(String? v) => _();
  String get classLetter => _();
  set classLetter(String s) => _();
  bool get oneClassOnly => _();
  set oneClassOnly(bool b) => _();
  bool get devOptionsEnabled => _();
  set devOptionsEnabled(bool b) => _();
  bool get firstLogin => _();
  set firstLogin(bool b) => _();
  bool get forceJsonCache => _();
  set forceJsonCache(bool b) => _();
  bool get useSystemTheme => _();
  set useSystemTheme(bool b) => _();
  String get dsbJsonCache => _();
  set dsbJsonCache(String s) => _();
  String get wpeDomain => _();
  set wpeDomain(String s) => _();
  String get savedLangCode => _();
  set savedLangCode(String s) => _();
  bool get updatePopup => _();
  set updatePopup(bool b) => _();
  bool get dsbUseLanguage => _();
  set dsbUseLanguage(bool b) => _();
  bool get parseSubjects => _();
  set parseSubjects(bool b) => _();
  String get dsbLanguage => _();
  void timerInit(Function() f) => _();
  int get timer => _();
  set timer(int i) => _();
  Future<bool> clear() => _();
  set brightness(Brightness b) => _();
  bool get isDarkMode => _();
  set isDarkMode(bool b) => _();
  ThemeData get themeData => _();
}

class Prefs extends FakePrefs {
  final SharedPreferences _prefs;

  Prefs(this._prefs);

  T _get<T>(String key, T dflt, T Function(String) f) {
    return _prefs.containsKey(key) ? f(key) : dflt;
  }

  int _getInt(String k, int d) => _get(k, d, _prefs.getInt);
  String _getString(String k, String d) => _get(k, d, _prefs.getString);
  bool _getBool(String k, bool d) => _get(k, d, _prefs.getBool);
  List<String> _getStringList(String k, List<String> d) =>
      _get(k, d, _prefs.getStringList);

  //this is just a checksum basically so sha1 is fine (collisions are next to impossible)
  //but because it is only 160 bits, it saves 96 bits compared to sha256,
  //which translates to 288 bits / 36 bytes saved per cached url
  //(and also it saves quite a bit of cpu)
  //still there is one consideration: if a school wanted to break this app, they
  //would just have to create collisions. (sha1 makes this a bit harder than md5
  //does) we will switch to something better, once we notice something like that
  //happening.
  String _hashCache(String s) => sha1.convert(utf8.encode(s)).toString();

  String? getCache(String url) {
    final hash = _hashCache(url);
    final cachedHashes = _getStringList('CACHE_URLS', []);
    if (!cachedHashes.contains(hash)) {
      ampInfo('prefs', 'HTTP Cache miss: $url');
      return null;
    }
    final ttl = _getInt('CACHE_TTL_$hash', 0);
    if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) {
      if (!_prefs.containsKey('CACHE_VAL_$hash')) return null;
      return _prefs.getString('CACHE_VAL_$hash');
    }
    _prefs.setString('CACHE_VAL_$hash', null);
    ampInfo('prefs', 'HTTP Cache TTL reached: $url');
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

  //TODO: garbage collect regularly
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

    if (_toggleDarkModePressed > 7) {
      devOptionsEnabled = !devOptionsEnabled;
      _toggleDarkModePressed = 0;
    }
  }

  bool get highContrast => _getBool('alttheme', false);
  set highContrast(bool i) => _prefs.setBool('alttheme', i);
  String get username => _getString('dsbuser', '');
  set username(String s) => _prefs.setString('dsbuser', s);
  String get password => _getString('dsbpass', '');
  set password(String s) => _prefs.setString('dsbpass', s);

//TODO: find a better way to do
  String get classGrade => _getString('grade', '5').trim().toLowerCase();
  set classGrade(String s) => _prefs.setString('grade', s.trim().toLowerCase());
  void Function() setClassGrade(String? v) => () {
        if (v == null) return;
        classGrade = v;
        try {
          if (int.parse(v) > 10) {
            classLetter = '';
          }
          // ignore: empty_catches
        } catch (e) {}
      };
  String get classLetter => _getString('char', 'a').trim().toLowerCase();
  set classLetter(String s) => _prefs.setString('char', s.trim().toLowerCase());

  bool get oneClassOnly => _getBool('oneclass', false);
  set oneClassOnly(bool b) => _prefs.setBool('oneclass', b);
  bool get devOptionsEnabled => _getBool('devoptions', false);
  set devOptionsEnabled(bool b) => _prefs.setBool('devoptions', b);
  bool get firstLogin => _getBool('firstlogin', true);
  set firstLogin(bool b) => _prefs.setBool('firstlogin', b);
  bool get forceJsonCache => _getBool('alwaysjsoncache', false);
  set forceJsonCache(bool b) => _prefs.setBool('alwaysjsoncache', b);
  bool get useSystemTheme => _getBool('systheme', false);
  set useSystemTheme(bool b) => _prefs.setBool('systheme', b);
  String get dsbJsonCache => _getString('jsoncache', '');
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

  Timer? _updateTimer;
  Function()? _timerFunction;
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
    _updateTimer?.cancel();
    _updateTimer =
        Timer.periodic(Duration(minutes: i), (_) => _timerFunction!());
  }

  Future<bool> clear() async {
    final success = await _prefs.clear();
    if (success) ampInfo('prefs', 'Cleared SharedPreferences.');
    return success;
  }

  //COLORS

  set brightness(Brightness b) {
    if (Brightness.values.length > 2) {
      ampWarn('AmpColors.brightness', 'more than 2 Brightness states exist.');
    }
    isDarkMode = b != Brightness.light;
    ampInfo('AmpColors', 'set brightness = $b');
  }

  bool get isDarkMode => _getBool('darkmode', true);
  set isDarkMode(bool b) {
    _prefs.setBool('darkmode', b);
    ampInfo('AmpColors', 'set isDarkMode = $isDarkMode');
  }

  ThemeData get themeData {
    if (isDarkMode) {
      return ThemeData(
        colorScheme: ColorScheme.highContrastDark(),
        backgroundColor: Colors.black,
        cardColor: Colors.transparent,
        shadowColor: Colors.transparent,
        splashColor: Colors.transparent,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black,
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Colors.white,
          disabledActionTextColor: Colors.white30,
        ),
        dividerColor: Colors.white38,
        hoverColor: Colors.transparent,
        dialogBackgroundColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        highlightColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        focusColor: Colors.transparent,
      );
    } else {
      return ThemeData(
        colorScheme: ColorScheme.highContrastLight(),
        backgroundColor: Colors.white,
        cardColor: Colors.transparent,
        shadowColor: Colors.transparent,
        splashColor: Colors.transparent,
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.white,
          contentTextStyle: TextStyle(color: Colors.black),
          actionTextColor: Colors.black,
          disabledActionTextColor: Colors.black38,
        ),
        dividerColor: Colors.black38,
        hoverColor: Colors.transparent,
        dialogBackgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        highlightColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        focusColor: Colors.transparent,
      );
    }
  }
}
