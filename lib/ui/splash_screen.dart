import '../appinfo.dart';
import '../dsbapi.dart';
import '../logging.dart';
import 'error_screen.dart';
import 'first_login.dart';
import '../uilib.dart';
import '../wpemails.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import '../prefs.dart' as prefs;
import 'home_page.dart';

class _Behavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;
}

class SplashScreen extends StatefulWidget {
  SplashScreen();
  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    prefs.load().then((_) async {
      try {
        if (!prefs.firstLogin) {
          final dsb = dsbUpdateWidget(true);
          await wpemailUpdate();
          await dsb;
        }
        setState(() => _loading = false);
      } catch (e) {
        ampErr('Splash.initState', errorString(e));
        await ampChangeScreen(ErrorScreenPage(), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        builder: (_, child) =>
            ScrollConfiguration(behavior: _Behavior(), child: child),
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: _loading ? null : prefs.themeData,
        home: _loading
            ? ampNull
            : prefs.firstLogin
                ? FirstLogin(this)
                : AmpHomePage(this, 0),
      );
}
