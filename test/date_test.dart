import 'package:amplessimus/dsbapi.dart' as dsb;

import 'testlib.dart';

testCase dsbDateTestCase(String date, DateTime now, bool outdated) =>
    expectTestCase(() async => dsb.outdated(date, now), outdated, false);

void main() {
  tests([
    dsbDateTestCase('12.12.1337', DateTime(1337, 12, 12), false),
    dsbDateTestCase('20.10.2000', DateTime(2000, 10, 30), true),
    dsbDateTestCase('30.5.2100', DateTime(2100, 6, 10), true),
  ], 'outdated');
}
