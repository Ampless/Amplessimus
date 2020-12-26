import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

import 'appinfo.dart';
import 'dsbapi.dart';
import 'logging.dart';
import 'ui/error_screen.dart';
import 'ui/first_login.dart';
import 'ui/home_page.dart';
import 'wpemails.dart';
import 'prefs.dart' as prefs;

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
      builder: (_, child) =>
          ScrollConfiguration(behavior: _Behavior(), child: child),
      title: appTitle,
      debugShowCheckedModeBanner: false,
      theme: prefs.themeData,
      home: prefs.firstLogin ? FirstLogin() : AmpHomePage(0),
    );
  }
}

var rebuildWholeApp;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prefs.load().then((_) async {
    try {
      if (!prefs.firstLogin) {
        final dsb = dsbUpdateWidget(true);
        await wpemailUpdate();
        await dsb;
      }
      runApp(_App());
    } catch (e) {
      ampErr('Splash.initState', errorString(e));
      await runApp(ErrorScreenPage());
    }
  });
}
