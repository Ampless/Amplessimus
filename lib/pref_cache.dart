import 'dart:convert';
import 'dart:io';

import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedSharedPreferences {
  SharedPreferences _prefs;
  RandomAccessFile _prefFile;
  final Mutex _prefFileMutex = Mutex();
  final List<String> _editsString = [];
  final List<String> _editsInt = [];
  final List<String> _editsDouble = [];
  final List<String> _editsBool = [];
  final List<String> _editsStrings = [];
  final Map<String, String> _cacheString = {};
  final Map<String, int> _cacheInt = {};
  final Map<String, double> _cacheDouble = {};
  final Map<String, bool> _cacheBool = {};
  final Map<String, List<String>> _cacheStrings = {};

  bool _platformSupportsSharedPrefs;

  // always returns false on windows, but that's fine, because prealpha
  bool get isInitialized => _platformSupportsSharedPrefs && _prefs != null;

  Future<Null> setString(String key, String value) async {
    await _prefFileMutex.acquire();
    _cacheString[key] = value;
    _prefFileMutex.release();
    if (_prefs != null)
      await _prefs.setString(key, value);
    else if (_prefFile == null) _editsString.add(key);
    await flush();
  }

  Future<Null> setInt(String key, int value) async {
    await _prefFileMutex.acquire();
    _cacheInt[key] = value;
    _prefFileMutex.release();
    if (_prefs != null)
      await _prefs.setInt(key, value);
    else if (_prefFile == null) _editsInt.add(key);
    await flush();
  }

  Future<Null> setDouble(String key, double value) async {
    await _prefFileMutex.acquire();
    _cacheDouble[key] = value;
    _prefFileMutex.release();
    if (_prefs != null)
      await _prefs.setDouble(key, value);
    else if (_prefFile == null) _editsDouble.add(key);
    await flush();
  }

  Future<Null> setStringList(String key, List<String> value) async {
    await _prefFileMutex.acquire();
    _cacheStrings[key] = value;
    _prefFileMutex.release();
    if (_prefs != null)
      await _prefs.setStringList(key, value);
    else if (_prefFile == null) _editsStrings.add(key);
    await flush();
  }

  Future<Null> setBool(String key, bool value) async {
    await _prefFileMutex.acquire();
    _cacheBool[key] = value;
    _prefFileMutex.release();
    if (_prefs != null)
      await _prefs.setBool(key, value);
    else if (_prefFile == null) _editsBool.add(key);
    await flush();
  }

  int getInt(String key, int defaultValue) {
    if (_cacheInt.containsKey(key)) return _cacheInt[key];
    if (_prefs == null) {
      if (_platformSupportsSharedPrefs)
        throw 'PREFSI NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    var i = _prefs.getInt(key);
    i ??= defaultValue;
    return i;
  }

  double getDouble(String key, double defaultValue) {
    if (_cacheDouble.containsKey(key)) return _cacheDouble[key];
    if (_prefs == null) {
      if (_platformSupportsSharedPrefs)
        throw 'PREFSD NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    var d = _prefs.getDouble(key);
    d ??= defaultValue;
    return d;
  }

  String getString(String key, String defaultValue) {
    if (_cacheString.containsKey(key)) return _cacheString[key];
    if (_prefs == null) {
      if (_platformSupportsSharedPrefs)
        throw 'PREFSS NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    var s = _prefs.getString(key);
    s ??= defaultValue;
    return s;
  }

  bool getBool(String key, bool defaultValue) {
    if (_cacheBool.containsKey(key)) return _cacheBool[key];
    if (_prefs == null) {
      if (_platformSupportsSharedPrefs)
        throw 'PREFSB NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    var b = _prefs.getBool(key);
    b ??= defaultValue;
    return b;
  }

  List<String> getStringList(String key, List<String> defaultValue) {
    if (_cacheStrings.containsKey(key)) return _cacheStrings[key];
    if (_prefs == null) {
      if (_platformSupportsSharedPrefs)
        throw 'PREFSSL NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    var s = _prefs.getStringList(key);
    s ??= defaultValue;
    return s;
  }

  String toJson() {
    var prefs = [];
    for (var k in _cacheString.keys)
      if (_cacheString[k] != null)
        prefs.add({'k': k, 'v': _cacheString[k], 't': 0});
    for (var k in _cacheInt.keys)
      if (_cacheInt[k] != null) prefs.add({'k': k, 'v': _cacheInt[k], 't': 1});
    for (var k in _cacheDouble.keys)
      if (_cacheDouble[k] != null)
        prefs.add({'k': k, 'v': _cacheDouble[k], 't': 2});
    for (var k in _cacheBool.keys)
      if (_cacheBool[k] != null)
        prefs.add({'k': k, 'v': _cacheBool[k] ? 1 : 0, 't': 3});
    for (var k in _cacheStrings.keys)
      if (_cacheStrings[k] != null)
        prefs.add({'k': k, 'v': _cacheStrings[k], 't': 4});
    return jsonEncode(prefs);
  }

  Future<Null> flush() async {
    await _prefFileMutex.acquire();
    if (_prefFile != null) {
      await _prefFile.setPosition(0);
      await _prefFile.truncate(0);
      await _prefFile.writeString(toJson());
      await _prefFile.flush();
    }
    _prefFileMutex.release();
  }

  Future<Null> waitForMutex() async {
    await _prefFileMutex.acquire();
    _prefFileMutex.release();
  }

  Future<Null> ctorSharedPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await waitForMutex();
    for (var key in _editsString) await setString(key, _cacheString[key]);
    for (var key in _editsInt) await setInt(key, _cacheInt[key]);
    for (var key in _editsDouble) await setDouble(key, _cacheDouble[key]);
    for (var key in _editsBool) await setBool(key, _cacheBool[key]);
    for (var key in _editsStrings) await setStringList(key, _cacheStrings[key]);
    _editsString.clear();
    _editsInt.clear();
    _editsDouble.clear();
    _editsBool.clear();
    _editsStrings.clear();
  }

  Future<Null> ctorPrealphaDesktop() async {
    await _prefFileMutex.acquire();
    _prefFile =
        await File('.amplissimus_prealpha_data').open(mode: FileMode.append);
    if (await _prefFile.length() > 1) {
      await _prefFile.setPosition(0);
      var bytes = await _prefFile.read(await _prefFile.length());
      //this kind of creates a race condition, but that doesn't really matter lol
      for (dynamic json in jsonDecode(utf8.decode(bytes))) {
        dynamic key = json['k'];
        dynamic val = json['v'];
        dynamic typ = json['t'];
        if (typ == 0)
          _cacheString[key] = val;
        else if (typ == 1)
          _cacheInt[key] = val;
        else if (typ == 2)
          _cacheDouble[key] = val;
        else if (typ == 3)
          _cacheBool[key] = val == 1;
        else if (typ == 4) {
          _cacheStrings[key] = [];
          for (dynamic s in val) _cacheStrings[key].add(s);
        } else
          throw 'Prefs doesn\'t know the pref type "$typ".';
      }
    }
    _prefFileMutex.release();
  }

  void checkPlatformSharedPrefSupport() {
    try {
      _platformSupportsSharedPrefs = !Platform.isWindows;
    } catch (e) {
      //it should only fail on web
      _platformSupportsSharedPrefs = true;
    }
  }

  void platformSharedPrefSupportFalse() {
    _platformSupportsSharedPrefs = false;
  }

  Future<Null> ctor() async {
    checkPlatformSharedPrefSupport();
    await (_platformSupportsSharedPrefs
        ? ctorSharedPrefs
        : ctorPrealphaDesktop)();
  }

  void clear() async {
    await _prefFileMutex.acquire();
    _cacheBool.clear();
    _cacheDouble.clear();
    _cacheInt.clear();
    _cacheString.clear();
    _cacheStrings.clear();
    if (_prefs == null) {
      _prefFileMutex.release();
      if (_platformSupportsSharedPrefs)
        throw 'PREFS NOT LODADA D A D AD';
      else
        return;
    }
    await _prefs.clear();
    _prefFileMutex.release();
    await flush();
  }
}
