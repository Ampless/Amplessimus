import 'dart:collection';

import 'package:Amplessimus/appinfo.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:Amplessimus/langs/language.dart';

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
  String get alternativeAppearance => 'Alternative appearance';

  @override
  String get changeLogin => 'Login data';

  @override
  String get changeLoginPopup => 'DSBMobile Login';

  @override
  String get selectClass => 'Select class';

  @override
  String get lightsUseSystem => 'Use system design';

  @override
  String dsbSubtoSubtitle(Substitution sub) {
    if (sub == null) return 'null';
    final notesaddon =
        sub.notes != null && sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
    return sub.isFree
        ? 'Free lesson$notesaddon'
        : 'Substituted by ${sub.subTeacher}$notesaddon';
  }

  @override
  String catchDsbGetData(dynamic e) =>
      'Please check your internet connection. (Error: $e)';

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
  String get done => 'Done';

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
  String get freeLesson => 'Free lesson';

  @override
  String get filterTimetables => 'Filter timetables';

  @override
  String get edit => 'Edit';

  @override
  String get substitution => 'Substitution';

  @override
  final LinkedHashMap<String, String> subjectLut = LinkedHashMap.from({
    'spo': 'Physical Education / Sports',
    'e': 'English',
    'ev': 'Protestant Religion',
    'd': 'German',
    'i': 'Computer Science',
    'g': 'History',
    'geo': 'Geography',
    'l': 'Latin',
    'it': 'Italian',
    'f': 'French',
    'so': 'Social Studies / Politics',
    'sk': 'Social Studies / Politics',
    'm': 'Maths',
    'mu': 'Music',
    'b': 'Biology',
    'bwl': 'Business Administration',
    'c': 'Chemistry',
    'k': 'Art',
    'ka': 'Catholic Religion',
    'p': 'Physics',
    'w': 'Economics/Law',
    'nut': '"Nature and Technology"',
    'spr': 'Consultation Hour',
  });

  @override
  String get darkMode => 'Dark mode';

  @override
  String dayToString(Day day) {
    if (day == null) return '';
    switch (day) {
      case Day.Null:
        return '';
      case Day.Monday:
        return 'Monday';
      case Day.Tuesday:
        return 'Tuesday';
      case Day.Wednesday:
        return 'Wednesday';
      case Day.Thursday:
        return 'Thursday';
      case Day.Friday:
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

  @override
  String get dismiss => 'Dismiss';

  @override
  String get open => 'Open';

  @override
  String get update => 'Update';

  @override
  String get plsUpdate => 'A new $appTitle version is available.';

  @override
  String get wpemailDomain => 'WPEmail-Domain';

  @override
  String get openPlanInBrowser => 'Open plan in browser';

  @override
  String get addWpeDomain => 'Add WPEmail-Domain';
}
