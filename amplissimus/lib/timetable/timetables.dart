//this file is very much in early alpha stage, not finished and has bad performance

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
}

TTDay ttDayFromInt(int i) {
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
    default:
      throw UnimplementedError();
  }
}

int ttDayToInt(TTDay day) {
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
    default:
      throw UnimplementedError();
  }
}

List<DsbPlan> timetablePlans = new List();

List<dynamic> timetableDays = [TTDay.Monday, TTDay.Tuesday];
void updateTimetableDays(List<DsbPlan> plans) {
  timetableDays = new List();
  for (DsbPlan tempPlan in plans) {
    timetableDays.add(ttMatchDay(tempPlan.title.split(' ').last.toLowerCase()));
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
}

class TTColumn {
  List<TTLesson> lessons;
  TTDay day;

  TTColumn(this.lessons, this.day);

  TTColumn.fromJson(Map<String, dynamic> json)
      : lessons =
            lessonsFromJson(List<String>.from(jsonDecode(json['lessons']))),
        day = ttDayFromInt(json['day']);

  Map<String, dynamic> toJson() => {
        'lessons': jsonEncode(lessonsToJson(lessons)),
        'day': ttDayToInt(day),
      };

  List<String> lessonsToJson(List<TTLesson> lessons) {
    List<String> lessonsStrings = [];
    for (TTLesson lesson in lessons) {
      lessonsStrings.add(jsonEncode(lesson.toJson()));
    }
    return lessonsStrings;
  }

  static List<TTLesson> lessonsFromJson(List<String> lessonsStrings) {
    List<TTLesson> tempLessons = new List();
    for (String tempString in lessonsStrings) {
      tempLessons.add(TTLesson.fromJson(jsonDecode(tempString)));
    }
    return tempLessons;
  }
}

TTColumn ttSubColumn(TTColumn column, List<DsbSubstitution> subs) {
  for (int i = 0; i < column.lessons.length; i++) {
    for (DsbSubstitution sub in subs) {
      if (sub.actualHours.contains(i)) {
        column.lessons[i].teacher = sub.teacher;
        column.lessons[i].notes = sub.notes;
        column.lessons[i].isFree = sub.isFree;
      }
    }
  }
  return column;
}

TTDay ttMatchDay(String s) {
  if (s.contains('montag'))
    return TTDay.Monday;
  else if (s.contains('monday'))
    return TTDay.Monday;
  else if (s.contains('dienstag'))
    return TTDay.Tuesday;
  else if (s.contains('tuesday'))
    return TTDay.Tuesday;
  else if (s.contains('mittwoch'))
    return TTDay.Wednesday;
  else if (s.contains('wednesday'))
    return TTDay.Wednesday;
  else if (s.contains('donnerstag'))
    return TTDay.Thursday;
  else if (s.contains('thursday'))
    return TTDay.Thursday;
  else if (s.contains('freitag'))
    return TTDay.Friday;
  else if (s.contains('friday'))
    return TTDay.Friday;
  else
    throw '[TT] Unknown day: $s';
}

List<TTColumn> ttSubTable(List<TTColumn> table, List<DsbPlan> plans) {
  for (DsbPlan plan in plans) {
    for (int i = 0; i < table.length; i++) {
      if (table[i].day == ttMatchDay(plan.title)) {
        table[i] = ttSubColumn(table[i], plan.subs);
      }
    }
  }
  return table;
}

Future<void> saveTimetableToPrefs(List<TTColumn> table) async {
  List<String> tableStrings = [];
  for (TTColumn column in table) {
    tableStrings.add(jsonEncode(column.toJson()));
  }
  Prefs.jsonTimetable = jsonEncode(tableStrings);
}

List<TTColumn> timetableFromPrefs() {
  List<TTColumn> table = [];
  if (Prefs.jsonTimetable == null) return [];
  List<String> tableStrings =
      List<String>.from(jsonDecode(Prefs.jsonTimetable));
  for (String s in tableStrings) {
    print(jsonDecode(s).runtimeType);
    table.add(TTColumn.fromJson(jsonDecode(s)));
  }
  return table;
}

List<Widget> timetableWidget(List<DsbPlan> plans, {bool filtered = true}) {
  List<Widget> widgets = [];
  for (DsbPlan plan in plans) {
    TTDay day = ttMatchDay(plan.title.toLowerCase());
    int ttColumnIndex = TTDay.values.indexOf(day);
    widgets.add(Text(
      '   ${CustomValues.lang.ttDayToString(ttMatchDay(plan.title.toLowerCase()))}',
      style: TextStyle(color: AmpColors.colorForeground, fontSize: 24),
    ));
    List<Widget> unthemedWidgets = [];
    List<TTLesson> lessons = CustomValues.ttColumns[ttColumnIndex].lessons;
    int tempLength = lessons.length;
    for (TTLesson lesson in lessons) {
      String titleString;
      String trailingString;
      if (filtered) {
      } else {
        if (lesson.isFree) {
          titleString = CustomValues.lang.freeLesson;
          trailingString = '';
        } else {
          titleString = lesson.subject;
          trailingString = lesson.teacher;
        }
      }

      unthemedWidgets.add(ListTile(
        title: Text(
          lesson.subject.trim().isEmpty && !lesson.isFree
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
          lesson.notes.trim().isEmpty
              ? CustomValues.lang.notes
              : lesson.notes.trim(),
          style: TextStyle(color: AmpColors.lightForeground, fontSize: 16),
        ),
        trailing: Text(
          lesson.teacher.trim().isEmpty && !lesson.isFree
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
