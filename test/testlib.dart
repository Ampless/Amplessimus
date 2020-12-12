import 'package:amplessimus/logging.dart';
import 'package:amplessimus/prefs.dart' as prefs;
import 'package:flutter_test/flutter_test.dart';

typedef testCase = Future<Null> Function();

testCase expectTestCase(
  Future<dynamic> Function() tfunc,
  dynamic expct,
  bool error,
) =>
    () async {
      dynamic res;
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
  await prefs.load();
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
