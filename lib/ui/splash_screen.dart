import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/ui/error_screen.dart';
import 'package:Amplessimus/ui/first_login.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/wpemails.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/colors.dart' as AmpColors;

class SplashScreen extends StatelessWidget {
  SplashScreen({
    Future<String> Function(Uri, Object, String, Map<String, String>) httpPost,
    Future<String> Function(Uri) httpGet,
  }) {
    if (httpPost != null) httpPostFunc = httpPost;
    if (httpGet != null) httpGetFunc = httpGet;
  }

  @override
  Widget build(BuildContext context) => ampMatApp(SplashScreenPage());
}

class SplashScreenPage extends StatefulWidget {
  SplashScreenPage();
  @override
  State<StatefulWidget> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  int _currentPage = -1;
  @override
  void initState() {
    super.initState();

    final loadPrefs = Prefs.load();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    loadPrefs.then((_) async {
      try {
        if (Prefs.useSystemTheme)
          AmpColors.brightness =
              SchedulerBinding.instance.window.platformBrightness;

        if (Prefs.firstLogin) return setState(() => _currentPage = 1);

        final dsb = dsbUpdateWidget(useJsonCache: true);
        final wpe = wpemailUpdate();

        await wpe;
        await dsb;

        setState(() => _currentPage = 0);
      } catch (e) {
        ampErr('Splash.initState', errorString(e));
        ampChangeScreen(ErrorScreenPage(), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      if (_currentPage != -1)
        return _currentPage == 0 ? AmpHomePage(0) : FirstLoginScreenPage();
      return Scaffold(
        backgroundColor: Colors.black,
        bottomSheet: ampLinearProgressIndicator(),
      );
    } catch (e) {
      ampErr('Splash.build', errorString(e));
      return ampText(errorString(e));
    }
  }
}
