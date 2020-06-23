import 'package:Amplissimus/langs/english.dart';
import 'package:Amplissimus/langs/german.dart';

abstract class Language {
  String get code;
  String get name;

  //
  //these are all of the translations hardcoded into the language classes
  //
  String get settingsLightsOn;
  String get settingsLightsOff;
  String get settingsLightsUseSystem;
  String get settingsLightsNoSystem;
  String get settingsChangeAppearance;
  String get settingsChangeLogin;
  String get settingsChangeLoginPopup;
  String get settingsSelectClass;
  String get settingsAppInfo;
  String get appInfo;
  String get menuStart;
  String get menuSettings;

  static final List<Language> _langs = [English(), German()];

  static Language fromCode(String code) {
    if(code == null) return _langs[0];
    for(Language lang in _langs)
      if(code.contains(lang.code) || lang.code.contains(code))
        return lang;
    return _langs[0];
  }
}
