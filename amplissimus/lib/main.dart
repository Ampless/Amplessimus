import 'package:amplissimus/animations.dart';
import 'package:amplissimus/dsbapi.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
      Animations.changeScreenEaseOutBack(new MyApp(initialIndex: 0,), context);
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
  MyApp({this.initialIndex});
  int initialIndex = 0;
  @override
  Widget build(BuildContext context) {
    ampLog(ctx: 'MyApp', message: 'Building Main Page');
    return WillPopScope(
      child: MaterialApp(
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground), 
          initialIndex: initialIndex,),
      ), 
      onWillPop: () {
        Animations.changeScreenNoAnimation(this, context);
        return new Future(() => false);
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, @required this.textStyle, this.initialIndex}) : super(key: key);
  int initialIndex = 0;
  final String title;
  TextStyle textStyle;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = Prefs.counter;

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
    List<Widget> containers = [
      Container(
        child: Center(
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
      ),
      Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
              color: AmpColors.colorBackground,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  AmpColors.changeMode();
                  Animations.changeScreenNoAnimation(new MyApp(initialIndex: 1,), context);
                },
                child: toggleDarkModeWidget(AmpColors.isDarkMode),
              ),
            ),
          ],
        ),
      )
    ];
    _counter = Prefs.counter;
    return DefaultTabController(length: 2, initialIndex: widget.initialIndex,
      child: Scaffold(
        backgroundColor: AmpColors.colorBackground,
        body: TabBarView(
          physics: ClampingScrollPhysics(),
          children: containers,
        ),
        floatingActionButton: FloatingActionButton.extended(
          hoverColor: AmpColors.colorForeground,
          elevation: 0,
          backgroundColor: AmpColors.colorBackground,
          splashColor: AmpColors.colorForeground,
          onPressed: _incrementCounter,
          icon: Icon(Icons.add, color: AmpColors.colorForeground,),
          label: Text('Zählen', style: widget.textStyle,),
        ),
        bottomNavigationBar: SizedBox(
          height: 55,
          child: TabBar(
            indicatorColor: AmpColors.colorForeground,
            labelColor: AmpColors.colorForeground,
            tabs: <Widget>[
              new Tab(
                icon: Icon(Icons.home),
                text: 'Start',
              ),
              new Tab(
                icon: Icon(Icons.settings),
                text: 'Einstellungen',
              )
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    );
  }
  Widget toggleDarkModeWidget(bool isDarkMode) {
    if(isDarkMode) {
      return Center(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(24)),
            Icon(MdiIcons.lightbulbOn, size: 50, color: AmpColors.colorForeground,),
            Padding(padding: EdgeInsets.all(10)),
            Text('Licht an', style: widget.textStyle,)
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(24)),
            Icon(MdiIcons.lightbulbOnOutline, size: 50, color: AmpColors.colorForeground,),
            Padding(padding: EdgeInsets.all(10)),
            Text('Licht aus', style: widget.textStyle,)
          ],
        ),
      );
    }
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
