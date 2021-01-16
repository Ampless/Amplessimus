import 'package:amplessimus/logging.dart';
import 'package:amplessimus/main.dart';
import 'package:amplessimus/prefs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef testCase = Future<Null> Function();

testCase expectTestCase<T>(
  Future<T> Function() tfunc,
  T expct,
  bool error,
) =>
    () async {
      T res;
      try {
        res = await tfunc();
      } catch (e) {
        if (!error) {
          rethrow;
        } else {
          return;
        }
      }
      if (error) throw '[expectTestCase($tfunc, $expct)] No error.';
      expect(res, expct);
    };

Future<Null> testInit() async {
  ampDisableLogging();
  prefs = Prefs(await SharedPreferences.getInstance());
}

void tests(List<testCase> testCases, String groupName) {
  group(groupName, () {
    var i = 1;
    for (final testCase in testCases) {
      test('case ${i++}', () async {
        await testInit();
        await testCase();
      });
    }
  });
}
