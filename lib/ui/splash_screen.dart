import '../appinfo.dart';
import '../dsbapi.dart';
import '../logging.dart';
import 'error_screen.dart';
import 'first_login.dart';
import '../uilib.dart';
import '../wpemails.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../prefs.dart' as Prefs;
import 'home_page.dart';

class _AmpBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => WillPopScope(
        child: MaterialApp(
          builder: (context, child) =>
              ScrollConfiguration(behavior: _AmpBehavior(), child: child),
          title: appTitle,
          home: SplashScreenPage(),
          debugShowCheckedModeBanner: false,
        ),
        onWillPop: () async => true,
      );
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
        return _currentPage == 0 ? AmpHomePage(0) : FirstLogin();
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
