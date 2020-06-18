import 'dart:io';

import 'package:Amplissimus/json.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/values.dart';
import 'package:mutex/mutex.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedSharedPreferences {
  SharedPreferences _prefs;
  RandomAccessFile _prefFile;
  Mutex _prefFileMutex = Mutex();
  List<String> _editsString = [];
  List<String> _editsInt = [];
  List<String> _editsDouble = [];
  List<String> _editsBool = [];
  List<String> _editsStrings = [];
  Map<String, String> _cacheString = {};
  Map<String, int> _cacheInt = {};
  Map<String, double> _cacheDouble = {};
  Map<String, bool> _cacheBool = {};
  Map<String, List<String>> _cacheStrings = {};

  bool _platformSupportsSharedPrefs = !Platform.isWindows && !Platform.isLinux;

  void setString(String key, String value) {
    if(_prefs == null) _editsString.add(key);
    else _prefs.setString(key, value);
    _cacheString[key] = value;
  }

  void setInt(String key, int value) {
    if(_prefs == null) _editsInt.add(key);
    else _prefs.setInt(key, value);
    _cacheInt[key] = value;
  }

  void setDouble(String key, double value) {
    if(_prefs == null) _editsDouble.add(key);
    else _prefs.setDouble(key, value);
    _cacheDouble[key] = value;
  }

  void setStringList(String key, List<String> value) {
    if(_prefs == null) _editsStrings.add(key);
    else _prefs.setStringList(key, value);
    _cacheStrings[key] = value;
  }

  void setBool(String key, bool value) {
    if(_prefs == null) _editsBool.add(key);
    else _prefs.setBool(key, value);
    _cacheBool[key] = value;
  }

  int getInt(String key, int defaultValue) {
    if(_cacheInt.containsKey(key)) return _cacheInt[key];
    if(_prefs == null) {
      if(_platformSupportsSharedPrefs)
        throw 'PREFSI NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    int i = _prefs.getInt(key);
    if(i == null) i = defaultValue;
    return i;
  }

  String getString(String key, String defaultValue) {
    if(_cacheString.containsKey(key)) return _cacheString[key];
    if(_prefs == null) {
      if(_platformSupportsSharedPrefs)
        throw 'PREFSS NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    String s = _prefs.getString(key);
    if(s == null) s = defaultValue;
    return s;
  }

  bool getBool(String key, bool defaultValue) {
    if(_cacheBool.containsKey(key)) return _cacheBool[key];
    if(_prefs == null) {
      if(_platformSupportsSharedPrefs)
        throw 'PREFSB NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    bool b = _prefs.getBool(key);
    if(b == null) b = defaultValue;
    return b;
  }

  List<String> getStringList(String key, List<String> defaultValue) {
    if(_cacheStrings.containsKey(key)) return _cacheStrings[key];
    if(_prefs == null) {
      if(_platformSupportsSharedPrefs)
        throw 'PREFSSL NOT INITIALIZED, THIS IS A SEVERE CODE BUG';
      else
        return defaultValue;
    }
    List<String> s = _prefs.getStringList(key);
    if(s == null) s = defaultValue;
    return s;
  }

  void flush() async {
    if(_prefFile != null && (_cacheString.length > 0 ||
                             _cacheInt.length > 0 ||
                             _cacheDouble.length > 0 ||
                             _cacheBool.length > 0 ||
                             _cacheStrings.length > 0)) {
      await _prefFileMutex.acquire();
      await _prefFile.setPosition(0);
      await _prefFile.writeString('[');
      for(var k in _cacheString.keys)
        await _prefFile.writeString('{"k":"${jsonEscape(k)}","v":"${jsonEscape(_cacheString[k])}","t":"str"},');
      for(var k in _cacheInt.keys)
        await _prefFile.writeString('{"k":"${jsonEscape(k)}","v":${_cacheInt[k]},"t":"int"},');
      for(var k in _cacheDouble.keys)
        await _prefFile.writeString('{"k":"${jsonEscape(k)}","v":${_cacheDouble[k]},"t":"flt"},');
      for(var k in _cacheBool.keys)
        await _prefFile.writeString('{"k":"${jsonEscape(k)}","v":${_cacheBool[k]},"t":"bol"},');
      for(var k in _cacheStrings.keys) {
        await _prefFile.writeString('{"k":"${jsonEscape(k)}","v":[');
        for(var s in _cacheStrings[k])
          await _prefFile.writeString('"${jsonEscape(s)}",');
        await _prefFile.setPosition((await _prefFile.position()) - 1);
        await _prefFile.writeString('],"t":"s[]"},');
      }
      await _prefFile.setPosition((await _prefFile.position()) - 1);
      await _prefFile.writeString(']');
      _prefFileMutex.release();
    }
  }

  Future<void> ctor() async {
    if(_platformSupportsSharedPrefs) {
      _prefs = await SharedPreferences.getInstance();
      for(String key in _editsString) setString(key, _cacheString[key]);
      for(String key in _editsInt) setInt(key, _cacheInt[key]);
      for(String key in _editsDouble) setDouble(key, _cacheDouble[key]);
      for(String key in _editsBool) setBool(key, _cacheBool[key]);
      for(String key in _editsStrings) setStringList(key, _cacheStrings[key]);
      _editsString.clear();
      _editsInt.clear();
      _editsDouble.clear();
      _editsBool.clear();
      _editsStrings.clear();
    } else {
      await _prefFileMutex.acquire();
      _prefFile = await File('.amplissimus_desktop_prealpha_shared_prefs').open(mode: FileMode.append);
      if(await _prefFile.length() > 1) {
        await _prefFile.setPosition(0);
        var bytes = await _prefFile.read(await _prefFile.length());
        var jsontext = String.fromCharCodes(bytes);
        //this kind of creates a race condition, but that doesn't really matter lol
        for(dynamic json in jsonIsList(jsontext)) {
          dynamic key = jsonGetKey(json, 'k');
          dynamic val = jsonGetKey(json, 'v');
          dynamic typ = jsonGetKey(json, 't');
          if(typ == 'str') _cacheString[key] = val;
          else if(typ == 'int') _cacheInt[key] = val;
          else if(typ == 'flt') _cacheDouble[key] = val;
          else if(typ == 'bol') _cacheBool[key] = val;
          else if(typ == 's[]') _cacheStrings[key] = jsonIsList(val);
          else throw 'Prefs doesn\'t know the pref type "$typ".';
        }
      }
      _prefFileMutex.release();
    }
    bool isDarkMode = getBool('is_dark_mode', true);
    ampInfo(ctx: 'Prefs', message: 'recognized isDarkMode = $isDarkMode');
    AmpColors.setMode(isDarkMode);
  }

  void clear() {
    _cacheBool.clear();
    _cacheDouble.clear();
    _cacheInt.clear();
    _cacheString.clear();
    _cacheStrings.clear();
    if(_prefs == null) {
      if(_platformSupportsSharedPrefs)
        throw 'PREFS NOT LODADA D A D AD';
      else return;
    }
    _prefs.clear();
  }
}
