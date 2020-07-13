import 'package:Amplissimus/first_login.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'dsb_test.dart';

void main() {
  return;
  testWidgets('first_login_test_1', (tester) async {
    Prefs.initTestPrefs();
    disableLogging();
    var screen = FirstLoginScreen(
        testing: true,
        httpPostReplacement: (url, body, id, headers,
                {getCache, setCache}) async =>
            dsbTest1Cache['GetData'],
        httpGetReplacement: (url, {getCache, setCache}) async =>
            dsbTest1Cache['44a7def4-aaa3-4177-959d-e2921176cde9.htm']);
    await tester.pumpWidget(screen);
    await tester.pumpAndSettle();
    FirstLoginValues.usernameInputFormController.text = 'username';
    FirstLoginValues.passwordInputFormController.text = 'password';
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
