import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Amplissimus/dsbutil.dart';
import 'package:Amplissimus/intutils.dart';
import 'package:Amplissimus/json.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G950F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "29 10.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

var dsbApiHomeScaffoldKey = GlobalKey<ScaffoldState>();

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
    if(affectedClass[0] == '0') affectedClass = affectedClass.substring(1);
    return DsbSubstitution(affectedClass.toLowerCase(), parseIntsFromString(hour), teacher, subject, notes, teacher.contains('---'));
  }
  static DsbSubstitution fromElements(dom.Element affectedClass, dom.Element hour, dom.Element teacher, dom.Element subject, dom.Element notes) {
    return fromStrings(_str(affectedClass), _str(hour), _str(teacher), _str(subject), _str(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String _str(dom.Element e) {
    return htmlUnescape(e.innerHtml).replaceAll(RegExp(r'</?.+?>'), '').trim();
  }

  String toString() => "['$affectedClass', $hours, '$teacher', '$subject', '$notes', $isFree]";

  static const Map<String, String> SUBJECT_LOOKUP_TABLE = {
    'spo': 'Sport',
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
    'spr': 'Sprechstunde',
  };

  String get realSubject {
    String sub = subject.toLowerCase();
    String s = subject;
    SUBJECT_LOOKUP_TABLE.forEach((key, value) => { if(sub.startsWith(key)) s = value });
    return s;
  }

  String get title {
    String hour = '';
    for(int h in hours)
      hour += hour == '' ? h.toString() : '-$h';
    return '$hour. Stunde $realSubject';
  }

  String get subtitle {
    String notesaddon = notes.length > 0 ? ' ($notes)' : '';
    return isFree ? 'Freistunde${hours.length == 1 ? '' : 'n'}$notesaddon'
                  : 'Vertreten durch $teacher$notesaddon';
  }

  List<int> get actualHours {
    List<int> h = [];
    for(int i = min(hours); i <= max(hours); i++)
      h.add(i);
    return h;
  }

  String toPlist() {
    String plist =
      '            <dict>\n'
      '                <key>class</key>\n'
      '                <string>${_xmlEscape(affectedClass)}</string>\n'
      '                <key>lessons</key>\n'
      '                <array>\n';
    for(int h in hours)
      plist += '                    <integer>$h</integer>\n';
    plist +=
      '                </array>\n'
      '                <key>teacher</key>\n'
      '                <string>${_xmlEscape(teacher)}</string>\n'
      '                <key>subject</key>\n'
      '                <string>${_xmlEscape(subject)}</string>\n'
      '                <key>notes</key>\n'
      '                <string>${_xmlEscape(notes)}</string>\n'
      '            </dict>\n';
    return plist;
  }

  String toJson() {
    String json =
      '            {\n'
      '                "class": "${_jsonEscape(affectedClass)}",\n'
      '                "lessons": [';
    for(int h in hours)
      json += '$h,';
    json +=
      '],\n'
      '                "teacher": "${_jsonEscape(teacher)}",\n'
      '                "subject": "${_jsonEscape(subject)}",\n'
      '                "notes": "${_jsonEscape(notes)}"\n'
      '            },\n';
    return json;
  }
}

class DsbPlan {
  String title;
  String date;
  List<DsbSubstitution> subs;

  DsbPlan(this.title, this.subs, this.date);

  String toString() => '$title: $subs';

  String toPlist() {
    String plist =
      '    <dict>\n'
      '        <key>title</key>\n'
      '        <string>${_xmlEscape(title)}</string>\n'
      '        <key>date</key>\n'
      '        <string>${_jsonEscape(date)}</string>\n'
      '        <key>subs</key>\n'
      '        <array>\n';
    for(DsbSubstitution sub in subs)
      plist += sub.toPlist();
    plist +=
      '        </array>\n'
      '    </dict>\n';
    return plist;
  }

  String toJson() {
    String json =
      '    {\n'
      '        "title": "${_jsonEscape(title)}",\n'
      '        "date": "${_jsonEscape(date)}",\n'
      '        "subs": [\n';
    for(DsbSubstitution sub in subs)
      json += sub.toJson();
    json +=
      '        ]\n'
      '    },\n';
    return json;
  }
}

Future<String> dsbGetData(String username, String password, {bool cachePostRequests = true}) async {
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
  try {
    return utf8.decode(
      GZipDecoder().decodeBytes(
        base64.decode(
          jsonGetKey(
            jsonDecode(
              await httpPost(
                DSB_WEBSERVICE, '{'
                  '"req": {'
                    '"Data": "${base64.encode(GZipEncoder().encode(utf8.encode(json)))}", '
                    '"DataType": 1'
                  '}'
                '}',
                '$username\t$password',
                {"content-type": "application/json"},
                useCache: cachePostRequests,
              ),
            ), 'd'
          ),
        ),
      ),
    );
  } catch(e) {
    String m = e.toString();
    throw 'Bitte überprüfen Sie Ihre Internetverbindung. (Fehler: $m)';
  }
}

Future<Map<String, String>> dsbGetHtml(String jsontext, {bool cacheGetRequests = true}) async {
  var json = jsonDecode(jsontext);
  if(jsonGetKey(json, 'Resultcode') != 0) throw jsonGetKey(json, 'ResultStatusInfo');
  json = jsonGetIndex(
    jsonGetKey(
      jsonGetIndex(
        jsonGetKey(json, 'ResultMenuItems'),
      ),
      'Childs',
    ),
  );
  Map<String, String> map = {};
  for (var plan in jsonGetKey(jsonGetKey(json, 'Root'), 'Childs'))
    map[
      jsonGetKey(plan, 'Title')
    ] = await httpGet(
      jsonGetKey(
        jsonGetIndex(
          jsonGetKey(plan, 'Childs'),
        ),
        'Detail',
      ),
      useCache: cacheGetRequests,
    );
  return map;
}

Future<List<DsbPlan>> dsbGetAllSubs(String username,  String password, {bool cacheGetRequests = true, bool cachePostRequests = true}) async {
  List<DsbPlan> plans = [];
  Prefs.flushCache();
  String json = await dsbGetData(username, password, cachePostRequests: cachePostRequests);
  var htmls = await dsbGetHtml(json, cacheGetRequests: cacheGetRequests);
  for(var title in htmls.keys) {
    var res = htmls[title];
    try {
      ampInfo(ctx: 'DSB', message: 'Trying to parse $title...');
      List<dom.Element> html = HtmlParser(res).parse().children[0].children[1].children[1].children;
      String planDate = html[0].innerHtml;
      html = html[2].children[0].children[0].children;
      List<DsbSubstitution> subs = [];
      for(int i = 1; i < html.length; i++)
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      plans.add(DsbPlan(planDate.split(' ').last, subs, planDate));
    } catch (e) {
      ampErr(ctx: 'DSB', message: errorString(e));
      plans.add(DsbPlan(title, [], ''));
    }
  }
  return plans;
}

List<DsbPlan> dsbSearchClass(List<DsbPlan> plans, String stage, String char) {
  for(DsbPlan plan in plans) {
    List<DsbSubstitution> subs = [];
    for(DsbSubstitution sub in plan.subs) {
      if(sub.affectedClass.contains(stage) && sub.affectedClass.contains(char)) {
        subs.add(sub);
      }
    }
    plan.subs = subs;
  }
  return plans;
}

List<DsbPlan> dsbSortAllByHour(List<DsbPlan> plans) {
  for(DsbPlan plan in plans)
    plan.subs.sort((a, b) => max(a.hours).compareTo(max(b.hours)));
  return plans;
}

Widget dsbGetGoodList(List<DsbPlan> plans) {
  ampInfo(ctx: 'DSB', message: 'Rendering plans: $plans');
  List<Widget> widgets = [];
  _initializeTheme(widgets, plans);
  
  widgets.add(Padding(padding: EdgeInsets.all(12)));
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

Future<void> dsbUpdateWidget(Function f, {bool cacheGetRequests = true,
                                          bool cachePostRequests = true,
                                          bool cacheJsonPlans = false}) async {
  try {
    if(Prefs.username.length == 0 || Prefs.password.length == 0)
      throw 'Keine Login-Daten eingetragen.';
    String jsonCache = Prefs.dsbJsonCache;
    List<DsbPlan> plans;
    if(!cacheJsonPlans || jsonCache == null) {
      plans = await dsbGetAllSubs(
        Prefs.username,
        Prefs.password,
        cacheGetRequests: cacheGetRequests,
        cachePostRequests: cachePostRequests
      );
      Prefs.dsbJsonCache = toJson(plans);
    } else plans = fromJson(jsonCache);
    if(Prefs.oneClassOnly && Prefs.username.trim().isNotEmpty && Prefs.password.trim().isNotEmpty)
      plans = dsbSortAllByHour(dsbSearchClass(plans, Prefs.grade, Prefs.char));
    dsbWidget = dsbGetGoodList(plans);
  } catch (e) {
    switch (Prefs.currentThemeId) {
      case 0:
        dsbWidget = SizedBox(child: Container(child: Card(
          color: AmpColors.lightForeground,
          child: ListTile(title: CustomValues.isAprilFools ? Text(errorString(e), style: TextStyle(color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1))) : Text(errorString(e), style: TextStyle(color: AmpColors.colorForeground)),)
        ), padding: EdgeInsets.only(top: 15),));
        break;
      case 1:
        dsbWidget = SizedBox(child: Container(child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: AmpColors.colorForeground),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(title: CustomValues.isAprilFools ? Text(errorString(e), style: TextStyle(color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1))) : Text(errorString(e), style: TextStyle(color: AmpColors.colorForeground)),)
        ), padding: EdgeInsets.only(top: 15),));
        break;
      default:
        dsbWidget = SizedBox(child: Container(child: Card(
          color: AmpColors.lightForeground,
          child: ListTile(title: CustomValues.isAprilFools ? Text(errorString(e), style: TextStyle(color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1))) : Text(errorString(e), style: TextStyle(color: AmpColors.colorForeground)),)
        ), padding: EdgeInsets.only(top: 15),));
    }
  }
  f();
}

Widget _getWidget(List<Widget> dayWidgets, int themeId, {AnimationController animController}) {
  switch (themeId) {
    case 0:
      return Card(
        elevation: 0,
        color: AmpColors.lightForeground,
        child: Column(mainAxisSize: MainAxisSize.min, children: dayWidgets),
      );
    case 1:
      return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AmpColors.colorForeground),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: dayWidgets),
      );
    case -1:
      return Card(
        elevation: 0,
        color: AmpColors.lightForeground,
        child: Column(mainAxisSize: MainAxisSize.min, children: dayWidgets),
      );
    default:
      return _getWidget(dayWidgets, 0);
  }
}

void _initializeTheme(List<Widget> widgets, List<DsbPlan> plans) {
  for(DsbPlan plan in plans) {
    List<Widget> dayWidgets = [];
    if(plan.subs.length == 0) {
      dayWidgets.add(ListTile(
        title: Text('Keine Vertretungen', style: TextStyle(color: AmpColors.colorForeground)),
      ));
    }
    int i = 0;
    int iMax = plan.subs.length;
    for(DsbSubstitution sub in plan.subs) {
      String titleSub = sub.title;
      if(CustomValues.isAprilFools) titleSub = '${Random().nextInt(98)+1}.${titleSub.split('.').last}';
      dayWidgets.add(ListTile(
        title: CustomValues.isAprilFools ? Text(titleSub, style: TextStyle(color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1))) : Text(titleSub, style: TextStyle(color: AmpColors.colorForeground)),
        subtitle: CustomValues.isAprilFools ? Text(sub.subtitle, style: TextStyle(color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1))) : Text(sub.subtitle, style: TextStyle(color: AmpColors.colorForeground)),
        trailing: (Prefs.char.isEmpty || Prefs.grade.isEmpty || !Prefs.oneClassOnly) ? Text(sub.affectedClass, style: TextStyle(color: AmpColors.colorForeground)) : Text(''),
      ));
      if(++i != iMax) dayWidgets.add(Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble()));
    }
    widgets.add(ListTile(title: Row(children: <Widget>[
      Text(' ${plan.title}', style: TextStyle(color: AmpColors.colorForeground, fontSize: 22)),
      IconButton(icon: Icon(Icons.info, color: AmpColors.colorForeground,), tooltip: plan.date.split(' ').first, onPressed: () {
        dsbApiHomeScaffoldKey.currentState?.showSnackBar(
          SnackBar(backgroundColor: AmpColors.colorBackground, content: Text(plan.date, style: TextStyle(color: AmpColors.colorForeground),))
        );
      },)
    ])));
    widgets.add(_getWidget(dayWidgets, Prefs.currentThemeId));
  }
}

String _xmlEscape(String s) => s.replaceAll('&', '&amp;')
                                .replaceAll('"', '&quot;')
                                .replaceAll("'", '&apos;')
                                .replaceAll('<', '&lt;')
                                .replaceAll('>', '&gt;');
String _jsonEscape(String s) => s.replaceAll('\\', '\\\\')
                                 .replaceAll('"', '\\"');

String toPlist(List<DsbPlan> plans) {
  String plist =
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
    '<plist version="1.0">\n'
    '<array>\n';
  for(var plan in plans)
    plist += plan.toPlist();
  return '$plist'
         '</array>\n'
         '</plist>\n';
}

String toJson(List<DsbPlan> plans) {
  String json =
    '[\n';
  for(var plan in plans)
    json += plan.toJson();
  return '$json]\n';
}

List<DsbPlan> fromJson(String jsontext) {
  dynamic json = jsonDecode(jsontext);
  List<DsbPlan> plans = [];
  for(dynamic plan in jsonIsList(json)) {
    List<DsbSubstitution> subs = [];
    for(dynamic sub in jsonIsList(jsonGetKey(plan, 'subs'))) {
      String teacher = jsonGetKey(sub, 'teacher');
      List<int> lessons = [];
      for(dynamic lesson in jsonGetKey(sub, 'lessons')) {
        lessons.add(lesson);
      }
      subs.add(DsbSubstitution(jsonGetKey(sub, 'class'),
                               lessons,
                               teacher,
                               jsonGetKey(sub, 'subject'),
                               jsonGetKey(sub, 'notes'),
                               teacher.contains('---')));
    }
    plans.add(DsbPlan(jsonGetKey(plan, 'title'), subs, jsonGetKey(plan, 'date')));
  }
  return plans;
}
