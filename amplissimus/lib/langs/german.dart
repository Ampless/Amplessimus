import 'package:Amplissimus/dsbapi.dart';
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
  String get settingsLightsNoSystem => 'System-Aussehen\nnicht verwenden';

  @override
  String get settingsLightsUseSystem => 'System-Aussehen\nverwenden';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    String notesaddon = sub.notes.length > 0 ? ' (${sub.notes})' : '';
    return sub.isFree ? 'Freistunde${sub.hours.length == 1 ? '' : 'n'}$notesaddon'
                      : 'Vertreten durch ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    String hour = '';
    for(int h in sub.hours)
      hour += hour.length == 0 ? h.toString() : '-$h';
    return '$hour. Stunde ${DsbSubstitution.realSubject(sub.subject)}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Bitte überprüfen Sie Ihre Internetverbindung. (Fehler: $e)';
  }

  @override
  String get dsbListErrorSubtitle => 'Bitte an Amplus melden (https://amplus.chrissx.de/amplissimus)';

  @override
  String get dsbListErrorTitle => 'Amplissimus-Fehler';

  @override
  String get dsbErrorNoLogin => 'Keine Login-Daten eingetragen.';

  @override
  String get classSelectorEmpty => 'Leer';

  @override
  String get settingsChangeLoginPopupPassword => 'Passwort';

  @override
  String get settingsChangeLoginPopupUsername => 'Benutzername';

  @override
  String get settingsChangeLoginPopupSave => 'Speichern';

  @override
  String get settingsChangeLoginPopupCancel => 'Abbrechen';

  @override
  String get dsbUiAllClasses => 'Alle Klassen';

  @override
  String get widgetValidatorFieldEmpty => 'Feld ist leer!';

  @override
  String get widgetValidatorInvalid => 'Ungültige Eingabe!';

  @override
  String get settingsChangeLanguage => 'Sprache ändern';

  @override
  String get firstStartupDone => 'Fertig';
}
