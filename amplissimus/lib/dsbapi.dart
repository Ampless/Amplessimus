import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:Amplissimus/dsbutil.dart';
import 'package:Amplissimus/intutils.dart';
import 'package:Amplissimus/json.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/xml.dart';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

const String _DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String _DSB_DEVICE = "SM-G950F";
const String _DSB_VERSION = "2.5.9";
const String _DSB_OS_VERSION = "29 10.0";
const String _DSB_LANGUAGE = "de";

var dsbApiHomeScaffoldKey = GlobalKey<ScaffoldState>();

class DsbSubstitution {
  String affectedClass;
  List<int> hours;
  String teacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.affectedClass, this.hours, this.teacher, this.subject,
      this.notes, this.isFree);

  DsbSubstitution.fromJson(Map<String, dynamic> json)
      : affectedClass = json['affectedClass'],
        hours = List<int>.from(jsonDecode(json['hours'])),
        teacher = json['teacher'],
        subject = json['subject'],
        notes = json['notes'],
        isFree = json['isFree'];

  Map<String, dynamic> toJson() => {
        'affectedClass': affectedClass,
        'hours': jsonEncode(hours),
        'teacher': teacher,
        'subject': subject,
        'notes': notes,
        'isFree': isFree,
      };

  static final int zero = '0'.codeUnitAt(0), nine = '9'.codeUnitAt(0);

  static List<int> parseIntsFromString(String s) {
    List<int> out = [];
    int lastindex = 0;
    for (int i = 0; i < s.length; i++) {
      int c = s[i].codeUnitAt(0);
      if (c < zero || c > nine) {
        if (lastindex != i) out.add(int.parse(s.substring(lastindex, i)));
        lastindex = i + 1;
      }
    }
    out.add(int.parse(s.substring(lastindex, s.length)));
    return out;
  }

  static DsbSubstitution fromStrings(String affectedClass, String hour,
      String teacher, String subject, String notes) {
    if (affectedClass.codeUnitAt(0) == zero)
      affectedClass = affectedClass.substring(1);
    return DsbSubstitution(
        affectedClass.toLowerCase(),
        parseIntsFromString(hour),
        teacher,
        subject,
        notes,
        teacher.contains('---'));
  }

  static DsbSubstitution fromElements(
      dom.Element affectedClass,
      dom.Element hour,
      dom.Element teacher,
      dom.Element subject,
      dom.Element notes) {
    return fromStrings(_str(affectedClass), _str(hour), _str(teacher),
        _str(subject), _str(notes));
  }

  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(
        elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String _str(dom.Element e) {
    return e.innerHtml.replaceAll(RegExp(r'</?.+?>'), '').trim();
  }

  String toString() =>
      "['$affectedClass', $hours, '$teacher', '$subject', '$notes', $isFree]";

  static bool _isNum(String s, int i) {
    int codeUnit = s.codeUnitAt(i);
    return codeUnit >= zero && codeUnit <= nine;
  }

  static final Pattern _letters = RegExp(r'[a-zA-Z]');
  static final Pattern _numeric = RegExp(r'[0-9]');

  static String realSubject(String subject) {
    if (_isNum(subject, 0) || _isNum(subject, subject.length - 1))
      return '${realSubject(subject.substring(subject.indexOf(_letters), subject.lastIndexOf(_letters) + 1))} '
          '${subject.substring(subject.lastIndexOf(_numeric))} (${subject.substring(0, subject.indexOf(_letters))})';
    String sub = subject.toLowerCase();
    String s = subject;
    CustomValues.lang.subjectLut.forEach((key, value) {
      if (sub.startsWith(key)) s = value;
    });
    return s;
  }

  List<int> get actualHours {
    List<int> h = [];
    for (int i = min(hours); i <= max(hours); i++) h.add(i);
    return h;
  }

  String toPlist() {
    String plist = '            <dict>\n'
        '                <key>class</key>\n'
        '                <string>${xmlEscape(affectedClass)}</string>\n'
        '                <key>lessons</key>\n'
        '                <array>\n';
    for (int h in hours) plist += '                    <integer>$h</integer>\n';
    plist += '                </array>\n'
        '                <key>teacher</key>\n'
        '                <string>${xmlEscape(teacher)}</string>\n'
        '                <key>subject</key>\n'
        '                <string>${xmlEscape(subject)}</string>\n'
        '                <key>notes</key>\n'
        '                <string>${xmlEscape(notes)}</string>\n'
        '            </dict>\n';
    return plist;
  }
}

class DsbPlan {
  TTDay day;
  String date;
  List<DsbSubstitution> subs;

  DsbPlan(this.day, this.subs, this.date);

  DsbPlan.fromJson(Map<String, dynamic> json)
      : day = ttDayFromInt(json['day']),
        date = json['date'],
        subs = subsFromJson(List<String>.from(jsonDecode(json['subs'])));

  Map<String, dynamic> toJson() => {
        'day': ttDayToInt(day),
        'date': date,
        'subs': jsonEncode(subsToJson(subs)),
      };

  List<String> subsToJson(List<DsbSubstitution> subs) {
    List<String> lessonsStrings = [];
    for (DsbSubstitution usage in subs) {
      lessonsStrings.add(jsonEncode(usage.toJson()));
    }
    return lessonsStrings;
  }

  static List<DsbSubstitution> subsFromJson(List<String> subsStrings) {
    List<DsbSubstitution> tempSubs = new List();
    for (String tempString in subsStrings) {
      tempSubs.add(DsbSubstitution.fromJson(jsonDecode(tempString)));
    }
    return tempSubs;
  }

  String toString() => '$day: $subs';

  String toPlist() {
    String plist = '    <dict>\n'
        '        <key>day</key>\n'
        '        <string>${ttDayToInt(day)}</string>\n'
        '        <key>date</key>\n'
        '        <string>${jsonEscape(date)}</string>\n'
        '        <key>subs</key>\n'
        '        <array>\n';
    for (DsbSubstitution sub in subs) plist += sub.toPlist();
    plist += '        </array>\n'
        '    </dict>\n';
    return plist;
  }
}

Future<String> dsbGetData(String username, String password,
    {String apiEndpoint = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData',
    bool cachePostRequests = true,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers,
            {bool useCache})
        httpPost = httpPost,
    @required Language lang}) async {
  String datetime = DateTime.now().toIso8601String().substring(0, 3) + 'Z';
  String json = '{'
      '"UserId":"$username",'
      '"UserPw":"$password",'
      '"AppVersion":"$_DSB_VERSION",'
      '"Language":"$_DSB_LANGUAGE",'
      '"OsVersion":"$_DSB_OS_VERSION",'
      '"AppId":"${v4()}",'
      '"Device":"$_DSB_DEVICE",'
      '"BundleId":"$_DSB_BUNDLE_ID",'
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
                  Uri.parse(apiEndpoint),
                  '{'
                      '"req": {'
                      '"Data": "${base64.encode(GZipEncoder().encode(utf8.encode(json)))}", '
                      '"DataType": 1'
                      '}'
                      '}',
                  '$apiEndpoint\t$username\t$password',
                  {"content-type": "application/json"},
                  useCache: cachePostRequests,
                ),
              ),
              'd'),
        ),
      ),
    );
  } catch (e) {
    ampErr(ctx: 'DSB][dsbGetData', message: errorString(e));
    throw lang.catchDsbGetData(e);
  }
}

Future<Map<String, String>> dsbGetHtml(String jsontext,
    {bool cacheGetRequests = true,
    Future<String> Function(Uri url, {bool useCache}) httpGet =
        httpGet}) async {
  var json = jsonDecode(jsontext);
  if (jsonGetKey(json, 'Resultcode') != 0)
    throw jsonGetKey(json, 'ResultStatusInfo');
  json = jsonGetIndex(
    jsonGetKey(
      jsonGetIndex(
        jsonGetKey(json, 'ResultMenuItems'),
      ),
      'Childs',
    ),
  );
  Map<String, String> map = {};
  for (var plan in jsonGetKey(jsonGetKey(json, 'Root'), 'Childs')) {
    String url = jsonGetKey(
      jsonGetIndex(
        jsonGetKey(plan, 'Childs'),
      ),
      'Detail',
    );
    map[jsonGetKey(plan, 'Title')] = await httpGet(
      Uri.parse(url),
      useCache: cacheGetRequests,
    );
  }
  return map;
}

dom.Element _searchHtml(List<dom.Element> rootNode, String className) {
  for (var e in rootNode) {
    if (e.className.contains(className)) return e;
    var found = _searchHtml(e.children, className);
    if (found != null) return found;
  }
  return null;
}

Future<List<DsbPlan>> dsbGetAllSubs(String username, String password,
    {bool cacheGetRequests = true,
    bool cachePostRequests = true,
    Future<String> Function(Uri url, {bool useCache}) httpGet = httpGet,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers,
            {bool useCache})
        httpPost = httpPost,
    @required Language lang}) async {
  List<DsbPlan> plans = [];
  if (cacheGetRequests || cachePostRequests) Prefs.flushCache();
  String json = await dsbGetData(username, password,
      cachePostRequests: cachePostRequests, httpPost: httpPost, lang: lang);
  var htmls = await dsbGetHtml(json,
      cacheGetRequests: cacheGetRequests, httpGet: httpGet);
  for (var title in htmls.keys) {
    try {
      plans.add(dsbParseHtml(title, htmls[title]));
    } catch (e) {
      ampErr(ctx: 'DSB][dsbGetAllSubs', message: errorString(e));
      plans.add(DsbPlan(
          TTDay.Null,
          [
            DsbSubstitution('', [0], '', lang.dsbListErrorTitle,
                lang.dsbListErrorSubtitle, true)
          ],
          title));
    }
  }
  return plans;
}

DsbPlan dsbParseHtml(String title, String res) {
  ampInfo(ctx: 'DSB', message: 'Trying to parse $title...');
  List<dom.Element> html =
      HtmlParser(res).parse().children[0].children[1].children; //body
  String planTitle = _searchHtml(html, 'mon_title').innerHtml;
  html = _searchHtml(html, 'mon_list')
      .children
      .first
      .children; //for some reason <table>s like to contain <tbody>s
  List<DsbSubstitution> subs = [];
  for (int i = 1; i < html.length; i++)
    subs.add(DsbSubstitution.fromElementArray(html[i].children));
  return DsbPlan(ttMatchDay(planTitle), subs, planTitle);
}

List<DsbPlan> dsbSearchClass(List<DsbPlan> plans, String stage, String char) {
  if(stage == null) stage = '';
  if(char == null) char = '';
  for (DsbPlan plan in plans) {
    List<DsbSubstitution> subs = [];
    for (DsbSubstitution sub in plan.subs) {
      if (sub.affectedClass.contains(stage) &&
          sub.affectedClass.contains(char)) {
        subs.add(sub);
      }
    }
    plan.subs = subs;
  }
  return plans;
}

List<DsbPlan> dsbSortAllByHour(List<DsbPlan> plans) {
  for (DsbPlan plan in plans)
    plan.subs.sort((a, b) => max(a.hours).compareTo(max(b.hours)));
  return plans;
}

Widget dsbGetGoodList(List<DsbPlan> plans) {
  ampInfo(ctx: 'DSB', message: 'Rendering plans: $plans');
  List<Widget> widgets = [];
  _initializeTheme(widgets, plans);
  widgets.add(Padding(padding: EdgeInsets.all(12)));
  updateTimetableDays(plans);
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: widgets);
}

String errorString(dynamic e) {
  if (e is Error) return '$e\n${e.stackTrace}';
  return e.toString();
}

Widget dsbWidget;

Future<Null> dsbUpdateWidget(Function f,
    {bool cacheGetRequests = true,
    bool cachePostRequests = true,
    bool cacheJsonPlans = false}) async {
  try {
    if (Prefs.username.length == 0 || Prefs.password.length == 0)
      throw CustomValues.lang.noLogin;
    String jsonCache = Prefs.dsbJsonCache;
    List<DsbPlan> plans;
    if (!cacheJsonPlans || jsonCache == null) {
      plans = await dsbGetAllSubs(Prefs.username, Prefs.password,
          lang: CustomValues.lang,
          cacheGetRequests: cacheGetRequests,
          cachePostRequests: cachePostRequests);
      Prefs.dsbJsonCache = plansToJson(plans);
    } else
      plans = plansFromJson(jsonCache);
    if (Prefs.oneClassOnly &&
        Prefs.username.isNotEmpty &&
        Prefs.password.isNotEmpty)
      plans = dsbSortAllByHour(dsbSearchClass(plans, Prefs.grade, Prefs.char));
    dsbWidget = dsbGetGoodList(plans);
    timetablePlans = plans;
  } catch (e) {
    ampErr(ctx: 'DSB][dsbUpdateWidget', message: errorString(e));
    dsbWidget = SizedBox(
      child: Container(
          child: getThemedWidget(
            ListTile(
              title: Text(errorString(e), style: AmpColors.textStyleForeground),
            ),
            Prefs.currentThemeId,
          ),
          padding: EdgeInsets.only(top: 15)),
    );
  }
  f();
}

Widget getThemedWidget(Widget child, int themeId) {
  switch (themeId) {
    case 0:
      return Card(
        elevation: 0,
        color: AmpColors.lightBackground,
        child: child,
      );
    case 1:
      return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AmpColors.colorForeground),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      );
    case -1:
      return Card(
        elevation: 0,
        color: AmpColors.lightBackground,
        child: child,
      );
    default:
      return getThemedWidget(child, 0);
  }
}

Widget _getWidget(List<Widget> dayW, int theme) => getThemedWidget(
    Column(mainAxisSize: MainAxisSize.min, children: dayW), theme);

void _initializeTheme(List<Widget> widgets, List<DsbPlan> plans) {
  for (DsbPlan plan in plans) {
    List<Widget> dayWidgets = [];
    if (plan.subs.length == 0) {
      dayWidgets.add(ListTile(
        title: Text(CustomValues.lang.noSubs,
            style: AmpColors.textStyleForeground),
      ));
    }
    int i = 0;
    int iMax = plan.subs.length;
    for (DsbSubstitution sub in plan.subs) {
      String titleSub = CustomValues.lang.dsbSubtoTitle(sub);
      if (CustomValues.isAprilFools)
        titleSub = '${Random().nextInt(98) + 1}.${titleSub.split('.').last}';
      dayWidgets.add(ListTile(
        title: Text(titleSub, style: AmpColors.textStyleForeground),
        subtitle: Text(CustomValues.lang.dsbSubtoSubtitle(sub),
            style: TextStyle(
                color: CustomValues.isAprilFools
                    ? rcolor
                    : AmpColors.colorForeground)),
        trailing:
            (Prefs.char.isEmpty || Prefs.grade.isEmpty || !Prefs.oneClassOnly)
                ? Text(sub.affectedClass,
                    style: TextStyle(color: AmpColors.colorForeground))
                : Text(''),
      ));
      if (++i != iMax)
        dayWidgets.add(Divider(
            color: AmpColors.colorForeground, height: Prefs.subListItemSpace));
    }
    widgets.add(ListTile(
        title: Row(children: <Widget>[
      Text(' ${CustomValues.lang.ttDayToString(plan.day)}',
          style: TextStyle(color: AmpColors.colorForeground, fontSize: 22)),
      IconButton(
          icon: Icon(
            Icons.info,
            color: AmpColors.colorForeground,
          ),
          tooltip: plan.date.split(' ').first,
          onPressed: () {
            dsbApiHomeScaffoldKey.currentState?.showSnackBar(
              SnackBar(
                  backgroundColor: AmpColors.colorBackground,
                  content:
                      Text(plan.date, style: AmpColors.textStyleForeground)),
            );
          }),
    ])));
    widgets.add(_getWidget(dayWidgets, Prefs.currentThemeId));
  }
}

String plansToPlist(List<DsbPlan> plans) {
  String plist = '<?xml version="1.0" encoding="UTF-8"?>\n'
      '<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
      '<plist version="1.0">\n'
      '<array>\n';
  for (var plan in plans) plist += plan.toPlist();
  return '$plist'
      '</array>\n'
      '</plist>\n';
}

String plansToJson(List<DsbPlan> plans) {
  List<String> plansStrings = [];
  for (DsbPlan plan in plans) {
    plansStrings.add(jsonEncode(plan.toJson()));
  }
  return jsonEncode(plansStrings);
}

List<DsbPlan> plansFromJson(String jsonPlans) {
  List<DsbPlan> plans = [];
  List<String> plansStrings = List<String>.from(jsonDecode(jsonPlans));
  for (String tempString in plansStrings) {
    plans.add(DsbPlan.fromJson(jsonDecode(tempString)));
  }
  return plans;
}
