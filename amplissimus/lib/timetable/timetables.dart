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

class TTLesson {
  String subject;
  String teacher;
  String notes;
  bool isFree;

  TTLesson(this.subject, this.teacher, this.notes, this.isFree);
}

class TTColumn {
  List<TTLesson> lessons;
  TTDay day;

  TTColumn(this.lessons, this.day);
}

TTColumn ttSubColumn(TTColumn column, List<DsbSubstitution> subs) {
  for(int i = 0; i < column.lessons.length; i++) {
    for(DsbSubstitution sub in subs) {
      if(sub.actualHours.contains(i)) {
        column.lessons[i].teacher = sub.teacher;
        column.lessons[i].notes = sub.notes;
        column.lessons[i].isFree = sub.isFree;
      }
    }
  }
  return column;
}

//NOT multi-language yet
TTDay ttMatchDay(String s) {
  if(s.contains('Montag'))
    return TTDay.Monday;
  else if(s.contains('Dienstag'))
    return TTDay.Tuesday;
  else if(s.contains('Mittwoch'))
    return TTDay.Wednesday;
  else if(s.contains('Donnerstag'))
    return TTDay.Thursday;
  else if(s.contains('Freitag'))
    return TTDay.Friday;
  else
    throw '[TT] Unknown day: $s';
}

List<TTColumn> ttSubTable(List<TTColumn> table, List<DsbPlan> plans) {
  for(DsbPlan plan in plans) {
    for(int i = 0; i < table.length; i++) {
      if(table[i].day == ttMatchDay(plan.title)) {
        table[i] = ttSubColumn(table[i], plan.subs);
      }
    }
  }
  return table;
}

String ttLessonToJson(TTLesson lesson)
  => '{"subject":"${lesson.subject}","teacher":"${lesson.teacher}","notes":"${lesson.notes}","free":"${lesson.isFree ? 1 : 0}"},';

String ttColumnToJson(TTColumn column) {
  String s = '';
  for(TTLesson l in column.lessons)
    s += ttLessonToJson(l);
  return '{"day":"${column.day}","lessons":[$s]},';
}

String ttToJson(List<TTColumn> table) {
  String s = '';
  for(var c in table)
    s += ttColumnToJson(c);
  return '[$s]';
}

TTLesson ttLessonFromJson(dynamic json) {
  return TTLesson(jsonGetKey(json, 'subject'),
                  jsonGetKey(json, 'teacher'),
                  jsonGetKey(json, 'notes'),
                  jsonGetKey(json, 'free') == '1' ? true : false);
}

TTColumn ttColumnFromJson(dynamic json) {
  TTDay day = ttMatchDay(jsonGetKey(json, 'day'));
  List<TTLesson> lessons = [];
  for(dynamic lesson in jsonIsList(jsonGetKey(json, 'lessons')))
    lessons.add(ttLessonFromJson(lesson));
  return TTColumn(lessons, day);
}

List<TTColumn> ttFromJson(String jsontext) {
  List<TTColumn> columns = [];
  for(dynamic column in jsonIsList(jsonDecode(jsontext)))
    columns.add(ttColumnFromJson(column));
  return columns;
}
