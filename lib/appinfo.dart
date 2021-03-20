import 'dart:io';

import 'package:package_info/package_info.dart';

const String appTitle = 'Amplessimus';
Future<String> get appVersion async {
  //TODO: someone with windows test if we have to do this
  if (Platform.isWindows) return '0.0.0-1';
  return (await PackageInfo.fromPlatform()).version;
}

Future<String> get buildNumber async =>
    (await PackageInfo.fromPlatform()).buildNumber;
