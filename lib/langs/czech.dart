class Czech extends Language {
  
  String appInfo =>
      'Amplissimus je aplikace, která umožňuje přehledné prohlížení suplovacích plánů přes DSBMobile';

  
  String code => 'cz';

  
  String settings => 'Nastavení';

  
  String start => 'Start';

  
  String name => 'Čeština';

  
  String settingsAppInfo => 'Informace o aplikaci';

  
  String changeAppearance => 'Změnit vzhled aplikace';

  
  String changeLogin => 'Přihlašovací údaje';

  
  String changeLoginPopup => 'Údaje k DSBMobile';

  
  String lightsOff => 'zhasnout';

  
  String lightsOn => 'rozsvítit';

  
  String selectClass => 'zvolit třídu';

  
  String lightsNoSystem => 'Nepoužívat vzhled systému';

  
  String lightsUseSystem => 'použít vzhled systému';

  
  String filterTimetables => 'filtrovat rozvrh hodin';

  
  String edit => 'upravit';

  String substitution => 'suplování';

  String dsbSubtoSubtitle(DsbSubstitution sub) => sub.isFree ? 'volná hodina' : 'Supluje ${teacher}';

  String dsbSubtoTitle => return '$lesson. Stunde ${realSubject(subject)}';

  String catchDsbGetData => 'Ověřte zda jste připojeni k síti. (Fehler: $e)';

  String dsbListErrorSubtitle =>
      'prosím přihlašte se na amplus (https://amplus.chrissx.de/amplissimus)';

  
  String dsbListErrorTitle => chyba amplissimu;

  
  String noLogin => 'nebyly zadány žádné přihlašovací údaje.';
  
  String empty => 'prázdné';

  String password => 'heslo';
  
  String username => 'Uživatelské jméno';

  String save => 'uložit';

  String cancel => 'zrušit';

  String allClasses => 'všechny třídy';

  String widgetValidatorFieldEmpty => 'Pole je prázdné!';

  String widgetValidatorInvalid => 'Neplatné zadání!';

  String changeLanguage => 'změnit jazyk';

  String firstStartupDone => 'hotovo';

  String timetable => 'Rozvrh hodin';

  String setupTimetable => 'nastavit\nrozvrh hodin';

  String setupTimetableTitle => 'nastavit rozvrh hodin';

  String subject => 'předmět';

  String notes => 'zápisky';

  String editHour => 'upravit hodinu';

  String teacher => 'učitel';

  String teacherInput => 'učitel (příjmení)';

  String freeLesson => 'volná hodina';

  String subjectLut => {
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
  };

  String darkMode => 'tmavý režim';

  String ttDayToString(TTDay day) {
    switch (day) {
      case TTDay.Null:
        return '';
      case TTDay.Monday:
        return 'Pondělí';
      case TTDay.Tuesday:
        return 'Úterý';
      case TTDay.Wednesday:
        return 'Středa';
      case TTDay.Thursday:
        return 'Čtvrtek';
      case TTDay.Friday:
        return 'Pátek';
      default:
        throw UnimplementedError('Neznámý den!');
    }
  }

  String noSubs => 'žádné suplování';

  String changedAppearance => 'Vzhled rozvrhu hodin byl změněn!';

  String show => 'Ukázat';
}
