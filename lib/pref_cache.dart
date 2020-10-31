import 'package:Amplessimus/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CachedSharedPreferences {
  SharedPreferences _prefs;

  bool get isInitialized => _prefs != null;

  Future<bool> setString(String k, String v) => _prefs.setString(k, v);
  Future<bool> setInt(String k, int v) => _prefs.setInt(k, v);
  Future<bool> setDouble(String k, double v) => _prefs.setDouble(k, v);
  Future<bool> setStringList(String k, List<String> v) =>
      _prefs.setStringList(k, v);
  Future<bool> setBool(String k, bool v) => _prefs.setBool(k, v);

  dynamic _get(String key, dynamic dflt, Function(String) f) {
    if (_prefs == null)
      ampWarn('PrefCache', 'Getting $key before initialization is done.');

    return _prefs != null && _prefs.containsKey(key) ? f(key) : dflt;
  }

  Function(String) _pGetInt() => _prefs.getInt;
  Function(String) _pGetDbl() => _prefs.getDouble;
  Function(String) _pGetStr() => _prefs.getString;
  Function(String) _pGetBol() => _prefs.getBool;
  Function(String) _pGetSs() => _prefs.getStringList;
  int getInt(String k, int d) => _get(k, d, _pGetInt());
  double getDouble(String k, double d) => _get(k, d, _pGetDbl());
  String getString(String k, String d) => _get(k, d, _pGetStr());
  bool getBool(String k, bool d) => _get(k, d, _pGetBol());
  List<String> getStringList(String k, List<String> d) => _get(k, d, _pGetSs());

  Future<CachedSharedPreferences> ctor() async {
    ampInfo('CSP', 'I be doin my gettin instance.');
    _prefs = await SharedPreferences.getInstance();
    ampInfo('CSP', 'Got muh instance.');
    return this;
  }

  Future<bool> clear() {
    if (_prefs == null) throw 'PREFS NOT LOADED';
    return _prefs.clear();
  }
}
