import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter_test/flutter_test.dart';

abstract class SyncTestCase {
  void run();
}

abstract class AsyncTestCase {
  Future<Null> run();
}

void runSyncTest(String description, SyncTestCase testCase) {
  test(description, () {
    Prefs.initTestPrefs();
    disableLogging();
    testCase.run();
    expect(Prefs.toJson(), '[]');
  });
}

void runAsyncTest(String description, AsyncTestCase testCase) {
  test(description, () async {
    Prefs.initTestPrefs();
    disableLogging();
    await testCase.run();
    expect(Prefs.toJson(), '[]');
  });
}
