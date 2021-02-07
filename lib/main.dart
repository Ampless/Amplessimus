import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
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

Future<void> loadPrefs() async {
  _prefs = Prefs(await SharedPreferences.getInstance());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  ampInfo('prefs', 'Loading SharedPreferences...');
  await loadPrefs();
  ampInfo('prefs', 'SharedPreferences (hopefully successfully) loaded.');
  try {
    if (!prefs.firstLogin) {
      final d = dsb.updateWidget(true);
      await wpemailUpdate();
      await d;
    }
    runApp(_App());
  } catch (e) {
    ampErr('Splash.initState', errorString(e));
    runApp(ErrorScreen());
  }
}
