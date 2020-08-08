import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dsb_test.dart';

void main() {
  testWidgets('The one and only UI test', (tester) async {
    Prefs.initTestPrefs();
    ampDisableLogging();
    var screen = FirstLoginScreen(
        testing: true,
        httpPostFunc: (url, body, id, headers, {getCache, setCache}) async =>
            dsbTest1Cache['GetData'],
        httpGetFunc: (url, {getCache, setCache}) async =>
            dsbTest1Cache['44a7def4-aaa3-4177-959d-e2921176cde9.htm']);
    await tester.pumpWidget(screen);
    await tester.pumpAndSettle();
    screen.page.state.gradeDropDownValue = '11';
    screen.page.state.letterDropDownValue = 'q';
    await tester.enterText(
        find.byKey(screen.page.state.usernameInputFormKey), 'username');
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(screen.page.state.passwordInputFormKey), 'password');
    await tester.pumpAndSettle();
    await tester.tap(find.text(CustomValues.lang.save));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CustomValues.lang.firstStartupDone));
    await tester.pumpAndSettle();
    for (var w in FirstLoginValues.settingsButtons) {
      if (!(w is Card)) continue;
      ((w as Card).child as InkWell).onTap();
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 10; i++) {
      ((FirstLoginValues.settingsButtons.first as Card).child as InkWell)
          .onTap();
      await tester.pumpAndSettle();
    }
    assert(FirstLoginValues.settingsButtons.last is Card);
    ((FirstLoginValues.settingsButtons.last as Card).child as InkWell).onTap();
    await tester.pumpAndSettle();
  });
}
