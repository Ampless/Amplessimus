import 'package:amplissimus/animations.dart';
import 'package:amplissimus/dsbapi.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
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
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  AmpColors.changeMode();
                  Animations.changeScreenNoAnimation(new MyApp(), context);
                },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(24)),
                      Icon(MdiIcons.lightbulbOn, size: 50, color: AmpColors.colorForeground,),
                      Padding(padding: EdgeInsets.all(10)),
                      Text('Toogle Dark Mode', style: widget.textStyle,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    ];
    _counter = Prefs.counter;
    return DefaultTabController(length: 2, 
      child: Scaffold(
        backgroundColor: AmpColors.colorBackground,
        body: TabBarView(
          children: containers,
        ),
        bottomSheet: TabBar(

          indicatorColor: AmpColors.blankBlack,
          labelColor: AmpColors.blankBlack,
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
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: AmpColors.colorBackground,
          splashColor: AmpColors.colorForeground,
          onPressed: _incrementCounter,
          icon: Icon(Icons.add, color: AmpColors.colorForeground,),
          label: Text('Zählen', style: widget.textStyle,),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      )
    );
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
