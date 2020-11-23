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
import 'package:url_launcher/url_launcher.dart';

Widget dsbRenderPlans(
  List<DsbPlan> plans,
  bool oneClassOnly,
  String char,
  String grade,
  int themeId,
) {
  ampInfo('DSB', 'Rendering plans: $plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidgets = <Widget>[];
    if (plan.subs.isEmpty) {
      dayWidgets.add(ampListTile(Language.current.noSubs));
    }
    var i = 0;
    for (final sub in plan.subs) {
      dayWidgets.add(ampLessonTile(
        subject: realSubject(sub.subject, Language.current),
        teacher: sub.orgTeacher,
        lesson: lesson(sub.lessons),
        subtitle: Language.current.dsbSubtoSubtitle(sub),
        affClass: (char.isEmpty || grade.isEmpty || !oneClassOnly)
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
            scaffoldMessanger.showSnackBar(ampSnackBar(plan.date));
          },
        ),
        IconButton(
          icon: ampIcon(Icons.open_in_new),
          tooltip: Language.current.openPlanInBrowser,
          onPressed: () => launch(plan.url),
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets, themeId));
  }
  widgets.add(ampPadding(12));
  final column = ampColumn(widgets);
  ampInfo('DSB', 'Done rendering plans.');
  return column;
}

List<DsbPlan> dsbPlans;
Widget dsbWidget;

Future<Null> dsbUpdateWidget(
    {Function() callback,
    bool useJsonCache,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers)
        httpPost,
    Future<String> Function(Uri url) httpGet,
    String dsbLanguage,
    String username,
    String password,
    bool oneClassOnly,
    String grade,
    String char,
    int themeId,
    Language lang}) async {
  httpPost ??= httpPostFunc;
  httpGet ??= httpGetFunc;
  useJsonCache ??= Prefs.useJsonCache;
  callback ??= () {};
  dsbLanguage ??= Prefs.dsbLanguage;
  username ??= Prefs.username;
  password ??= Prefs.password;
  lang ??= Language.current;
  oneClassOnly ??= Prefs.oneClassOnly;
  grade ??= Prefs.grade;
  char ??= Prefs.char;
  themeId ??= Prefs.currentThemeId;
  try {
    if (username.isEmpty || password.isEmpty) throw lang.noLogin;
    final useJCache = useJsonCache && Prefs.dsbJsonCache != null;
    var plans = useJCache
        ? plansFromJson(Prefs.dsbJsonCache)
        : await dsbGetAllSubs(username, password, httpGet, httpPost,
            dsbLanguage: dsbLanguage);
    if (!useJCache) Prefs.dsbJsonCache = plansToJson(plans);
    if (oneClassOnly)
      plans = dsbSortByLesson(dsbSearchClass(plans, grade, char));
    updateTimetableDays(plans);
    dsbWidget = dsbRenderPlans(plans, oneClassOnly, char, grade, themeId);
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
