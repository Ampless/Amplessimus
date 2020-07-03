import 'dart:convert';

import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
import 'package:flutter/material.dart';

enum TTDay {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Null,
}

TTDay ttDayFromInt(int i) {
  if (i == null) return TTDay.Null;
  switch (i) {
    case 0:
      return TTDay.Monday;
    case 1:
      return TTDay.Tuesday;
    case 2:
      return TTDay.Wednesday;
    case 3:
      return TTDay.Thursday;
    case 4:
      return TTDay.Friday;
    case -1:
      return TTDay.Null;
    default:
      throw UnimplementedError();
  }
}

int ttDayToInt(TTDay day) {
  if (day == null) return -1;
  switch (day) {
    case TTDay.Monday:
      return 0;
    case TTDay.Tuesday:
      return 1;
    case TTDay.Wednesday:
      return 2;
    case TTDay.Thursday:
      return 3;
    case TTDay.Friday:
      return 4;
    case TTDay.Null:
      return -1;
    default:
      throw UnimplementedError();
  }
}

List<DsbPlan> timetablePlans = new List();

List<dynamic> timetableDays = [TTDay.Monday, TTDay.Tuesday];
void updateTimetableDays(List<DsbPlan> plans) {
  timetableDays = new List();
  for (DsbPlan plan in plans) {
    timetableDays.add(plan.day);
  }
  print(timetableDays);
}

class TTLesson {
  String subject;
  String teacher;
  String notes;
  bool isFree;

  TTLesson(this.subject, this.teacher, this.notes, this.isFree);

  TTLesson.fromJson(Map<String, dynamic> json)
      : subject = json['subject'],
        teacher = json['teacher'],
        notes = json['notes'],
        isFree = json['isFree'];

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'teacher': teacher,
        'notes': notes,
        'isFree': isFree,
      };

  @override
  String toString() => '{"$subject", "$teacher", "$notes", $isFree}';
}

class TTColumn {
  List<TTLesson> lessons;
  TTDay day;

  TTColumn(this.lessons, this.day);

  TTColumn.fromJson(Map<String, dynamic> json)
      : lessons = lessonsFromJson(json['lessons']),
        day = ttDayFromInt(json['day']);

  Map<String, dynamic> toJson() => {
        'lessons': lessonsToJson(lessons),
        'day': ttDayToInt(day),
      };

  List<dynamic> lessonsToJson(List<TTLesson> lessons) {
    List<dynamic> lessonsStrings = [];
    for (TTLesson lesson in lessons) {
      lessonsStrings.add(lesson.toJson());
    }
    return lessonsStrings;
  }

  static List<TTLesson> lessonsFromJson(List<dynamic> lessonsStrings) {
    List<TTLesson> tempLessons = new List();
    for (dynamic tempString in lessonsStrings) {
      tempLessons.add(TTLesson.fromJson(tempString));
    }
    return tempLessons;
  }

  @override
  String toString() => '{$day, $lessons}';
}

const List<TTDay> ttWeek = [
  TTDay.Monday,
  TTDay.Tuesday,
  TTDay.Wednesday,
  TTDay.Thursday,
  TTDay.Friday
];

TTDay ttMatchDay(String s) {
  if (s == null || s.length == 0) return TTDay.Null;
  s = s.toLowerCase();
  if (s.contains('null') || s.contains('none'))
    return TTDay.Null;
  else if (s.contains('montag') || s.contains('monday'))
    return TTDay.Monday;
  else if (s.contains('dienstag') || s.contains('tuesday'))
    return TTDay.Tuesday;
  else if (s.contains('mittwoch') || s.contains('wednesday'))
    return TTDay.Wednesday;
  else if (s.contains('donnerstag') || s.contains('thursday'))
    return TTDay.Thursday;
  else if (s.contains('freitag') || s.contains('friday'))
    return TTDay.Friday;
  else
    throw '[TT] Unknown day: $s';
}

bool _subjectsEqual(String s1, String s2) {
  if(s1 == null) return s2 == null;
  if(s2 == null) return false;
  s1 = s1.toLowerCase();
  s2 = s2.toLowerCase();
  return s1.contains(s2) || s2.contains(s1);
}

List<TTColumn> ttSubTable(List<TTColumn> table, List<DsbPlan> plans) {
  for (DsbPlan plan in plans) {
    for (int i = 0; i < table.length; i++) {
      if (table[i].day == plan.day) {
        TTColumn column = table[i];
        for (int i = 0; i < column.lessons.length; i++) {
          for (DsbSubstitution sub in plan.subs) {
            if (sub.actualHours.contains(i + 1) &&
                _subjectsEqual(sub.subject, column.lessons[i].subject)) {
              column.lessons[i].teacher = sub.teacher;
              column.lessons[i].notes = sub.notes;
              column.lessons[i].isFree = sub.isFree;
            }
          }
        }
      }
    }
  }
  return table;
}

Future<Null> saveTimetableToPrefs(List<TTColumn> table) async {
  List<dynamic> tableStrings = [];
  for (TTColumn column in table) {
    tableStrings.add(column.toJson());
  }
  Prefs.jsonTimetable = jsonEncode(tableStrings);
}

List<TTColumn> timetableFromPrefs() {
  List<TTColumn> table = [];
  if (Prefs.jsonTimetable == null) return [];
  List<dynamic> tableStrings = jsonDecode(Prefs.jsonTimetable);
  for (dynamic s in tableStrings) {
    table.add(TTColumn.fromJson(s));
  }
  return table;
}

List<Widget> timetableWidget(List<DsbPlan> plans, {bool filtered = true}) {
  List<DsbPlan> tempPlans =
      dsbSortAllByHour(dsbSearchClass(plans, Prefs.grade, Prefs.char));
  List<Widget> widgets = [];
  for (DsbPlan plan in tempPlans) {
    int ttColumnIndex = TTDay.values.indexOf(plan.day);
    widgets.add(
      ListTile(
          title: Text(' ${CustomValues.lang.ttDayToString(plan.day)}',
              style:
                  TextStyle(color: AmpColors.colorForeground, fontSize: 24))),
    );
    List<Widget> unthemedWidgets = [];
    List<TTLesson> lessons = CustomValues.ttColumns[ttColumnIndex].lessons;
    int tempLength = lessons.length;
    for (TTLesson lesson in lessons) {
      bool finishedFiltering = false;
      int lessonIndex = lessons.indexOf(lesson) + 1;
      String titleString = '';
      String trailingString = '';
      String notesString = '';
      bool isReplaced = false;
      if (filtered) {
        if (plan.subs.isEmpty) {
          if (lesson.isFree)
            titleString = CustomValues.lang.freeLesson;
          else {
            titleString = lesson.subject;
            trailingString = lesson.teacher;
          }
          notesString = lesson.notes;
        }
        for (DsbSubstitution sub in plan.subs) {
          if (!finishedFiltering) {
            if (sub.hours.contains(lessonIndex)) {
              titleString = DsbSubstitution.realSubject(sub.subject);
              notesString = CustomValues.lang.dsbSubtoSubtitle(sub);
              if (!sub.isFree) {
                trailingString = sub.teacher;
                String notesaddon =
                    sub.notes.length > 0 ? ' (${sub.notes})' : '';
                notesString = CustomValues.lang.substitution + notesaddon;
              }
              isReplaced = true;
              finishedFiltering = true;
            } else {
              if (lesson.isFree)
                titleString = CustomValues.lang.freeLesson;
              else {
                titleString = lesson.subject;
                trailingString = lesson.teacher;
              }
              notesString = lesson.notes;
            }
          }
        }
      } else {
        if (lesson.isFree) {
          titleString = CustomValues.lang.freeLesson;
        } else {
          titleString = lesson.subject;
          trailingString = lesson.teacher;
        }
        notesString = lesson.notes;
      }

      unthemedWidgets.add(ListTile(
        title: Text(
          titleString.trim().isEmpty && !lesson.isFree
              ? CustomValues.lang.subject
              : titleString.trim(),
          style: TextStyle(color: AmpColors.colorForeground, fontSize: 22),
        ),
        leading: Text(
          (lessons.indexOf(lesson) + 1).toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AmpColors.colorForeground,
              fontSize: 30),
        ),
        subtitle: Text(
          notesString.trim().isEmpty
              ? CustomValues.lang.notes
              : notesString.trim(),
          style: TextStyle(color: AmpColors.lightForeground, fontSize: 16),
        ),
        trailing: Text(
          trailingString.trim().isEmpty && !isReplaced && !lesson.isFree
              ? CustomValues.lang.teacher
              : trailingString.trim(),
          style: TextStyle(color: AmpColors.lightForeground, fontSize: 16),
        ),
      ));
      if (lessons.indexOf(lesson) < tempLength - 1)
        unthemedWidgets.add(Divider(
          color: AmpColors.colorForeground,
          height: 0,
        ));
    }
    widgets.add(getThemedWidget(
        Column(children: unthemedWidgets), Prefs.currentThemeId));
    widgets.add(Padding(padding: EdgeInsets.all(12)));
  }
  return widgets;
}
