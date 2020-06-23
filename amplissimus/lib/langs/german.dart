import 'package:Amplissimus/langs/language.dart';

class German extends Language {
  @override
  String get appInfo => 'Amplissimus ist eine App, um Untis Vertretungspläne durch DSBMobile einfach anzusehen.';

  @override
  String get code => 'de';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuStart => 'Start';

  @override
  String get name => 'Deutsch';

  @override
  String get settingsAppInfo => 'App-Informationen';

  @override
  String get settingsChangeAppearance => 'Aussehen ändern';

  @override
  String get settingsChangeLogin => 'Login-Daten';

  @override
  String get settingsChangeLoginPopup => 'DSBMobile Daten';

  @override
  String get settingsLightsOff => 'Licht aus';

  @override
  String get settingsLightsOn => 'Licht an';

  @override
  String get settingsSelectClass => 'Klasse auswählen';

  @override
  String get settingsLightsNoSystem => 'System-Aussehen nicht verwenden';

  @override
  String get settingsLightsUseSystem => 'System-Aussehen verwenden';
}
