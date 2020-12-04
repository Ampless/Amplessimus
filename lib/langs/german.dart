import 'dart:collection';

import 'package:Amplessimus/appinfo.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:Amplessimus/langs/language.dart';

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
  String get alternativeAppearance => 'Alternatives Aussehen';

  @override
  String get changeLogin => 'Login-Daten';

  @override
  String get changeLoginPopup => 'DSBMobile Daten';

  @override
  String get selectClass => 'Klasse auswählen';

  @override
  String get lightsUseSystem => 'System-Design verwenden';

  @override
  String get filterTimetables => 'Stundenplan filtern';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get substitution => 'Vertretung';

  @override
  String dsbSubtoSubtitle(Substitution sub) {
    if (sub == null) return 'null';
    final notesaddon =
        sub.notes != null && sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Freistunde$notesaddon'
        : 'Vertreten durch ${sub.subTeacher}$notesaddon';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Bitte überprüfen Sie Ihre Internetverbindung. (Fehler: $e)';
  }

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
    'ev': 'Evangelische Religion',
    'et': 'Ethik',
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
    'bwl': 'Betriebswirtschaftslehre',
    'c': 'Chemie',
    'k': 'Kunst',
    'ka': 'Katholische Religion',
    'p': 'Physik',
    'ps': 'Psychologie',
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

  @override
  String get dismiss => 'Schließen';

  @override
  String get open => 'Öffnen';

  @override
  String get update => 'Update';

  @override
  String get plsUpdate => 'Eine neue $appTitle-Version ist verfügbar.';

  @override
  String get wpemailDomain => 'WPEmail-Domain';

  @override
  String get openPlanInBrowser => 'Plan im Browser öffnen';

  @override
  String get addWpeDomain => 'WPEmail-Domain hinzufügen';
}
