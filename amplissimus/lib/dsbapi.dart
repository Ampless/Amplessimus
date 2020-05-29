import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import 'values.dart';

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G935F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "28 8.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

String removeLastChars(String s, int n) {
  return s.substring(0, s.length - n);
}

Future<http.Response> httpPost(String url, dynamic body, {Map<String, String> headers}) async {
  ampInfo(ctx: 'DSB][HTTP', message: 'Posting to "$url" with headers "$headers": $body');
  http.Response res = await http.post(url, body: body, headers: headers);
  ampInfo(ctx: 'DSB][HTTP', message: 'Got POST-Response with status code ${res.statusCode}.');
  return res;
}

Future<http.Response> httpGet(String url) async {
  ampInfo(ctx: 'DSB][HTTP', message: 'Getting from "$url"...');
  http.Response res = await http.get(url);
  ampInfo(ctx: 'DSB][HTTP', message: 'Got GET-Response with status code ${res.statusCode}.');
  return res;
}

class DsbSubstitution {
  String affectedClass;
  List<int> hours;
  String teacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.affectedClass, this.hours, this.teacher, this.subject, this.notes, this.isFree);

  static List<int> parseIntsFromString(String s) {
    List<int> i = [];
    for(String t in s.split(RegExp('[ -]+')))
      if(t.length != 0)
        i.add(int.parse(t));
    return i;
  }

  static DsbSubstitution fromStrings(String affectedClass, String hour, String teacher, String subject, String notes) {
    return DsbSubstitution(affectedClass, parseIntsFromString(hour), teacher, subject, notes, teacher.contains('---'));
  }
  static DsbSubstitution fromElements(dom.Element affectedClass, dom.Element hour, dom.Element teacher, dom.Element subject, dom.Element notes) {
    return fromStrings(ihu(affectedClass), ihu(hour), ihu(teacher), ihu(subject), ihu(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String ihu(dom.Element e) {
    return HtmlUnescape().convert(e.innerHtml).replaceAll(RegExp(r'</?.+?>', caseSensitive: false), '');
  }

  String toString() {
    return "['$affectedClass', '$hours', '$teacher', '$subject', '$notes', '$isFree']";
  }

  String title() {
    String hour;
    for(int h in hours)
      if(hour == null)
        hour = h.toString();
      else
        hour += '-$h';
    return '$hour. Stunde $subject';
  }

  String subtitle() {
    if(isFree)
      return hours.length == 1 ? 'Freistunde' : 'Freistunden';
    else
      return teacher;
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

Future<String> getData(String username, String password) async {
  String datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
  String uuid = new Uuid().v4();
  String json = '{"UserId":"$username","UserPw":"$password","AppVersion":"$DSB_VERSION","Language":"$DSB_LANGUAGE","OsVersion":"$DSB_OS_VERSION","AppId":"$uuid","Device":"$DSB_DEVICE","BundleId":"$DSB_BUNDLE_ID","Date":"$datetime","LastUpdate":"$datetime"}';
  http.Response res = await httpPost(DSB_WEBSERVICE, '{"req": {"Data": "${base64.encode(gzip.encode(utf8.encode(json)))}", "DataType": 1}}', headers: HashMap.fromEntries([MapEntry<String, String>("content-type", "application/json")]));
  var jsonResponse = jsonDecode(res.body);
  assert(jsonResponse is Map);
  assert(jsonResponse.containsKey('d'));
  return utf8.decode(gzip.decode(base64.decode(jsonResponse['d'])));
}

Map<String, Future<http.Response>> dsbGetHtml(String jsontext) {
  Map<String, Future<http.Response>> map = {};
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
  for (var plan in json['Childs'])
    map[plan['Title']] = httpGet(plan['Childs'][0]['Detail']);
  return map;
}

Future<List<DsbPlan>> dsbGetAllSubs(String username, String password) async {
  List<DsbPlan> plans = [];
  String json = await getData(username, password);
  var htmls = dsbGetHtml(json);
  for(var title in htmls.keys) {
    var res = htmls[title];
    try {
      ampInfo(ctx: 'DSB', message: 'Trying to parse $title...');
      List<dom.Element> html = HtmlParser((await res).body).parse()
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
  stage = stage.toLowerCase();
  letter = letter.toLowerCase();
  List<DsbPlan> newPlans = [];
  for(DsbPlan plan in plans) {
    List<DsbSubstitution> subs = [];
    for(DsbSubstitution sub in plan.subs) {
      String c = sub.affectedClass.toLowerCase();
      if(c.contains(stage) && c.contains(letter)) {
        subs.add(sub);
      }
    }
    newPlans.add(DsbPlan(plan.title, subs));
  }
  return newPlans;
}

int max(List<int> i) {
  if(i.length == 0) return null;
  int j = i[0];
  for(int k in i)
    if(j < k)
      j = k;
  return j;
}

List<DsbSubstitution> dsbSortByHour(List<DsbSubstitution> subs) {
  subs.sort((a, b) => max(a.hours).compareTo(max(b.hours)));
  return subs;
}

List<DsbPlan> dsbSortAllByHour(List<DsbPlan> plans) {
  List<DsbPlan> newPlans = [];
  for(DsbPlan plan in plans)
    newPlans.add(DsbPlan(plan.title, dsbSortByHour(plan.subs)));
  return newPlans;
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

Future<Widget> dsbGetWidget(Function f) async {
  try {
    dsbWidget = dsbGetGoodList(dsbSortAllByHour(dsbSearchClass(await dsbGetAllSubs(Prefs.username, Prefs.password), Prefs.grade, Prefs.char)));
  } catch (e) {
    dsbWidget = Text('\r\n\r\n${errorString(e)}');
  }
  if(f != null) f();
  return dsbWidget;
}

