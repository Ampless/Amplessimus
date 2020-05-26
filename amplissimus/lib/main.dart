import 'package:amplissimus/animations.dart';
import 'package:amplissimus/dsbapi.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/screens/settings.dart';
import 'package:amplissimus/values.dart';
import 'package:amplissimus/widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() {
  runApp(SplashScreen());
}
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Prefs.loadPrefs();
    return MaterialApp(home: SplashScreenPage());
  }
}
class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {return SplashScreenPageState();}
}
class SplashScreenPageState extends State<SplashScreenPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 50), () {
      Animations.changeScreenEaseOutBack(new MyApp(), context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmpColors.blankBlack,
    );
  }

}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () {
        Animations.changeScreenNoAnimation(new MyApp(), context);
        return new Future(() => false);
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.textStyle}) : super(key: key);
  final String title;
  TextStyle textStyle;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;


  void _incrementCounter() {
    setState(() {
      _counter = Prefs.counter;
      _counter++;
      _counter++;
      Prefs.saveCounter(_counter);
    });
  }

  @override
  Widget build(BuildContext context) {
    _counter = Prefs.counter;
    return Scaffold(
      backgroundColor: AmpColors.colorBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:', style: widget.textStyle),
            Text('$_counter', style: TextStyle(color: AmpColors.colorForeground, fontSize: 30)),
            RaisedButton(
              onPressed: () async {
                Animations.changeScreenEaseOutBack(Klasse(await dsbGetString()), context);
              }
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AmpColors.colorBackground,
        splashColor: AmpColors.colorForeground,
        onPressed: _incrementCounter,
        icon: Icon(Icons.add, color: AmpColors.colorForeground,),
        label: Text('Zählen', style: widget.textStyle,),
      ),
      bottomNavigationBar: Widgets.bottomNavMenu(index: 0, onTapFunction: onNavBarTap), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void onNavBarTap(int index) {
    if(index == 0) return;
    Animations.changeScreenNoAnimation(new Settings(), context);
    ampLog(ctx: 'BottomNav', message: null);
  }
}

class Klasse extends StatelessWidget {
  String resp;
  Klasse(this.resp);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: Container(
            child: Text(resp))),
    );
  }

}
