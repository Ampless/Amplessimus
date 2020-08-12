import 'dart:collection';

import 'package:Amplessimus/day.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';

class Czech extends Language {
  @override
  String get appInfo =>
      'Amplissimus je aplikace, která umožňuje přehledné prohlížení suplovacích plánů přes DSBMobile';

  @override
  String get code => 'cz';

  @override
  String get settings => 'Nastavení';

  @override
  String get start => 'Start';

  @override
  String get name => 'Čeština';

  @override
  String get settingsAppInfo => 'Informace o aplikaci';

  @override
  String get changeAppearance => 'Změnit vzhled aplikace';

  @override
  String get changeLogin => 'Přihlašovací údaje';

  @override
  String get changeLoginPopup => 'Údaje k DSBMobile';

  @override
  String get lightsOff => 'zhasnout';

  @override
  String get lightsOn => 'rozsvítit';

  @override
  String get selectClass => 'zvolit třídu';

  @override
  String get lightsNoSystem => 'Nepoužívat vzhled systému';

  @override
  String get lightsUseSystem => 'použít vzhled systému';

  @override
  String get filterTimetables => 'filtrovat rozvrh hodin';

  @override
  String get edit => 'upravit';

  @override
  String get substitution => 'suplování';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    if (sub == null) return 'null';
    return sub.isFree ? 'volná hodina' : 'Supluje ${sub.teacher}';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    if (sub == null) return 'null';
    var s = '';
    if (sub.hours == null)
      s = 'null';
    else
      for (var h in sub.hours) s += s.isEmpty ? h.toString() : '-$h';
    return '$s. hodina ${DsbSubstitution.realSubject(sub.subject, this)}';
  }

  @override
  String catchDsbGetData(e) => 'Ověřte zda jste připojeni k síti. (Fehler: $e)';

  @override
  String get dsbListErrorSubtitle =>
      'prosím přihlašte se na ampless (ampless.chrissx.de)';

  @override
  String get dsbListErrorTitle => 'chyba amplessimu';

  @override
  String get noLogin => 'nebyly zadány žádné přihlašovací údaje.';

  @override
  String get empty => 'prázdné';

  @override
  String get password => 'heslo';

  @override
  String get username => 'Uživatelské jméno';

  @override
  String get save => 'uložit';

  @override
  String get cancel => 'zrušit';

  @override
  String get allClasses => 'všechny třídy';

  @override
  String get widgetValidatorFieldEmpty => 'Pole je prázdné!';

  @override
  String get widgetValidatorInvalid => 'Neplatné zadání!';

  @override
  String get changeLanguage => 'změnit jazyk';

  @override
  String get done => 'hotovo';

  @override
  String get timetable => 'Rozvrh hodin';

  @override
  String get setupTimetable => 'nastavit\nrozvrh hodin';

  @override
  String get setupTimetableTitle => 'nastavit rozvrh hodin';

  @override
  String get subject => 'předmět';

  @override
  String get notes => 'zápisky';

  @override
  String get editHour => 'upravit hodinu';

  @override
  String get teacher => 'učitel';

  @override
  String get freeLesson => 'volná hodina';

  @override
  LinkedHashMap<String, String> get subjectLut => LinkedHashMap.from({
        'spo': 'tělesná výchova',
        'e': 'Anglický jazyk',
        'd': 'Německý jazyk',
        'i': 'Informatika',
        'g': 'Dějepis',
        'geo': 'Zeměpis',
        'l': 'Latinský jazyk',
        'it': 'Italský jazyk',
        'f': 'Francouzský jazyk',
        'so': 'Společenské vědy',
        'sk': 'Společenské vědy',
        'm': 'Matematika',
        'mu': 'Hudební výchova',
        'b': 'Biologie',
        'c': 'Chemie',
        'k': 'Výtvarná výchova',
        'p': 'Fyzika',
        'w': 'Ekonomika a právo',
        'nut': 'Příroda a technika',
        'spr': 'Konverzační hodina',
      });

  @override
  String get darkMode => 'tmavý režim';

  @override
  String dayToString(Day day) {
    if (day == null) return '';
    switch (day) {
      case Day.Null:
        return '';
      case Day.Monday:
        return 'Pondělí';
      case Day.Tuesday:
        return 'Úterý';
      case Day.Wednesday:
        return 'Středa';
      case Day.Thursday:
        return 'Čtvrtek';
      case Day.Friday:
        return 'Pátek';
      default:
        throw UnimplementedError('Neznámý den!');
    }
  }

  @override
  String get noSubs => 'žádné suplování';

  @override
  String get changedAppearance => 'Vzhled rozvrhu hodin byl změněn!';

  @override
  String get show => 'Ukázat';

  @override
  String get useForDsb => 'Použít pro DSB (nedoporučeno)';
}
