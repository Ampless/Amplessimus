import 'dart:collection';
import 'dart:convert';
import 'dart:io';

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

String responseToString(http.Response r) {
  return 'Request: \r\n\r\n' + r.request.headers.toString() + '\r\n\r\n' + r.headers.toString() + '\r\n\r\n' + r.body;
}

class DsbAccount {
  String username;
  String password;

  DsbAccount(this.username, this.password);

  Future<String> getData() async {
    String datetime = removeLastChars(DateTime.now().toIso8601String(), 3) + 'Z';
    String uuid = new Uuid().v4();
    String json = '{"UserId":"$username","UserPw":"$password","AppVersion":"$DSB_VERSION","Language":"$DSB_LANGUAGE","OsVersion":"$DSB_OS_VERSION","AppId":"$uuid","Device":"$DSB_DEVICE","BundleId":"$DSB_BUNDLE_ID","Date":"$datetime","LastUpdate":"$datetime"}';
    http.Response res = await http.post(DSB_WEBSERVICE, body: '{"req": {"Data": "${base64.encode(gzip.encode(utf8.encode(json)))}", "DataType": 1}}', headers: HashMap.fromEntries([MapEntry<String, String>("content-type", "application/json")]));
    var jsonResponse = jsonDecode(res.body);
    assert(jsonResponse is Map);
    assert(jsonResponse.containsKey('d'));
    return utf8.decode(gzip.decode(base64.decode(jsonResponse['d'])));
  }
}

class DsbSubstitution {
  String affectedClass;
  String hour;
  String teacher;
  String subject;
  String notes;

  DsbSubstitution(this.affectedClass, this.hour, this.teacher, this.subject, this.notes);

  static DsbSubstitution fromElements(dom.Element affectedClass, dom.Element hour, dom.Element teacher, dom.Element subject, dom.Element notes) {
    return DsbSubstitution(ihu(affectedClass), ihu(hour), ihu(teacher), ihu(subject), ihu(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String ihu(dom.Element e) {
    return HtmlUnescape().convert(e.innerHtml);
  }

  String toString() {
    return "['$affectedClass', '$hour', '$teacher', '$subject', '$notes']";
  }
}

Future<Map<String, String>> dsbGetHtml(String json) async {
  Map<String, String> map = HashMap<String, String>();
  for (var plan in jsonDecode(json)['ResultMenuItems'][0]['Childs'][0]['Root']['Childs'])
    map[plan['Title']] = (await http.get(plan['Childs'][0]['Detail'])).body;
  return map;
}

List<DsbSubstitution> dsbGetSubs(String body) {
  List<dom.Element> html = HtmlParser(body).parse()
                       .children[0].children[1].children[1]
                       .children[2].children[0].children[0].children;
  List<DsbSubstitution> subs = [];
  for(int i = 1; i < html.length; i++) {
    subs.add(DsbSubstitution.fromElementArray(html[i].children));
  }
  return subs;
}

Future<Map<String, List<DsbSubstitution>>> dsbGetAllSubs(String username, String password) async {
  Map<String, List<DsbSubstitution>> map = new HashMap<String, List<DsbSubstitution>>();
  String json = await DsbAccount(username, password).getData();
  Map<String, String> htmls = await dsbGetHtml(json);
  htmls.forEach((title, url) {
    map[title] = dsbGetSubs(url);
  });
  return map;
}

Future<Widget> dsbGetWidget() async {
  return null;
}

