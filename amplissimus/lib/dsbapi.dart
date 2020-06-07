import 'dart:convert';
import 'dart:io';

import 'package:amplissimus/dsbutil.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';

const String DSB_BUNDLE_ID = "de.heinekingmedia.dsbmobile";
const String DSB_DEVICE = "SM-G950F";
const String DSB_VERSION = "2.5.9";
const String DSB_OS_VERSION = "29 10.0";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'https://app.dsbcontrol.de/JsonHandler.ashx/GetData';

var dsbApiHomeScaffoldKey = GlobalKey<ScaffoldState>();

class DsbSubstitution {
  String usedClass;
  List<int> hours;
  String teacher;
  String subject;
  String notes;
  bool isFree;

  DsbSubstitution(this.usedClass, this.hours, this.teacher, this.subject, this.notes, this.isFree);

  DsbSubstitution.fromJson(Map<String, dynamic> json)
    : usedClass = json['usedClass'],
      hours = List<int>.from(jsonDecode(json['hours'])),
      teacher = json['teacher'],
      subject = json['subject'],
      notes = json['notes'],
      isFree = json['isFree'];

  Map<String, dynamic> toJson() =>
    {
      'usedClass': usedClass,
      'hours': jsonEncode(hours),
      'teacher': teacher,
      'subject': subject,
      'notes': notes,
      'isFree': isFree,
    };

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
    return fromStrings(_str(affectedClass), _str(hour), _str(teacher), _str(subject), _str(notes));
  }
  static DsbSubstitution fromElementArray(List<dom.Element> elements) {
    return fromElements(elements[0], elements[1], elements[2], elements[3], elements[4]);
  }

  static String _str(dom.Element e) {
    return htmlUnescape(e.innerHtml).replaceAll(RegExp(r'</?.+?>'), '').trim();
  }

  String toString() {
    return "['$usedClass', $hours, '$teacher', '$subject', '$notes', $isFree]";
  }

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

  String get affectedClass {
    if(usedClass.startsWith('0')) return usedClass.replaceFirst('0', '');
    return usedClass;
  }
}

class DsbPlan {
  String title;
  String date;
  List<DsbSubstitution> subs;

  DsbPlan(this.title, this.subs, this.date);

  String toString() {
    return '$title: $subs';
  }

  DsbPlan.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        subs = subsFromJson(List<String>.from(jsonDecode(json['subs']))),
        date = json['date'];

  Map<String, dynamic> toJson() =>
    {
      'title': title,
      'subs': jsonEncode(subsToJson(subs)),
      'date': date,
    };
  
  static List<DsbSubstitution> subsFromJson(List<String> tempStrings) {
    List<DsbSubstitution> tempSubs = [];
    for(String tempString in tempStrings) {
      tempSubs.add(DsbSubstitution.fromJson(jsonDecode(tempString)));
    }
    return tempSubs;
  }

  static List<String> subsToJson(List<DsbSubstitution> tempSubs) {
    List<String> tempStrings = [];
    for(DsbSubstitution tempSub in tempSubs) {
      tempStrings.add(jsonEncode(tempSub.toJson()));
    }
    return tempStrings;
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
    '}', Map.fromEntries([MapEntry<String, String>("content-type", "application/json")]));
  var jsonResponse = jsonDecode(res);
  assert(jsonResponse is Map);
  assert(jsonResponse.containsKey('d'));
  return utf8.decode(gzip.decode(base64.decode(jsonResponse['d'])));
}

dynamic _jsonGetKey(dynamic json, String key) {
  assert(json is Map);
  assert(json.containsKey(key));
  return json[key];
}

dynamic _jsonGetFirst(dynamic json) {
  assert(json is List);
  assert(json.length > 0);
  return json[0];
}

Future<Map<String, String>> dsbGetHtml(String jsontext) async {
  var json = jsonDecode(jsontext);
  if(_jsonGetKey(json, 'Resultcode') != 0) throw _jsonGetKey(json, 'ResultStatusInfo');
  json = _jsonGetFirst(
    _jsonGetKey(
      _jsonGetFirst(
        _jsonGetKey(
          json,
          'ResultMenuItems',
        ),
      ),
      'Childs',
    ),
  );
  Map<String, String> map = {};
  for (var plan in _jsonGetKey(_jsonGetKey(json, 'Root'), 'Childs'))
    map[
      _jsonGetKey(plan, 'Title')
    ] = await httpGet(
      _jsonGetKey(
        _jsonGetFirst(
          _jsonGetKey(
            plan,
            'Childs',
          ),
        ),
        'Detail',
      ),
    );
  return map;
}

Future<List<DsbPlan>> dsbGetAllSubs(String username, String password) async {
  List<DsbPlan> plans = [];
  Prefs.flushCache();
  String json = await dsbGetData(username, password);
  var htmls = await dsbGetHtml(json);
  for(var title in htmls.keys) {
    var res = htmls[title];
    try {
      ampInfo(ctx: 'DSB', message: 'Trying to parse $title...');
      List<dom.Element> html = HtmlParser(res).parse().children[0].children[1].children[1].children[2].children[0].children[0].children;
      dom.Element htmlDateElement = HtmlParser(res).parse().children[0].children[1].children[1].children[0];
      String planDate = htmlDateElement.innerHtml.toString();
      String planTitle = htmlDateElement.innerHtml.toString().split(' ').last;
      List<DsbSubstitution> subs = [];
      for(int i = 1; i < html.length; i++) {
        subs.add(DsbSubstitution.fromElementArray(html[i].children));
      }
      plans.add(DsbPlan(planTitle, subs, planDate));
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
    List<Widget> dayWidgets = [];
    if(plan.subs.length == 0) {
      dayWidgets.add(ListTile(
        title: Text('Keine Vertretungen', style: TextStyle(color: AmpColors.colorForeground)),
      ));
    }
    int i = 0;
    int iMax = plan.subs.length;
    for(DsbSubstitution sub in plan.subs) {
      dayWidgets.add(ListTile(
        title: Text(sub.title, style: TextStyle(color: AmpColors.colorForeground)),
        subtitle: Text(sub.subtitle, style: TextStyle(color: AmpColors.colorForeground)),
        trailing: Text(sub.affectedClass, style: TextStyle(color: AmpColors.colorForeground)),
      ));
      if(++i != iMax) dayWidgets.add(Divider(color: AmpColors.colorForeground, height: 0,));
    }
    widgets.add(ListTile(title: Row(children: <Widget>[
      Text(' ${plan.title}', style: TextStyle(color: AmpColors.colorForeground, fontSize: 25)),
      IconButton(icon: Icon(Icons.info, color: AmpColors.colorForeground,), tooltip: plan.date.split(' ').first, onPressed: () {
        dsbApiHomeScaffoldKey.currentState?.showSnackBar(
          SnackBar(backgroundColor: AmpColors.colorBackground, content: Text(plan.date, style: TextStyle(color: AmpColors.colorForeground),))
        );
      },)
    ])));
    widgets.add(Card(
      elevation: 0,
      color: AmpColors.lightForeground,
      child: Column(mainAxisSize: MainAxisSize.min, children: dayWidgets),
    ));
  }
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

Future<void> dsbUpdateWidget(Function f, {bool fetchDataAgain=false}) async {
  try {
    if(Prefs.username.length == 0 || Prefs.password.length == 0) throw 'Keine Daten eingetragen!';
    String tempGrade = '';
    String tempChar = '';
    if(Prefs.oneClassOnly) {
      tempGrade = Prefs.grade;  
      tempChar = Prefs.char;
    }
    List<DsbPlan> tempPlans = jsonDecodeDsbPlans(Cache.dsbPlansJsonEncoded);
    if(fetchDataAgain || tempPlans.isEmpty) {
      tempPlans = await dsbGetAllSubs(Prefs.username, Prefs.password);
      Cache.dsbPlansJsonEncoded = jsonEncodeDsbPlans(tempPlans);
      ampInfo(ctx: 'DSB', message: '[SAVE] Cache.dsbPlans = ${Cache.dsbPlansJsonEncoded}');
    } else {
      ampInfo(ctx: 'DSB', message: 'Building dsbWidget without fetching again...');
    }
    if(Prefs.oneClassOnly) {
      dsbWidget = dsbGetGoodList(dsbSortAllByHour(dsbSearchClass(tempPlans, tempGrade, tempChar)));
    } else {
      dsbWidget = dsbGetGoodList(tempPlans);
    }
  } catch (e) {
    dsbWidget = SizedBox(child: Container(child: Card(
      color: AmpColors.lightForeground,
      child: ListTile(title: Text(errorString(e), style: TextStyle(color: AmpColors.colorForeground),),)
    ), padding: EdgeInsets.only(top: 15),));
  }
  f();
}

List<DsbPlan> jsonDecodeDsbPlans(List<String> tempStrings) {
  List<DsbPlan> tempPlans = [];
  for(String tempString in tempStrings) {
    tempPlans.add(DsbPlan.fromJson(jsonDecode(tempString)));
  }
  return tempPlans;
}

List<String> jsonEncodeDsbPlans(List<DsbPlan> tempPlans) {
  List<String> tempStrings = [];
  for(DsbPlan tempPlan in tempPlans) tempStrings.add(jsonEncode(tempPlan.toJson()));
  return tempStrings;
}
