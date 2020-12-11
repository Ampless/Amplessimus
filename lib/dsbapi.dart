import 'dart:async';

import 'ui/first_login.dart';
import 'langs/language.dart';
import 'logging.dart';
// ignore: library_prefixes
import 'prefs.dart' as Prefs;
import 'subject.dart';
import 'ui/home_page.dart';
import 'uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget _renderPlans(List<Plan> plans) {
  ampInfo('DSB', 'Rendering plans: $plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidgets = <Widget>[];
    if (plan.subs.isEmpty) {
      dayWidgets.add(ListTile(title: ampText(Language.current.noSubs)));
    }
    for (final sub in plan.subs) {
      dayWidgets.add(ampLessonTile(
        subject: Prefs.parseSubjects ? realSubject(sub.subject) : sub.subject,
        orgTeacher: sub.orgTeacher,
        lesson: sub.lesson.toString(),
        subtitle: Language.current.dsbSubtoSubtitle(sub),
        affClass: (Prefs.classGrade.isEmpty ||
                Prefs.classLetter.isEmpty ||
                !Prefs.oneClassOnly)
            ? sub.affectedClass
            : '',
      ));
    }
    widgets.add(ListTile(
      title: ampRow([
        ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
        IconButton(
          icon: ampIcon(Icons.info, Icons.info_outline),
          tooltip: plan.date.split(' ').first,
          onPressed: () =>
              scaffoldMessanger.showSnackBar(ampSnackBar(plan.date)),
        ),
        IconButton(
          icon: ampIcon(Icons.open_in_new, Icons.open_in_new_outlined),
          tooltip: Language.current.openPlanInBrowser,
          onPressed: () => ampOpenUrl(plan.url),
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets));
  }
  ampInfo('DSB', 'Done rendering plans.');
  return ampColumn(widgets);
}

List<Plan> dsbPlans;
Widget dsbWidget;

Future<Null> dsbUpdateWidget({
  Function() callback,
  bool useJsonCache,
}) async {
  useJsonCache ??= Prefs.useJsonCache;
  callback ??= () {};
  try {
    final useJCache = useJsonCache && Prefs.dsbJsonCache != null;
    var plans = useJCache
        ? Plan.plansFromJson(Prefs.dsbJsonCache)
        : await getAllSubs(
            Prefs.username, Prefs.password, cachedHttpGet, http.post,
            language: Prefs.dsbLanguage);
    if (!useJCache) Prefs.dsbJsonCache = Plan.plansToJson(plans);
    if (Prefs.oneClassOnly) {
      plans = searchClass(
        plans,
        Prefs.classGrade,
        Prefs.classLetter,
      );
    }
    for (final plan in plans) {
      plan.subs.sort();
    }
    dsbWidget = _renderPlans(plans);
    dsbPlans = plans;
  } catch (e) {
    ampErr(['DSB', 'dsbUpdateWidget'], errorString(e));
    dsbWidget = ampList([ampErrorText(e)]);
  }
  callback();
}

//this is a really bad place to put this and
//some bad prefixes, but we can fix that later

List<String> get dsbGrades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get dsbLetters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
