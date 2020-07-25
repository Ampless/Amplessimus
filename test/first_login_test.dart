import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dsb_test.dart';

void main() {
  var b = true;
  if (b) return;
  testWidgets('first_login_test_1', (tester) async {
    Prefs.initTestPrefs();
    disableLogging();
    var screen = FirstLoginScreen(
        testing: true,
        httpPostFunc: (url, body, id, headers, {getCache, setCache}) async =>
            dsbTest1Cache['GetData'],
        httpGetFunc: (url, {getCache, setCache}) async =>
            dsbTest1Cache['44a7def4-aaa3-4177-959d-e2921176cde9.htm']);
    await tester.pumpWidget(screen);
    await tester.pumpAndSettle();
    screen.page.state.usernameInputFormController.text = 'username';
    screen.page.state.passwordInputFormController.text = 'password';
    screen.page.state.gradeDropDownValue = '11';
    screen.page.state.letterDropDownValue = 'q';
    screen.page.state.saveButton.onPressed();
    await tester.pumpAndSettle();
    screen.page.state.doneButton.onPressed();
    await tester.pumpAndSettle();
    for (var w in FirstLoginValues.settingsButtons) {
      ((w as Card).child as InkWell).onTap();
      await tester.pumpAndSettle();
    }
  });
}
