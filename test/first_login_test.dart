import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
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
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('q').first);
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(screen.page.state.usernameInputFormKey), 'username');
    await tester.pumpAndSettle();
    await tester.enterText(
        find.byKey(screen.page.state.passwordInputFormKey), 'password');
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.save));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.firstStartupDone));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.settings));
    await tester.pumpAndSettle();
    for (var w in <String>[
      Language.current.changeAppearance,
    ]) {
      await tester.tap(find.text(w));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byWidget(FirstLoginValues.settingsButtons.first));
      await tester.pumpAndSettle();
    }
    assert(FirstLoginValues.settingsButtons.last is Card);
    ((FirstLoginValues.settingsButtons.last as Card).child as InkWell).onTap();
    await tester.pumpAndSettle();
  });
}
