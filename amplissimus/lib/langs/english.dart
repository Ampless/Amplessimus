import 'dart:collection';

import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/timetable/timetables.dart';

class English extends Language {
  @override
  String get appInfo =>
      'Amplessimus is an app for easily viewing Untis substitution plans using DSBMobile.';

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
    if (sub == null) return 'null';
    var notesaddon =
        sub.notes != null && sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Free lesson${sub.hours.length == 1 ? '' : 's'}$notesaddon'
        : 'Substituted by ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    if (sub == null) return 'null';
    var hour = '';
    if (sub.hours != null) {
      for (var h in sub.hours) {
        if (hour.isNotEmpty) hour += '-';
        hour += h.toString();
        var r = h % 10;
        if (r == 1)
          hour += 'st';
        else if (r == 2)
          hour += 'nd';
        else if (r == 3)
          hour += 'rd';
        else
          hour += 'th';
      }
    } else
      hour = 'null';
    return '$hour lesson ${DsbSubstitution.realSubject(sub.subject, lang: this)}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Please check your internet connection. (Error: $e)';
  }

  @override
  String get dsbListErrorSubtitle =>
      'Please report to Ampless (https://ampless.chrissx.de/amplessimus)';

  @override
  String get dsbListErrorTitle => 'Amplessimus Error';

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
  String get subject => 'Subject';

  @override
  String get notes => 'Notes';

  @override
  String get editHour => 'Edit hour';

  @override
  String get teacher => 'Teacher';

  @override
  String get teacherInput => 'Teacher (last name)';

  @override
  String get freeLesson => 'Free lesson';

  @override
  String get filterTimetables => 'Filter timetables';

  @override
  String get edit => 'Edit';

  @override
  String get substitution => 'Substitution';

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
    'w': 'Economics/Law',
    'nut': '"Nature and Technology"',
    'spr': 'Consultation Hour',
  });

  @override
  String get darkMode => 'Dark mode';

  @override
  String ttDayToString(TTDay day) {
    switch (day) {
      case TTDay.Null:
        return '';
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

  @override
  String get changedAppearance =>
      'Changed the appearance of the substitution plan!';

  @override
  String get show => 'Show';

  @override
  String get useForDsb => 'Use for DSB (not recommended)';
}
