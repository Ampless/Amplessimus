import 'package:Amplissimus/langs/language.dart';

class English extends Language {
  @override
  String get appInfo => 'Amplissimus is an App for easily viewing Untis substitution plans using DSBMobile.';

  @override
  String get code => 'en';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuStart => 'Start';

  @override
  String get name => 'English';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsChangeAppearance => 'Change appearance';

  @override
  String get settingsChangeLogin => 'Login data';

  @override
  String get settingsChangeLoginPopup => 'DSBMobile login';

  @override
  String get settingsLightsOff => 'Lights off';

  @override
  String get settingsLightsOn => 'Lights on';

  @override
  String get settingsSelectClass => 'Select class';

  @override
  String get settingsLightsNoSystem => 'Don\'t use system appearance';

  @override
  String get settingsLightsUseSystem => 'Use system appearance';
}
