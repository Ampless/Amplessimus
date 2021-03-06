import 'package:flutter/material.dart';
import 'package:schttp/schttp.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'appinfo.dart';
import 'dsbapi.dart' as dsb;
import 'logging.dart';
import 'ui/error_screen.dart';
import 'ui/first_login.dart';
import 'ui/home_page.dart';
import 'wpemails.dart';
import 'prefs.dart';

class _Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;
}

class _App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<_App> {
  @override
  Widget build(BuildContext context) {
    rebuildWholeApp = () => setState(() {});
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: prefs.themeData,
      home: ScrollConfiguration(
        behavior: _Behavior(),
        child: prefs.firstLogin ? FirstLogin() : AmpHomePage(0),
      ),
    );
  }
}

var rebuildWholeApp;
Prefs? _prefs;
Prefs get prefs => _prefs!;
final http = ScHttpClient(prefs.getCache, prefs.setCache);

Future<void> loadPrefs() async {
  ampInfo('prefs', 'Loading SharedPreferences...');
  _prefs = Prefs(await SharedPreferences.getInstance());
  ampInfo('prefs', 'SharedPreferences (hopefully successfully) loaded.');
}

Future<void> mockPrefs() async {
  _prefs = Prefs(null);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadPrefs();
  try {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      prefs.deleteCache((hash, val, ttl) => now > ttl);
    } catch (e) {
      ampErr('CacheGC', e);
    }

    if (!prefs.firstLogin) {
      final d = dsb.updateWidget(true);
      await wpemailUpdate();
      await d;
    }

    runApp(_App());
  } catch (e) {
    ampErr('Splash.initState', e);
    runApp(ErrorScreen());
  }
}
