import 'dart:convert';

import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/subject.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

List<Day> timetableDays = [Day.Monday, Day.Tuesday];

void updateTimetableDays(List<DsbPlan> plans) {
  timetableDays = [];
  for (var plan in plans) timetableDays.add(plan.day);
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

  static TTLesson get empty => TTLesson('', '', '', false);
}

class TTColumn {
  List<TTLesson> lessons;
  Day day;

  TTColumn(this.lessons, this.day);

  TTColumn.fromJson(Map<String, dynamic> json)
      : lessons = _lessonsFromJson(json['lessons']),
        day = dayFromInt(json['day']);

  Map<String, dynamic> toJson() => {
        'lessons': _lessonsToJson(lessons),
        'day': dayToInt(day),
      };

  List<dynamic> _lessonsToJson(List<TTLesson> lessons) {
    var lessonsStrings = <dynamic>[];
    for (var lesson in lessons) {
      lessonsStrings.add(lesson.toJson());
    }
    return lessonsStrings;
  }

  static List<TTLesson> _lessonsFromJson(List<dynamic> lessonsStrings) {
    var tempLessons = <TTLesson>[];
    for (dynamic tempString in lessonsStrings) {
      tempLessons.add(TTLesson.fromJson(tempString));
    }
    return tempLessons;
  }

  @override
  String toString() => '{$day, $lessons}';
}

const List<Day> ttWeek = [
  Day.Monday,
  Day.Tuesday,
  Day.Wednesday,
  Day.Thursday,
  Day.Friday
];

//applies plans to a copy of table, which is then returned
List<TTColumn> ttSubTable(List<TTColumn> table, List<DsbPlan> plans) {
  var tbl = <TTColumn>[];
  //copy table -> tbl
  for (var c in table) {
    var ls = <TTLesson>[];
    for (var l in c.lessons)
      ls.add(TTLesson(l.subject, l.teacher, l.notes, l.isFree));
    tbl.add(TTColumn(ls, c.day));
  }
  for (var plan in plans) {
    for (var column in tbl) {
      if (column.day == plan.day) {
        for (var i = 0; i < column.lessons.length; i++) {
          for (var sub in plan.subs) {
            if (sub.actualLessons.contains(i + 1) &&
                strcontain(sub.subject, column.lessons[i].subject)) {
              column.lessons[i].teacher = sub.subTeacher;
              column.lessons[i].notes = sub.notes;
              column.lessons[i].isFree = sub.isFree;
            }
          }
        }
      }
    }
  }
  return tbl;
}

String ttToJson(List<TTColumn> tt) {
  if (tt == null) return '[]';
  var columns = [];
  for (var column in tt) columns.add(column.toJson());
  return jsonEncode(columns);
}

List<TTColumn> ttFromJson(String jsontext) {
  if (jsontext == null) return [];
  var table = <TTColumn>[];
  var columns = jsonDecode(jsontext);
  for (var s in columns) table.add(TTColumn.fromJson(s));
  return table;
}

void ttSaveToPrefs(List<TTColumn> tbl) => Prefs.jsonTimetable = ttToJson(tbl);
List<TTColumn> ttLoadFromPrefs() => ttFromJson(Prefs.jsonTimetable);

//if(filtered) table = ttSubTable(table, plans)
//then makes ampLists from table
List<Widget> ttWidgets(
  List<DsbPlan> plans,
  List<TTColumn> table, [
  bool filtered = true,
]) {
  plans = dsbSortByLesson(dsbSearchClass(plans, Prefs.grade, Prefs.char));
  if (filtered) table = ttSubTable(table, plans);
  var widgets = <Widget>[];
  for (var plan in plans) {
    widgets.add(ListTile(
      title: ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
    ));
    var unthemedWidgets = <Widget>[];
    var lessons = table[Day.values.indexOf(plan.day)].lessons;
    var lessonLength = lessons.length;
    for (var lesson in lessons) {
      var title = lesson.isFree
          ? Language.current.freeLesson
          : realSubject(lesson.subject);

      unthemedWidgets.add(ampLessonTile(
        subject: title.trim().isEmpty && !lesson.isFree
            ? Language.current.subject
            : title.trim(),
        lesson: (lessons.indexOf(lesson) + 1).toString(),
        subtitle: lesson.notes.trim().isEmpty
            ? Language.current.notes
            : lesson.notes.trim(),
        trailing: lesson.teacher.trim().isEmpty && !lesson.isFree
            ? Language.current.teacher
            : lesson.teacher.trim(),
      ));
      if (lessons.indexOf(lesson) < lessonLength - 1)
        unthemedWidgets.add(ampSizedDivider(0));
    }
    widgets.add(ampList(unthemedWidgets));
    widgets.add(ampPadding(12));
  }
  return widgets;
}
