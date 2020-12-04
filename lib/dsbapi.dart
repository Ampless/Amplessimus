import 'dart:async';

import 'ui/first_login.dart';
import 'main.dart';
import 'langs/language.dart';
import 'logging.dart';
import 'prefs.dart' as Prefs;
import 'subject.dart';
import 'uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget dsbRenderPlans(
  List<Plan> plans,
  bool oneClassOnly,
  String char,
  String grade,
  bool altTheme,
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
        subject: Prefs.parseSubjects ? realSubject(sub.subject) : sub.subject,
        orgTeacher: sub.orgTeacher,
        lesson: sub.lesson.toString(),
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
          icon: ampIcon(Icons.info_outline),
          tooltip: plan.date.split(' ').first,
          onPressed: () {
            scaffoldMessanger.showSnackBar(ampSnackBar(plan.date));
          },
        ),
        IconButton(
          icon: ampIcon(Icons.open_in_new_outlined),
          tooltip: Language.current.openPlanInBrowser,
          onPressed: () => ampOpenUrl(plan.url),
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets, altTheme));
  }
  widgets.add(ampPadding(12));
  final column = ampColumn(widgets);
  ampInfo('DSB', 'Done rendering plans.');
  return column;
}

List<Plan> dsbPlans;
Widget dsbWidget;

Future<Null> dsbUpdateWidget({
  Function() callback,
  bool useJsonCache,
  bool altTheme,
}) async {
  useJsonCache ??= Prefs.useJsonCache;
  altTheme ??= Prefs.altTheme;
  callback ??= () {};
  final username = Prefs.username;
  final password = Prefs.password;
  final oneClassOnly = Prefs.oneClassOnly;
  final grade = Prefs.grade;
  final char = Prefs.char;
  try {
    if (username.isEmpty || password.isEmpty) throw Language.current.noLogin;
    final useJCache = useJsonCache && Prefs.dsbJsonCache != null;
    var plans = useJCache
        ? Plan.plansFromJson(Prefs.dsbJsonCache)
        : await getAllSubs(username, password, cachedHttpGet, uncachedHttp.post,
            language: Prefs.dsbLanguage);
    if (!useJCache) Prefs.dsbJsonCache = Plan.plansToJson(plans);
    if (oneClassOnly) plans = sortByLesson(searchClass(plans, grade, char));
    dsbWidget = dsbRenderPlans(plans, oneClassOnly, char, grade, altTheme);
    dsbPlans = plans;
  } catch (e) {
    ampErr(['DSB', 'dsbUpdateWidget'], errorString(e));
    dsbWidget = SizedBox(
      child: Container(
        child: ampList([ampErrorText(e)], altTheme),
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
