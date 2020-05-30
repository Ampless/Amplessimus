import 'dart:io';

import 'package:amplissimus/animations.dart';
import 'package:amplissimus/dev_options/dev_options.dart';
import 'package:amplissimus/dsbapi.dart';
import 'package:amplissimus/logging.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:amplissimus/widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(SplashScreen());
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Prefs.loadPrefs();
    dsbUpdateWidget(() {});
    return MaterialApp(home: SplashScreenPage());
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  Color backgroundColor = AmpColors.blankBlack;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        backgroundColor = AmpColors.colorBackground;
      });
      Future.delayed(Duration(milliseconds: 1650), () {
        Animations.changeScreenEaseOutBack(new MyApp(initialIndex: 0,), context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'SplashScreen', message: 'Buiding Splash Screen');
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          height: double.infinity,
          width: double.infinity,
          color: backgroundColor,
          duration: Duration(milliseconds: 1000),
          child: Image(image: AssetImage('assets/images/logo.png')),
        ),
      ),
      backgroundColor: Colors.red,
    );
  }
}

class MyApp extends StatelessWidget {
  MyApp({@required this.initialIndex});
  final int initialIndex;
  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'MyApp', message: 'Building Main Page');
    return WillPopScope(
      child: MaterialApp(
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: AmpColors.primaryBlack,
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
  MyHomePage({Key key, this.title, @required this.textStyle, @required this.initialIndex}) : super(key: key);
  final int initialIndex;
  final String title;
  final TextStyle textStyle;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  void _incrementCounter() {
    setState(() {
      Prefs.saveCounter(Prefs.counter += 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'MyHomePage', message: 'Building...');
    while(dsbWidget is Container) sleep(Duration(milliseconds: 10));
    List<Widget> containers = [
      Container(
        child: Center(
          child: ListView(
            children: <Widget>[
              Text('${Prefs.counter}', style: TextStyle(color: AmpColors.colorForeground, fontSize: 30),),
              RaisedButton(
                child: Text('Häsch dini Ovo hüt scho ka?'),
                onPressed: () async {
                  dsbUpdateWidget(() => setState(() {}));
                },
              ),
              dsbWidget
            ],
          )
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
                child: Widgets.toggleDarkModeWidget(AmpColors.isDarkMode, widget.textStyle),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
              color: AmpColors.colorBackground,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  Widgets.showInputEntryCredentials(context);
                },
                child: Widgets.entryCredentialsWidget(AmpColors.isDarkMode, widget.textStyle),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
              color: AmpColors.colorBackground,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  Widgets.showInputSelectCurrentClass(context);
                },
                child: Widgets.setCurrentClassWidget(AmpColors.isDarkMode, widget.textStyle),
              ),
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
              color: AmpColors.colorBackground,
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  Animations.changeScreenEaseOutBack(DevOptionsScreen(), context);
                },
                child: Widgets.developerOptionsWidget(widget.textStyle),
              ),
            ),
          ],
        ),
      )
    ];
    return DefaultTabController(length: 2, initialIndex: widget.initialIndex,
      child: SafeArea(
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
            onPressed: () {
              _incrementCounter();
            },
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
      ),
    );
  }
  List<String> classes = ['5','6','7','8','9','10','11','12','13'];
  String currentSelectedDropdownClassValue = '5';
  String currentSelectedDropdownCharValue = 'A';
}

class NiceFullScreenScrollView extends StatelessWidget {
  final Widget displayWidget;
  NiceFullScreenScrollView(this.displayWidget);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmpColors.colorBackground,
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: displayWidget,
      )
    );
  }

}
