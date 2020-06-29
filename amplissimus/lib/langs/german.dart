import 'dart:collection';

import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/timetable/timetables.dart';

class German extends Language {
  @override
  String get appInfo =>
      'Amplissimus ist eine App, um Untis Vertretungspläne durch DSBMobile einfach anzusehen.';

  @override
  String get code => 'de';

  @override
  String get settings => 'Einstellungen';

  @override
  String get start => 'Start';

  @override
  String get name => 'Deutsch';

  @override
  String get settingsAppInfo => 'App-Informationen';

  @override
  String get changeAppearance => 'Aussehen ändern';

  @override
  String get changeLogin => 'Login-Daten';

  @override
  String get changeLoginPopup => 'DSBMobile Daten';

  @override
  String get lightsOff => 'Licht aus';

  @override
  String get lightsOn => 'Licht an';

  @override
  String get selectClass => 'Klasse auswählen';

  @override
  String get lightsNoSystem => 'System-Aussehen\nnicht verwenden';

  @override
  String get lightsUseSystem => 'System-Aussehen\nverwenden';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    String notesaddon = sub.notes.length > 0 ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Freistunde${sub.hours.length == 1 ? '' : 'n'}$notesaddon'
        : 'Vertreten durch ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    String hour = '';
    for (int h in sub.hours) hour += hour.length == 0 ? h.toString() : '-$h';
    return '$hour. Stunde ${DsbSubstitution.realSubject(sub.subject)}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Bitte überprüfen Sie Ihre Internetverbindung. (Fehler: $e)';
  }

  @override
  String get dsbListErrorSubtitle =>
      'Bitte an Amplus melden (https://amplus.chrissx.de/amplissimus)';

  @override
  String get dsbListErrorTitle => 'Amplissimus-Fehler';

  @override
  String get noLogin => 'Keine Login-Daten eingetragen.';

  @override
  String get empty => 'leer';

  @override
  String get password => 'Passwort';

  @override
  String get username => 'Benutzername';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get allClasses => 'Alle Klassen';

  @override
  String get widgetValidatorFieldEmpty => 'Feld ist leer!';

  @override
  String get widgetValidatorInvalid => 'Ungültige Eingabe!';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get firstStartupDone => 'Fertig';

  @override
  String get timetable => 'Stundenplan';

  @override
  String get setupTimetable => 'Stundenplan\neinrichten';

  @override
  String get setupTimetableTitle => 'Stundenplan einrichten';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Sport',
    'e': 'Englisch',
    'd': 'Deutsch',
    'i': 'Informatik',
    'g': 'Geschichte',
    'geo': 'Geografie',
    'l': 'Latein',
    'it': 'Italienisch',
    'f': 'Französisch',
    'so': 'Sozialkunde',
    'sk': 'Sozialkunde',
    'm': 'Mathematik',
    'mu': 'Musik',
    'b': 'Biologie',
    'c': 'Chemie',
    'k': 'Kunst',
    'p': 'Physik',
    'w': 'Wirtschaft/Recht',
    'spr': 'Sprechstunde',
  });

  @override
  String get darkMode => 'Dark Mode';

  @override
  String ttDayToString(TTDay day) {
    switch (day) {
      case TTDay.Monday:
        return 'Montag';
      case TTDay.Tuesday:
        return 'Dienstag';
      case TTDay.Wednesday:
        return 'Mittwoch';
      case TTDay.Thursday:
        return 'Donnerstag';
      case TTDay.Friday:
        return 'Freitag';
      default:
        throw UnimplementedError('Unbekannter Tag!');
    }
  }
}
