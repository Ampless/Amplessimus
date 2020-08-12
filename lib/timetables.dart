import 'dart:convert';

import 'package:Amplessimus/day.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/utils.dart';
import 'package:flutter/material.dart';

List<dynamic> timetableDays = [Day.Monday, Day.Tuesday];

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
      : lessons = lessonsFromJson(json['lessons']),
        day = dayFromInt(json['day']);

  Map<String, dynamic> toJson() => {
        'lessons': lessonsToJson(lessons),
        'day': dayToInt(day),
      };

  List<dynamic> lessonsToJson(List<TTLesson> lessons) {
    var lessonsStrings = <dynamic>[];
    for (var lesson in lessons) {
      lessonsStrings.add(lesson.toJson());
    }
    return lessonsStrings;
  }

  static List<TTLesson> lessonsFromJson(List<dynamic> lessonsStrings) {
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

List<TTColumn> ttSubTable(List<TTColumn> table, List<DsbPlan> plans) {
  for (var plan in plans) {
    for (var i = 0; i < table.length; i++) {
      if (table[i].day == plan.day) {
        var column = table[i];
        for (var i = 0; i < column.lessons.length; i++) {
          for (var sub in plan.subs) {
            if (sub.actualHours.contains(i + 1) &&
                strcontain(sub.subject, column.lessons[i].subject)) {
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

void ttSaveToPrefs(List<TTColumn> table) =>
    Prefs.jsonTimetable = ttToJson(table);
List<TTColumn> ttLoadFromPrefs() => ttFromJson(Prefs.jsonTimetable);

List<Widget> ttWidgets(
  List<DsbPlan> plans,
  List<TTColumn> columns, [
  bool filtered = true,
]) {
  var tempPlans =
      dsbSortAllByHour(dsbSearchClass(plans, Prefs.grade, Prefs.char));
  var widgets = <Widget>[];
  for (var plan in tempPlans) {
    var ttColumnIndex = Day.values.indexOf(plan.day);
    widgets.add(ListTile(
      title: ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
    ));
    var unthemedWidgets = <Widget>[];
    var lessons = columns[ttColumnIndex].lessons;
    var tempLength = lessons.length;
    for (var lesson in lessons) {
      var finishedFiltering = false, isReplaced = false;
      var lessonIndex = lessons.indexOf(lesson) + 1;
      var titleString = '', trailingString = '', notesString = '';
      if (filtered) {
        if (plan.subs.isEmpty) {
          if (lesson.isFree)
            titleString = Language.current.freeLesson;
          else {
            titleString = lesson.subject;
            trailingString = lesson.teacher;
          }
          notesString = lesson.notes;
        }
        for (var sub in plan.subs) {
          if (!finishedFiltering) {
            if (sub.hours.contains(lessonIndex)) {
              titleString =
                  DsbSubstitution.realSubject(sub.subject, Language.current);
              notesString = Language.current.dsbSubtoSubtitle(sub);
              if (!sub.isFree) {
                trailingString = sub.teacher;
                var notesaddon = sub.notes.isNotEmpty ? ' (${sub.notes})' : '';
                notesString = Language.current.substitution + notesaddon;
              }
              isReplaced = true;
              finishedFiltering = true;
            } else {
              if (lesson.isFree)
                titleString = Language.current.freeLesson;
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
          titleString = Language.current.freeLesson;
        } else {
          titleString = lesson.subject;
          trailingString = lesson.teacher;
        }
        notesString = lesson.notes;
      }

      unthemedWidgets.add(ListTile(
        title: ampText(
          titleString.trim().isEmpty && !lesson.isFree
              ? Language.current.subject
              : titleString.trim(),
          size: 22,
        ),
        leading: ampText(
          (lessons.indexOf(lesson) + 1).toString(),
          weight: FontWeight.bold,
          size: 30,
        ),
        subtitle: ampText(
          notesString.trim().isEmpty
              ? Language.current.notes
              : notesString.trim(),
          size: 16,
        ),
        trailing: ampText(
          trailingString.trim().isEmpty && !isReplaced && !lesson.isFree
              ? Language.current.teacher
              : trailingString.trim(),
          size: 16,
        ),
      ));
      if (lessons.indexOf(lesson) < tempLength - 1)
        unthemedWidgets.add(ampSizedDivider(0));
    }
    widgets.add(getThemedWidget(
        Column(children: unthemedWidgets), Prefs.currentThemeId));
    widgets.add(ampPadding(12));
  }
  return widgets;
}
