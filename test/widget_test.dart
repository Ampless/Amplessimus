import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/screens/register_timetable.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter_test/flutter_test.dart';

final Map<String, String> dsbTest1Cache = {
  'GetData':
      '{\"d\":\"H4sIAAAAAAAEAOWX3W6bMBSA7yftHSKuS/gxBOjd1G1apaaqlmo301QZfEhQiYmwaTdVfZu9yV5sJm4oP4ayLO00NTco5/98dk4Od2/fTCbaZ2BFyqOMgHY8MY9qsgXHvGCnNM6ERtOkSghzfkoJfBdC3arbz4EWpxzWTGi+lvLJ5E4+hMnORWaQoiijZwm9foy+FV8mPC1rES4rnHKoqU5WSUpq4RspetJ0Uq0437Bjw8CbzZSwUGh4nqVTAgYTDSeRgSnJs4QkQsOMy2QNHIcpTDd0qTWjVpVepL9+UmhpP2cZF8pGfWUppNnvg/g95qBUVEm6LqKwJFU74SVTKk4yevljAx1CQnWRJ5lKrkbacxryc9cWVH07DvYIxI6OMUa6Y3meHrgB0cEObMvyZhGBoF10g4+NpuZsapu2OTH9Y9dVGlfMvkDOc+AFXV7Nrz5BwUEdvJfkIM0WUVul7qEqkfSQlXF76ZYfBWEZ8q8oSxh/QFri2dFmRcj4lWla0xVf98evYPf/Egnm2PAdK/CxG+pBFIsu/NjWMbiublrENy2YAYp8Y0yro4wGax66AfK0qluA+kwGboI8uoHbIHNUN+Jbfw64SeC2LPVw9DYy6HYAqvLed4WqAuvFdeLcdxz6Z4jrO7YTzjzdgjAWRbu27kdIfPV8y4E4QJ6nHgsHmCHzLF8CfRVDZF/MEsZ/NUTGtDrK6FUOkVH0XmSINAVt/17f5vDpRaTNga8yco7X24vKd5tha+87h9uTrKC8u4Uu8A2cYbZdrMsQPC/g0aCq/jFrK2NtE1YmGUiwa7G7kFvjF/KFWIh5sgT2b1fyBXCe0CUb2sg/JKJUSFMxtdvjeuz5soc0ex9vjFNWP9+jpwhZhyL0EYCEOLoeIrSz2Q9OrPZ+Rjj2oeC8C7OCD5HZvvHuRQWXoV8OCToUkrNs+QQTabEflVTluz+WZx2T5UMGFt1hSiFtvC5rc8ENUy43JBO5KA58pEOMZrrjOVgPUBDpQYjQjER+6CBH/NHc/wbNrhqraREAAA==\"}',
  '44a7def4-aaa3-4177-959d-e2921176cde9.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">23.6.2020 Dienstag</div><table class=\"info\" ><tr></tr><tr><td>Betroffene Klassen </td><td>11Q</td></tr></table><table class=\"mon_list\" ><tr></tr><tr><td>11Q</td><td> 7 &nbsp; 8 </td><td>---</td><td>1sk1</td><td> </td></tr></table>Untis Stundenplan Software',
  '58424b67-1ebf-4152-8c37-17814ef93775.htm':
      '<table class=\"mon_head\"> <tr> <td></td> <td></td> <td> GYM. MIT SCHÜLERHEIM ROSENHOF D-91257,P1meml Gymnasium Rosenhof 2019/2020 Stand: 23.06.2020 08:55 </td> </tr></table><div class=\"mon_title\">24.6.2020 Mittwoch</div><table class=\"info\" ><tr></tr><tr><td>Betroffene Klassen </td><td>05a, 05b, 05c, 05d, Heim</td></tr></table><table class=\"mon_list\" ><tr></tr><tr><td>05abcd</td><td>6</td><td>---</td><td>Ethik</td><td> </td></tr></table>Untis Stundenplan Software',
};

void main() {
  testWidgets('The one and only UI test', (tester) async {
    ampDisableLogging();
    await tester.pumpWidget(
      SplashScreen(
        testing: true,
        httpPostFunc: (url, body, id, headers, {getCache, setCache}) async =>
            dsbTest1Cache['GetData'],
        httpGetFunc: (url, {getCache, setCache}) async =>
            dsbTest1Cache['44a7def4-aaa3-4177-959d-e2921176cde9.htm'],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('11').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('a'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(usernameInputFormKey), 'username');
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(passwordInputFormKey), 'password');
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.save));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.timetable));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.setupTimetable));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.dayToString(Day.Monday)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.dayToString(Day.Tuesday)).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('6').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Language.current.save));
    await tester.pumpAndSettle();
    assert(ttColumns.where((element) => element.lessons.isNotEmpty).isNotEmpty);
    await tester.tap(find.text(Language.current.settings));
    await tester.pumpAndSettle();
    for (var w in <String>[
      Language.current.changeAppearance,
    ]) {
      await tester.tap(find.text(w));
      await tester.pumpAndSettle();
    }
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.text(Language.current.lightsOn));
      await tester.pumpAndSettle();
      await tester.tap(find.text(Language.current.lightsOff));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('Entwickleroptionen'));
    await tester.pumpAndSettle();
  });
}
