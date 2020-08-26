import 'dart:convert';
import 'dart:io';

import 'package:Amplessimus/logging.dart';
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class CachedSharedPreferences extends SharedPreferencesStorePlatform {
  SharedPreferences _prefs;
  RandomAccessFile _prefFile;
  final Mutex _prefFileMutex = Mutex();
  final Map<String, dynamic> _cache = {};

  bool _platformSupportsSharedPrefs;

  // always returns false on windows, but that's fine, because prealpha
  // (this also leads to the "lights on/off wont work" bug i talked about in
  //  a commit comment)
  bool get isInitialized => _platformSupportsSharedPrefs && _prefs != null;

  Future<Null> _set(
    String key,
    dynamic value, [
    bool setCacheAndFlush = true,
  ]) async {
    if (setCacheAndFlush) {
      await _prefFileMutex.acquire();
      _cache[key] = value;
      _prefFileMutex.release();
    }
    if (_prefs != null) {
      if (value is String)
        await _prefs.setString(key, value);
      else if (value is int)
        await _prefs.setInt(key, value);
      else if (value is List)
        await _prefs.setStringList(key, value);
      else if (value is bool)
        await _prefs.setBool(key, value);
      else if (value is double)
        await _prefs.setDouble(key, value);
      else
        ampWarn(
          'PrefCache',
          'value "$value" '
              '(runtimeType: ${value.runtimeType}) '
              'not supported',
        );
    }
    if (setCacheAndFlush) await flush();
  }

  Future<Null> setString(String k, String v) => _set(k, v);
  Future<Null> setInt(String k, int v) => _set(k, v);
  Future<Null> setDouble(String k, double v) => _set(k, v);
  Future<Null> setStringList(String k, List<String> v) => _set(k, v);
  Future<Null> setBool(String k, bool v) => _set(k, v);

  dynamic _get(String key, dynamic defaultValue) {
    if (_prefs == null && _platformSupportsSharedPrefs)
      ampWarn('PrefCache', 'Getting $key before initialization is done.');

    if (_cache.containsKey(key))
      return _cache[key];
    else if (_prefs != null && _prefs.containsKey(key))
      return _prefs.get(key);
    else
      return defaultValue;
  }

  int getInt(String key, int dflt) => _get(key, dflt);
  double getDouble(String key, double dflt) => _get(key, dflt);
  String getString(String key, String dflt) => _get(key, dflt);
  bool getBool(String key, bool dflt) => _get(key, dflt);
  List<String> getStringList(String key, List<String> dflt) => _get(key, dflt);

  String toJson() {
    var prefs = [];
    for (var k in _cache.keys)
      if (_cache[k] != null)
        prefs.add({
          'k': k,
          'v': _cache[k] is bool ? (_cache[k] ? 1 : 0) : _cache[k],
          't': _cache[k] is bool ? 3 : _cache[k] is List<String> ? 4 : -1
        });
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
    await _prefFileMutex.protect(() async {
      for (var k in _cache.keys) await _set(k, _cache[k]);
    });
  }

  // this is a constructor for the prealpha desktop version
  // (only used on windows and hopefully not much longer)
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
        if (typ == 3)
          _cache[key] = val == 1;
        else if (typ == 4) {
          _cache[key] = [];
          for (dynamic s in val) _cache[key].add(s);
        } else
          _cache[key] = val;
      }
    }
    _prefFileMutex.release();
  }

  void checkPlatformSharedPrefSupport() {
    try {
      _platformSupportsSharedPrefs = !Platform.isWindows;
    } catch (e) {
      //it should only fail on web (it doesnt with universal_io)
      _platformSupportsSharedPrefs = true;
    }
  }

  //_platformSupportsSharedPrefs = false;
  //(only used in the tests)
  void platformSharedPrefSupportFalse() {
    _platformSupportsSharedPrefs = false;
  }

  Future<Null> ctor() async {
    checkPlatformSharedPrefSupport();
    await (_platformSupportsSharedPrefs
        ? ctorSharedPrefs
        : ctorPrealphaDesktop)();
  }

  @override
  Future<bool> clear() async {
    await _prefFileMutex.acquire();
    _cache.clear();
    if (_prefs == null) {
      _prefFileMutex.release();
      if (_platformSupportsSharedPrefs)
        throw 'PREFS NOT LOADED';
      else
        return true;
    }
    await _prefs.clear();
    _prefFileMutex.release();
    await flush();
    return true;
  }

  @override
  Future<Map<String, Object>> getAll() async => _cache;

  @override
  Future<bool> remove(String key) => _set(key, null);

  @override
  Future<bool> setValue(String _, String key, Object value) => _set(key, value);
}
