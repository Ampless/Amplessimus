import 'dart:collection';

import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/timetable/timetables.dart';

class English extends Language {
  @override
  String get appInfo =>
      'Amplissimus is an App for easily viewing Untis substitution plans using DSBMobile.';

  @override
  String get code => 'en';

  @override
  String get settings => 'Settings';

  @override
  String get start => 'Start';

  @override
  String get name => 'English';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get changeAppearance => 'Change appearance';

  @override
  String get changeLogin => 'Login data';

  @override
  String get changeLoginPopup => 'DSBMobile Login';

  @override
  String get lightsOff => 'Lights off';

  @override
  String get lightsOn => 'Lights on';

  @override
  String get selectClass => 'Select class';

  @override
  String get lightsNoSystem => 'Don\'t use\nsystem appearance';

  @override
  String get lightsUseSystem => 'Use\nsystem appearance';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    String notesaddon = sub.notes.length > 0 ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Free lesson${sub.hours.length == 1 ? '' : 'n'}$notesaddon'
        : 'Substituted by ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    String hour = '';
    for (int h in sub.hours) {
      if (hour.length > 0) hour += '-';
      hour += h.toString();
      int r = h % 10;
      if (r == 1)
        hour += 'st';
      else if (r == 2)
        hour += 'nd';
      else if (r == 3)
        hour += 'rd';
      else
        hour += 'th';
    }
    return '$hour lesson ${DsbSubstitution.realSubject(sub.subject)}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Please check your internet connection. (Error: $e)';
  }

  @override
  String get dsbListErrorSubtitle =>
      'Please report to Amplus (https://amplus.chrissx.de/amplissimus)';

  @override
  String get dsbListErrorTitle => 'Amplissimus Error';

  @override
  String get noLogin => 'No login data entered.';

  @override
  String get empty => 'empty';

  @override
  String get password => 'Password';

  @override
  String get username => 'Username';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get allClasses => 'All classes';

  @override
  String get widgetValidatorFieldEmpty => 'Field is empty!';

  @override
  String get widgetValidatorInvalid => 'Invalid input!';

  @override
  String get changeLanguage => 'Change language';

  @override
  String get firstStartupDone => 'Done';

  @override
  String get timetable => 'Timetable';

  @override
  String get setupTimetable => 'setup\ntimetable';

  @override
  String get setupTimetableTitle => 'Setup Timetable';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Physical Education (sports)',
    'e': 'English',
    'd': 'German',
    'i': 'Computer Science',
    'g': 'History',
    'geo': 'Geography',
    'l': 'Latin',
    'it': 'Italian',
    'f': 'French',
    'so': 'Social Studies (politics)',
    'sk': 'Social Studies (politics)',
    'm': 'Maths',
    'mu': 'Music',
    'b': 'Biology',
    'c': 'Chemistry',
    'k': 'Art',
    'p': 'Physics',
    'w': 'Economy/Law',
    'nut': '"Nature and Technology"',
    'spr': 'Consultation Hour',
  });

  @override
  String get darkMode => 'Dark mode';

  @override
  String ttDayToString(TTDay day) {
    switch (day) {
      case TTDay.Monday:
        return 'Monday';
      case TTDay.Tuesday:
        return 'Tuesday';
      case TTDay.Wednesday:
        return 'Wednesday';
      case TTDay.Thursday:
        return 'Thursday';
      case TTDay.Friday:
        return 'Friday';
      default:
        throw UnimplementedError('Unknown Day!');
    }
  }

  @override
  String get noSubs => 'No substitutions';
}
