import 'dart:io';

import 'package:package_info/package_info.dart';

const String appTitle = 'Amplessimus';
Future<String> get appVersion async {
  //TODO: test if we have to do this (i need to get a windows for that)
  if (Platform.isWindows) return '0.0.0-1';
  //TODO: make it x.y.z (num) in the app info
  return (await PackageInfo.fromPlatform()).version;
}
