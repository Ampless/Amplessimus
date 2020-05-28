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
  ampInfo(ctx: 'DSBHTTP', message: 'Posting to "$url" with headers "$headers": $body');
  http.Response res = await http.post(url, body: body, headers: headers);
  ampInfo(ctx: 'DSBHTTP', message: 'Got POST-Response with status code ${res.statusCode}: ${res.body}');
  return res;
}

Future<http.Response> httpGet(String url) async {
  ampInfo(ctx: 'DSBHTTP', message: 'Getting from "$url"...');
  http.Response res = await http.get(url);
  ampInfo(ctx: 'DSBHTTP', message: 'Got GET-Response with status code ${res.statusCode}: ${res.body}');
  return res;
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
}

Future<Map<String, String>> dsbGetHtml(String jsontext) async {
  Map<String, String> map = HashMap<String, String>();
  var json = jsonDecode(jsontext);
  if(json['Resultcode'] != 0) throw json['ResultStatusInfo'];
  for (var plan in json['ResultMenuItems'][0]['Childs'][0]['Root']['Childs'])
    map[plan['Title']] = (await httpGet(plan['Childs'][0]['Detail'])).body;
  return map;
}

Future<Map<String, List<DsbSubstitution>>> dsbGetAllSubs(String username, String password) async {
  Map<String, List<DsbSubstitution>> map = new HashMap<String, List<DsbSubstitution>>();
  String json = await getData(username, password);
  Map<String, String> htmls = await dsbGetHtml(json);
  htmls.forEach((title, body) {
    try {
      List<dom.Element> html = HtmlParser(body).parse()
                           .children[0].children[1].children[1]
                           .children[2].children[0].children[0].children;
      List<DsbSubstitution> subs = [];
      for(int i = 1; i < html.length; i++) {
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      }
      map[title] = subs;
    } catch (e) {
      ampErr(ctx: 'DSB', message: e);
      map[title] = [];
    }
  });
  return map;
}

Map<String, List<DsbSubstitution>> dsbSearchClass(Map<String, List<DsbSubstitution>> allSubs, String stage, String letter) {
  stage = stage.toLowerCase();
  letter = letter.toLowerCase();
  Map<String, List<DsbSubstitution>> map = {};
  allSubs.forEach((key, value) {
    List<DsbSubstitution> subs = [];
    for(DsbSubstitution sub in value) {
      String c = sub.affectedClass.toLowerCase();
      if(c.contains(stage) && c.contains(letter)) {
        subs.add(sub);
      }
    }
    map[key] = subs;
  });
  return map;
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

Map<String, List<DsbSubstitution>> dsbSortAllByHour(Map<String, List<DsbSubstitution>> allSubs) {
  Map<String, List<DsbSubstitution>> map = {};
  allSubs.forEach((key, value) {
    map[key] = dsbSortByHour(value);
  });
  return map;
}

Table dsbGetTable(Map<String, List<DsbSubstitution>> allSubs) {
  ampInfo(ctx: 'DSB', message: 'Generating table...');
  List<TableRow> rows = [ TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]) ];
  allSubs.forEach((title, subs) {
    rows.add(TableRow(children: [ Text(' '), Container(), Container(), Container(), Container() ]));
    rows.add(TableRow(children: [ Text(title), Container(), Container(), Container(), Container() ]));
    rows.add(TableRow(children: [ Text('Klasse'), Text('Stunde'), Text('Lehrer*in'), Text('Fach'), Container() ]));
    for(DsbSubstitution sub in subs)
      rows.add(TableRow(children: [
        Text(sub.affectedClass),
        Text(sub.hours.toString()),
        Text(sub.teacher),
        Text(sub.subject),
        Text(sub.notes)
      ]));
  });
  return Table(
    border: TableBorder(
      horizontalInside: BorderSide(width: 1),
      verticalInside: BorderSide(width: 1)
    ),
    children: rows
  );
}

Future<Widget> dsbGetWidget() async {
  return dsbGetTable(dsbSortAllByHour(dsbSearchClass(await dsbGetAllSubs(Prefs.username, Prefs.password), Prefs.grade, Prefs.char)));
}

