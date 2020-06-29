//this file is very much in early alpha stage, not finished and has bad performance

import 'dart:convert';

import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/json.dart';

enum TTDay {
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
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
      : lessons = lessonsFromJson(jsonDecode(json['lessons'])),
        day = json['day'];

  Map<String, dynamic> toJson() => {
        'lessons': jsonEncode(lessonsToJson(lessons)),
        'day': day,
      };

  List<String> lessonsToJson(List<TTLesson> lessons) {
    List<String> lessonsStrings = [];
    for (TTLesson usage in lessons) {
      lessonsStrings.add(jsonEncode(usage.toJson()));
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

String ttToJson(List<TTColumn> table) {
  List<String> tableStrings = [];
  for (TTColumn column in table) {
    tableStrings.add(jsonEncode(column.toJson()));
  }
  return jsonEncode(tableStrings);
}
