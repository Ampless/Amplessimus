import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'logging.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  final SharedPreferences? _prefs;

  Prefs(this._prefs);

  T _get<T>(String key, T dflt, T? Function(String)? f) {
    return (_prefs != null) ? (f!(key) ?? dflt) : dflt;
  }

  int _getInt(String k, int d) => _get(k, d, _prefs?.getInt);
  String _getString(String k, String d) => _get(k, d, _prefs?.getString);
  bool _getBool(String k, bool d) => _get(k, d, _prefs?.getBool);
  List<String> _getStringList(String k, List<String> d) =>
      _get(k, d, _prefs?.getStringList);

  void _set<T>(String key, T value, Function(String, T)? f) {
    if (_prefs != null) f!(key, value);
  }

  void _setInt(String k, int v) => _set(k, v, _prefs?.setInt);
  void _setString(String k, String v) => _set(k, v, _prefs?.setString);
  void _setBool(String k, bool v) => _set(k, v, _prefs?.setBool);

  //NOTE: collisions would break everything.
  //TODO: evaluate better hashing algorithms
  String _hashCache(String s) => sha1.convert(utf8.encode(s)).toString();

  String? getCache(String url) {
    if (_prefs == null) return null;
    final hash = _hashCache(url);
    if (!_getStringList('CACHE_URLS', []).contains(hash)) {
      ampInfo('prefs', 'HTTP Cache miss: $url');
      return null;
    }
    final ttl = _getInt('CACHE_TTL_$hash', 0);
    if (ttl == 0 || ttl > DateTime.now().millisecondsSinceEpoch) {
      if (!_prefs!.containsKey('CACHE_VAL_$hash')) return null;
      return _prefs!.getString('CACHE_VAL_$hash');
    }
    _prefs!.remove('CACHE_VAL_$hash');
    ampInfo('prefs', 'HTTP Cache TTL reached: $url');
    return null;
  }

  void setCache(String url, String html, Duration ttl) {
    if (_prefs == null) return;
    final hash = _hashCache(url);
    final cachedHashes = _getStringList('CACHE_URLS', []);
    if (!cachedHashes.contains(hash)) cachedHashes.add(hash);
    _prefs!.setStringList('CACHE_URLS', cachedHashes);
    _prefs!.setString('CACHE_VAL_$hash', html);
    _prefs!.setInt(
        'CACHE_TTL_$hash', DateTime.now().add(ttl).millisecondsSinceEpoch);
  }

  void deleteCache(bool Function(String, String, int) isToBeDeleted) {
    if (_prefs == null) return;
    final cachedHashes = _getStringList('CACHE_URLS', []);
    final toRemove = cachedHashes.where((hash) => isToBeDeleted(
        hash,
        _prefs!.getString('CACHE_VAL_$hash')!,
        _prefs!.getInt('CACHE_TTL_$hash')!));
    for (final hash in toRemove) {
      cachedHashes.remove(hash);
      _prefs!.remove('CACHE_VAL_$hash');
      _prefs!.remove('CACHE_TTL_$hash');
      ampInfo('CACHE', 'Removed $hash');
    }
    _prefs!.setStringList('CACHE_URLS', cachedHashes);
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
  set highContrast(bool i) => _setBool('alttheme', i);
  String get username => _getString('dsbuser', '');
  set username(String s) => _setString('dsbuser', s);
  String get password => _getString('dsbpass', '');
  set password(String s) => _setString('dsbpass', s);

  String get classGrade => _getString('grade', '5').trim().toLowerCase();
  set classGrade(String s) => _setString('grade', s.trim().toLowerCase());
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
  set classLetter(String s) => _setString('char', s.trim().toLowerCase());

  bool get oneClassOnly => _getBool('oneclass', false);
  set oneClassOnly(bool b) => _setBool('oneclass', b);
  bool get devOptionsEnabled => _getBool('devoptions', false);
  set devOptionsEnabled(bool b) => _setBool('devoptions', b);
  bool get firstLogin => _getBool('firstlogin', true);
  set firstLogin(bool b) => _setBool('firstlogin', b);
  bool get forceJsonCache => _getBool('alwaysjsoncache', false);
  set forceJsonCache(bool b) => _setBool('alwaysjsoncache', b);
  bool get useSystemTheme => _getBool('systheme', false);
  set useSystemTheme(bool b) => _setBool('systheme', b);
  String get dsbJsonCache => _getString('jsoncache', '');
  set dsbJsonCache(String s) => _setString('jsoncache', s);
  String get wpeDomain => _getString('wpedomain', '');
  set wpeDomain(String s) => _setString('wpedomain', s);
  String get savedLangCode => _getString('lang', Platform.localeName);
  set savedLangCode(String s) => _setString('lang', s);
  bool get updatePopup => _getBool('update', true);
  set updatePopup(bool b) => _setBool('update', b);
  bool get parseSubjects => _getBool('parsesubs', true);
  set parseSubjects(bool b) => _setBool('parsesubs', b);
  bool get groupByClass => _getBool('groupbyclass', true);
  set groupByClass(bool b) => _setBool('groupbyclass', b);

  Timer? _updateTimer;
  Function()? _timerFunction;
  void timerInit(Function() f) {
    _timerFunction = f;
    _updateUpdateTimer(timer);
  }

  int get timer => _getInt('timer', 15);
  set timer(int i) {
    _setInt('timer', i);
    _updateUpdateTimer(i);
  }

  void _updateUpdateTimer(int i) {
    _updateTimer?.cancel();
    _updateTimer =
        Timer.periodic(Duration(minutes: i), (_) => _timerFunction!());
  }

  Future<bool> clear() async {
    if (_prefs == null) return false;
    final success = await _prefs!.clear();
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
    _setBool('darkmode', b);
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
