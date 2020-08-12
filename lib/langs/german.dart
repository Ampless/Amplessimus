import 'dart:collection';

import 'package:Amplessimus/day.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/subject.dart';

class German extends Language {
  @override
  String get appInfo =>
      'Amplessimus ist eine App, um Untis Vertretungspläne durch DSBMobile einfach anzusehen.';

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
  String get filterTimetables => 'Stundenplan filtern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get substitution => 'Vertretung';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    if (sub == null) return 'null';
    var notesaddon =
        sub.notes != null && sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Freistunde${sub.hours.length == 1 ? '' : 'n'}$notesaddon'
        : 'Vertreten durch ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    if (sub == null) return 'null';
    var hour = '';
    if (sub.hours != null) {
      for (var h in sub.hours) hour += hour.isEmpty ? h.toString() : '-$h';
    } else
      hour = 'null';
    return '$hour. Stunde ${realSubject(sub.subject, this)}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Bitte überprüfen Sie Ihre Internetverbindung. (Fehler: $e)';
  }

  @override
  String get dsbListErrorSubtitle =>
      'Bitte an Ampless melden (https://ampless.chrissx.de/amplessimus)';

  @override
  String get dsbListErrorTitle => 'Amplessimus-Fehler';

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
  String get done => 'Fertig';

  @override
  String get timetable => 'Stundenplan';

  @override
  String get setupTimetable => 'Stundenplan\neinrichten';

  @override
  String get setupTimetableTitle => 'Stundenplan einrichten';

  @override
  String get subject => 'Fach';

  @override
  String get notes => 'Notizen';

  @override
  String get editHour => 'Stunde bearbeiten';

  @override
  String get teacher => 'Lehrer*in';

  @override
  String get freeLesson => 'Freistunde';

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
    'nut': 'Natur und Technik',
    'spr': 'Sprechstunde',
  });

  @override
  String get darkMode => 'Dark Mode';

  @override
  String dayToString(Day day) {
    if (day == null) return '';
    switch (day) {
      case Day.Null:
        return '';
      case Day.Monday:
        return 'Montag';
      case Day.Tuesday:
        return 'Dienstag';
      case Day.Wednesday:
        return 'Mittwoch';
      case Day.Thursday:
        return 'Donnerstag';
      case Day.Friday:
        return 'Freitag';
      default:
        throw UnimplementedError('Unbekannter Tag!');
    }
  }

  @override
  String get noSubs => 'Keine Vertretungen';

  @override
  String get changedAppearance => 'Aussehen des Vertretungsplans geändert!';

  @override
  String get show => 'Anzeigen';

  @override
  String get useForDsb => 'An DSB senden (nicht empfohlen)';
}
