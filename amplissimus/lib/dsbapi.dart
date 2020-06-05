import 'dart:convert';
import 'dart:io';

import 'package:amplissimus/dsbutil.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G950F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "29 10.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

class DsbSubstitution {
  String affectedClass;
  List<int> hours;
  String teacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.affectedClass, this.hours, this.teacher, this.subject, this.notes, this.isFree);

  static final int zero = '0'.codeUnitAt(0),
                   nine = '9'.codeUnitAt(0);

  static List<int> parseIntsFromString(String s) {
    List<int> out = [];
    int lastindex = 0;
    for(int i = 0; i < s.length; i++) {
      int c = s[i].codeUnitAt(0);
      if(c < zero || c > nine) {
        if(lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
        lastindex = i + 1;
      }
    }
    out.add(int.parse(s.substring(lastindex, s.length)));
    return out;
  }

  static DsbSubstitution fromStrings(String affectedClass, String hour, String teacher, String subject, String notes) {
    return DsbSubstitution(affectedClass.toLowerCase(), parseIntsFromString(hour), teacher, subject, notes, teacher.contains('---'));
  }
  static DsbSubstitution fromElements(dom.Element affectedClass, dom.Element hour, dom.Element teacher, dom.Element subject, dom.Element notes) {
    return fromStrings(ihu(affectedClass), ihu(hour), ihu(teacher), ihu(subject), ihu(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String ihu(dom.Element e) {
    return htmlUnescape(e.innerHtml).replaceAll(RegExp(r'</?.+?>'), '').trim();
  }

  String toString() {
    return "['$affectedClass', $hours, '$teacher', '$subject', '$notes', $isFree]";
  }

  static const Map<String, String> SUBJECT_LOOKUP_TABLE = {
    'sp': 'Sport',
    'e': 'Englisch',
    'd': 'Deutsch',
    'in': 'Informatik',
    'geo': 'Geografie',
    'ges': 'Geschichte',
    'l': 'Latein',
    'it': 'Italienisch',
    'f': 'Französisch',
    'so': 'Sozialkunde',
    'mu': 'Musik',
    'ma': 'Mathematik',
    'b': 'Biologie',
    'c': 'Chemie',
    'k': 'Kunst',
    'p': 'Physik',
    'w': 'Wirtschaft/Recht',
  };

  String get realSubject {
    String sub = subject.toLowerCase();
    String s = subject;
    SUBJECT_LOOKUP_TABLE.forEach((key, value) => { if(sub.startsWith(key)) s = value });
    return s;
  }

  String title() {
    String hour = '';
    for(int h in hours)
      hour += hour == '' ? h.toString() : '-$h';
    return '$hour. Stunde $realSubject';
  }

  String subtitle() {
    String notesaddon = notes.length > 0 ? ' ($notes)' : '';
    return isFree ? 'Freistunde${hours.length == 1 ? '' : 'n'}$notesaddon'
                  : 'Vertreten durch $teacher$notesaddon';
  }
}

class DsbPlan {
  String title;
  List<DsbSubstitution> subs;

  DsbPlan(this.title, this.subs);

  String get realTitle => title.replaceFirst('Vertretung_M_', '');

  String toString() {
    return '$title: $subs';
  }
}

Future<String> dsbGetData(String username, String password) async {
  String datetime = DateTime.now().toIso8601String().substring(0, 3) + 'Z';
  String json = '{'
      '"UserId":"$username",'
      '"UserPw":"$password",'
      '"AppVersion":"$DSB_VERSION",'
      '"Language":"$DSB_LANGUAGE",'
      '"OsVersion":"$DSB_OS_VERSION",'
      '"AppId":"${v4()}",'
      '"Device":"$DSB_DEVICE",'
      '"BundleId":"$DSB_BUNDLE_ID",'
      '"Date":"$datetime",'
      '"LastUpdate":"$datetime"'
    '}';
  String res = await httpPost(DSB_WEBSERVICE, '{'
      '"req": {'
        '"Data": "${base64.encode(gzip.encode(utf8.encode(json)))}", '
        '"DataType": 1'
      '}'
    '}', headers: Map.fromEntries([MapEntry<String, String>("content-type", "application/json")]));
  var jsonResponse = jsonDecode(res);
  assert(jsonResponse is Map);
  assert(jsonResponse.containsKey('d'));
  return utf8.decode(gzip.decode(base64.decode(jsonResponse['d'])));
}

Future<Map<String, String>> dsbGetHtml(String jsontext) async {
  Map<String, String> map = {};
  var client = http.Client();
  var json = jsonDecode(jsontext);
  assert(json is Map);
  assert(json.containsKey('Resultcode'));
  assert(json.containsKey('ResultStatusInfo'));
  if(json['Resultcode'] != 0) throw json['ResultStatusInfo'];
  assert(json.containsKey('ResultMenuItems'));
  json = json['ResultMenuItems'];
  assert(json is List);
  assert(json.length > 0);
  json = json[0];
  assert(json is Map);
  assert(json.containsKey('Childs'));
  json = json['Childs'];
  assert(json is List);
  assert(json.length > 0);
  json = json[0];
  assert(json is Map);
  assert(json.containsKey('Root'));
  json = json['Root'];
  assert(json is Map);
  assert(json.containsKey('Childs'));
  for (var plan in json['Childs']) {
    String title = plan['Title'];
    String url = plan['Childs'][0]['Detail'];
    ampInfo(ctx: 'HTTP', message: 'Getting from "$url".');
    map[title] = (await client.get(url)).body;
    ampInfo(ctx: 'HTTP', message: 'Got GET-Response.');
  }
  return map;
}

Future<List<DsbPlan>> dsbGetAllSubs(String username, String password) async {
  List<DsbPlan> plans = [];
  String json = await dsbGetData(username, password);
  var htmls = await dsbGetHtml(json);
  for(var title in htmls.keys) {
    var res = htmls[title];
    try {
      ampInfo(ctx: 'DSB', message: 'Trying to parse $title...');
      List<dom.Element> html = HtmlParser(res).parse()
                               .children[0].children[1].children[1]
                               .children[2].children[0].children[0].children;
      List<DsbSubstitution> subs = [];
      for(int i = 1; i < html.length; i++) {
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      }
      plans.add(DsbPlan(title, subs));
    } catch (e) {
      ampErr(ctx: 'DSB', message: errorString(e));
      plans.add(DsbPlan(title, []));
    }
  }
  return plans;
}

List<DsbPlan> dsbSearchClass(List<DsbPlan> plans, String stage, String letter) {
  for(DsbPlan plan in plans) {
    List<DsbSubstitution> subs = [];
    for(DsbSubstitution sub in plan.subs)
      if(sub.affectedClass.contains(stage) && sub.affectedClass.contains(letter))
        subs.add(sub);
    plan.subs = subs;
  }
  return plans;
}

int max(List<int> i) {
  if(i.length == 0) return null;
  int j = i[0];
  for(int k in i)
    if(j < k)
      j = k;
  return j;
}

List<DsbPlan> dsbSortAllByHour(List<DsbPlan> plans) {
  for(DsbPlan plan in plans)
    plan.subs.sort((a, b) => max(a.hours).compareTo(max(b.hours)));
  return plans;
}

Table dsbGetTable(List<DsbPlan> plans) {
  ampInfo(ctx: 'DSB', message: 'Generating table...');
  List<TableRow> rows = [ TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]) ];
  for(DsbPlan plan in plans) {
    rows.add(TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]));
    rows.add(TableRow(children: [ Text(plan.title), Container(), Container(), Container(), Container() ]));
    rows.add(TableRow(children: [ Text('Klasse'), Text('Stunde'), Text('Lehrer*in'), Text('Fach'), Container() ]));
    for(DsbSubstitution sub in plan.subs)
      rows.add(TableRow(children: [
        Text(sub.affectedClass),
        Text(sub.hours.toString()),
        Text(sub.teacher),
        Text(sub.subject),
        Text(sub.notes)
      ]));
  }
  return Table(
    border: TableBorder(
      horizontalInside: BorderSide(width: 1),
      verticalInside: BorderSide(width: 1)
    ),
    children: rows
  );
}

Widget dsbGetGoodList(List<DsbPlan> plans) {
  ampInfo(ctx: 'DSB', message: plans);
  List<Widget> widgets = [];
  for(DsbPlan plan in plans) {
    widgets.add(Text(plan.realTitle, style: TextStyle(color: AmpColors.colorForeground)));
    if(plan.subs.length == 0) {
      widgets.add(ListTile(
        title: Text('Keine Vertretungen', style: TextStyle(color: AmpColors.colorForeground)),
      ));
      widgets.add(Divider(color: AmpColors.colorForeground));
    }
    for(DsbSubstitution sub in plan.subs) {
      widgets.add(ListTile(
        title: Text(sub.title(), style: TextStyle(color: AmpColors.colorForeground)),
        subtitle: Text(sub.subtitle(), style: TextStyle(color: AmpColors.colorForeground)),
      ));
      widgets.add(Divider(color: AmpColors.colorForeground));
    }
  }
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: widgets
  );
}

String errorString(dynamic e) {
  if(e is Error)
    return '$e\r\n${e.stackTrace}';
  return e.toString();
}

Widget dsbWidget = Container();

void dsbUpdateWidget(Function f) async {
  try {
    dsbWidget = dsbGetGoodList(dsbSortAllByHour(dsbSearchClass(await dsbGetAllSubs(Prefs.username, Prefs.password), Prefs.grade, Prefs.char)));
  } catch (e) {
    dsbWidget = Text(errorString(e), style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)));
  }
  f();
}
