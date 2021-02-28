import 'dart:io';

import 'package:package_info/package_info.dart';

const String appTitle = 'Amplessimus';
Future<String> get appVersion async {
  //TODO: test if we have to do this (i need to get a windows for that)
  if (Platform.isWindows) return '0.0.0-1';
  return (await PackageInfo.fromPlatform()).version;
}

Future<String> get buildNumber async =>
    (await PackageInfo.fromPlatform()).buildNumber;
