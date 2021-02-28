import 'dart:async';

import 'main.dart';
import 'ui/first_login.dart';
import 'langs/language.dart';
import 'logging.dart';
import 'subject.dart';
import 'ui/home_page.dart';
import 'uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

Widget _renderPlans(List<Plan> plans, bool oneClassOnly) {
  ampInfo('DSB', 'Rendering plans: $plans');
  final widgets = <Widget>[];
  for (final plan in plans) {
    final dayWidgets = plan.subs.isEmpty
        ? [ListTile(title: ampText(Language.current.noSubs))]
        : plan.subs.map((sub) {
            final subject = parseSubject(sub.subject);
            final title = sub.orgTeacher == null || sub.orgTeacher!.isEmpty
                ? subject
                : '$subject (${sub.orgTeacher})';

            final trailing = oneClassOnly ? '' : sub.affectedClass;

            return ListTile(
              horizontalTitleGap: 4,
              title: ampText(title, size: 18),
              leading: ampText(sub.lesson, weight: FontWeight.bold, size: 36),
              subtitle:
                  ampText(Language.current.dsbSubtoSubtitle(sub), size: 16),
              trailing: ampText(trailing, weight: FontWeight.bold, size: 20),
            );
          }).toList();
    final warn = outdated(plan.date, DateTime.now());
    widgets.add(ListTile(
      title: ampRow([
        ampText(' ${Language.current.dayToString(plan.day)}', size: 24),
        IconButton(
          icon: warn
              ? ampIcon(Icons.warning, Icons.warning_amber_outlined)
              : ampIcon(Icons.info, Icons.info_outline),
          tooltip: warn
              //TODO: better warning tooltip
              ? Language.current.warnWrongDate(plan.date)
              : plan.date.split(' ').first,
          onPressed: () => scaffoldMessanger?.showSnackBar(ampSnackBar(
              warn ? Language.current.warnWrongDate(plan.date) : plan.date)),
          padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
        ),
        IconButton(
          icon: ampIcon(Icons.open_in_new, Icons.open_in_new_outlined),
          tooltip: Language.current.openPlanInBrowser,
          onPressed: () => ampOpenUrl(plan.url),
          padding: EdgeInsets.fromLTRB(4, 4, 2, 4),
        ),
      ]),
    ));
    widgets.add(ampList(dayWidgets));
  }
  ampInfo('DSB', 'Done rendering plans.');
  return ampColumn(widgets);
}

List<Plan>? plans;
Widget widget = ampNull;

Future<Null> updateWidget([bool? useJsonCache]) async {
  useJsonCache ??= prefs.forceJsonCache;
  try {
    var plans = useJsonCache && prefs.dsbJsonCache != ''
        ? Plan.plansFromJson(prefs.dsbJsonCache)
        : await getAllSubs(prefs.username, prefs.password, cachedHttp,
            language: prefs.dsbLanguage);
    prefs.dsbJsonCache = Plan.plansToJson(plans);
    if (prefs.oneClassOnly) {
      plans = Plan.searchInPlans(
          plans,
          (sub) =>
              sub.affectedClass.contains(prefs.classGrade) &&
              sub.affectedClass.contains(prefs.classLetter));
    }
    for (final plan in plans) {
      plan.subs.sort();
    }
    widget = _renderPlans(
      plans,
      prefs.oneClassOnly &&
          (prefs.classGrade.isNotEmpty || prefs.classLetter.isNotEmpty),
    );
    plans = plans;
  } catch (e) {
    ampErr(['DSB', 'updateWidget'], errorString(e));
    widget = ampList([ampErrorText(e)]);
  }
}

bool outdated(String date, DateTime now) {
  try {
    final raw = date.split(' ').first.split('.');
    return now.isAfter(DateTime(
      int.parse(raw[2]),
      int.parse(raw[1]),
      int.parse(raw[0]),
    ).add(Duration(days: 3)));
  } catch (e) {
    return false;
  }
}

//this is a really bad place to put this, but we can fix that later
List<String> get grades => ['5', '6', '7', '8', '9', '10', '11', '12', '13'];
List<String> get letters => ['', 'a', 'b', 'c', 'd', 'e', 'f', 'g'];
