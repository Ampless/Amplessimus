import 'dart:async';

import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/subject.dart';
import 'package:Amplessimus/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget dsbGetGoodList(
  List<DsbPlan> plans,
  bool oneClassOnly,
  String char,
  String grade,
  int themeId,
) {
  ampInfo('DSB', 'Rendering plans: $plans');
  var widgets = <Widget>[];
  for (var plan in plans) {
    var dayWidgets = <Widget>[];
    if (plan.subs.isEmpty) {
      dayWidgets.add(ampListTile(Language.current.noSubs));
    }
    var i = 0;
    for (var sub in plan.subs) {
      dayWidgets.add(ampLessonTile(
        subject:
            '${realSubject(sub.subject, Language.current)} (${sub.orgTeacher})',
        lesson: lesson(sub.lessons),
        subtitle: Language.current.dsbSubtoSubtitle(sub),
        trailing: (char.isEmpty || grade.isEmpty || !oneClassOnly)
            ? sub.affectedClass
            : '',
      ));
      if (++i < plan.subs.length) dayWidgets.add(ampDivider);
    }
    widgets.add(ListTile(
      title: Row(children: [
        ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
        IconButton(
          icon: ampIcon(Icons.info),
          tooltip: plan.date.split(' ').first,
          onPressed: () {
            homeScaffoldKey.currentState?.showSnackBar(ampSnackBar(plan.date));
          },
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets, themeId));
  }
  widgets.add(ampPadding(12));
  return Column(mainAxisAlignment: MainAxisAlignment.center, children: widgets);
}

List<DsbPlan> dsbPlans;
Widget dsbWidget;

Future<Null> dsbUpdateWidget(
    {void Function() callback,
    bool cacheGetRequests = true,
    bool cachePostRequests = true,
    bool cacheJsonPlans,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers)
        httpPost,
    Future<String> Function(Uri url) httpGet,
    String dsbLanguage,
    String dsbJsonCache,
    String username,
    String password,
    bool oneClassOnly,
    String grade,
    String char,
    int themeId,
    Language lang}) async {
  httpPost ??= FirstLoginValues.httpPostFunc;
  httpGet ??= FirstLoginValues.httpGetFunc;
  cacheJsonPlans ??= Prefs.useJsonCache;
  callback ??= () {};
  dsbLanguage ??= Prefs.dsbLanguage;
  dsbJsonCache ??= Prefs.dsbJsonCache;
  username ??= Prefs.username;
  password ??= Prefs.password;
  lang ??= Language.current;
  oneClassOnly ??= Prefs.oneClassOnly;
  grade ??= Prefs.grade;
  char ??= Prefs.char;
  themeId ??= Prefs.currentThemeId;
  try {
    if (username.isEmpty || password.isEmpty) throw lang.noLogin;
    var useJCache = cacheJsonPlans && dsbJsonCache != null;
    var plans = useJCache
        ? plansFromJson(dsbJsonCache)
        : await dsbGetAllSubs(username, password, httpGet, httpPost,
            cacheGetRequests: cacheGetRequests,
            cachePostRequests: cachePostRequests,
            dsbLanguage: dsbLanguage);
    if (!useJCache) dsbJsonCache = plansToJson(plans);
    if (oneClassOnly)
      plans = dsbSortByLesson(dsbSearchClass(plans, grade, char));
    updateTimetableDays(plans);
    dsbWidget = dsbGetGoodList(plans, oneClassOnly, char, grade, themeId);
    dsbPlans = plans;
  } catch (e) {
    ampErr(['DSB', 'dsbUpdateWidget'], errorString(e));
    dsbWidget = SizedBox(
      child: Container(
        child: ampList([ampListTile(errorString(e))], themeId),
        padding: EdgeInsets.only(top: 15),
      ),
    );
  }
  callback();
}

//this is a really bad place to put this and
//some bad prefixes, but we can fix that later

List<String> get dsbGrades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get dsbLetters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
