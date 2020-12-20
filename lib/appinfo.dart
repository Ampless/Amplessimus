import 'package:package_info/package_info.dart';

const String appTitle = 'Amplessimus';
Future<String> get appVersion async =>
    (await PackageInfo.fromPlatform()).version;
