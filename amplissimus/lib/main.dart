import 'dart:async';

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
    return MaterialApp(home: SplashScreenPage());
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  Color backgroundColor = AmpColors.blankWhite;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () async {
      setState(() => backgroundColor = AmpColors.colorBackground);
      await Prefs.loadPrefs();
      await dsbUpdateWidget(() {});
      Future.delayed(Duration(milliseconds: 1000), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp(initialIndex: 0),));
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
          child: Image.asset('assets/images/logo.png', scale: 5,),
        ),
      ),
      bottomSheet: LinearProgressIndicator(
        backgroundColor: AmpColors.blankGrey,
        valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
      ),
      backgroundColor: Colors.red,
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
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
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child);
        },
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground), 
          initialIndex: initialIndex,),
      ), 
      onWillPop: () {
        return new Future(() => Prefs.closeAppOnBackPress);
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
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  bool circularProgressIndicatorActive = false;

  void rebuild() {
    setState(() {});
  }

  Future<Null> rebuildDragDown() async {
    refreshKey.currentState?.show();
    await dsbUpdateWidget(rebuild, fetchDataAgain: true);
    return null;
  }

  Future<Null> rebuildNewBuild() async {
    setState(() {
      circularProgressIndicatorActive = true;
    });
    await dsbUpdateWidget(rebuild);
    setState(() {
      circularProgressIndicatorActive = false;
    });
    return null;
  }

  void showInputSelectCurrentClass(BuildContext context) {
    final gradeInputFormKey = GlobalKey<FormFieldState>();
    final charInputFormKey = GlobalKey<FormFieldState>();
    final gradeInputFormController = TextEditingController(text: Prefs.grade);
    final charInputFormController = TextEditingController(text: Prefs.char.toUpperCase());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Klasse auswählen', style: TextStyle(color: AmpColors.colorForeground),),
          backgroundColor: AmpColors.colorBackground,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  style: TextStyle(color: AmpColors.colorForeground),
                  controller: gradeInputFormController,
                  key: gradeInputFormKey,
                  validator: Widgets.gradeFieldValidator,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: AmpColors.colorForeground),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Stufe',
                    fillColor: AmpColors.colorForeground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AmpColors.colorForeground),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(6)),
              Flexible(
                child: TextFormField(
                  style: TextStyle(color: AmpColors.colorForeground),
                  controller: charInputFormController,
                  key: charInputFormKey,
                  validator: Widgets.letterFieldValidator,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: AmpColors.colorForeground),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Buchstabe',
                    fillColor: AmpColors.colorForeground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AmpColors.colorForeground),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('Abbrechen'),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                bool condA = gradeInputFormKey.currentState.validate();
                bool condB = charInputFormKey.currentState.validate();
                if(!condA || !condB) return;
                Prefs.grade = gradeInputFormController.text.trim();
                Prefs.char = charInputFormController.text.trim();
                rebuildNewBuild();
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  void showInputEntryCredentials(BuildContext context) {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController = TextEditingController(text: Prefs.username);
    final passwordInputFormController = TextEditingController(text: Prefs.password);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('DSB-Mobile Daten', style: TextStyle(color: AmpColors.colorForeground),),
          backgroundColor: AmpColors.colorBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style: TextStyle(color: AmpColors.colorForeground),
                controller: usernameInputFormController,
                key: usernameInputFormKey,
                validator: Widgets.textFieldValidator,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: TextStyle(color: AmpColors.colorForeground),
                  labelText: 'Benutzername',
                  fillColor: AmpColors.colorForeground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: AmpColors.colorForeground)
                  )
                ),
              ),
              Padding(padding: EdgeInsets.all(6)),
              TextFormField(
                style: TextStyle(color: AmpColors.colorForeground),
                controller: passwordInputFormController,
                key: passwordInputFormKey,
                validator: Widgets.textFieldValidator,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: AmpColors.colorForeground),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Passwort',
                  fillColor: AmpColors.colorForeground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AmpColors.colorForeground),
                  )
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('Abbrechen'),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                bool condA = passwordInputFormKey.currentState.validate();
                bool condB = usernameInputFormKey.currentState.validate();
                if (!condA || !condB) return;
                Prefs.username = usernameInputFormController.text.trim();
                Prefs.password = passwordInputFormController.text.trim();
                rebuildDragDown();
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Widget get changeSubVisibilityWidget {
    bool display = true;
    Widget widget;
    if(Prefs.grade == '' && Prefs.char == '') display = false;
    display ? widget = Stack(children: <Widget>[
      ListTile(title: Text('Alle Klassen', style: TextStyle(color: AmpColors.colorForeground),), trailing: Text('${Prefs.grade}${Prefs.char}', style: TextStyle(color: AmpColors.colorForeground),),),
      Align(child: Switch(activeColor: AmpColors.colorForeground, value: Prefs.oneClassOnly, onChanged: (value) {
        setState(() => Prefs.oneClassOnly = value);
        dsbUpdateWidget(rebuild);
      }), alignment: Alignment.center,),
    ],) : widget = Container(height: 0);
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    dsbApiHomeScaffoldKey = homeScaffoldKey;
    ampInfo(ctx: 'MyHomePage', message: 'Building MyHomePage...');
    if(dsbWidget is Container) rebuildNewBuild();
    List<Widget> containers = [
      Container(
        child: Scaffold(
          key: homeScaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AmpColors.colorBackground,
            title: Text('${AmpStrings.appTitle} ${Prefs.counter}', style: widget.textStyle,),
            centerTitle: true,
          ),
          backgroundColor: AmpColors.colorBackground,
          body: RefreshIndicator(
            key: refreshKey,
            child: !circularProgressIndicatorActive ? ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                dsbWidget,
                Divider(),
                changeSubVisibilityWidget,
                Padding(padding: EdgeInsets.all(30)),
              ],
            ) : Center(child: SizedBox(child: Widgets.loadingWidget(1),height: 200, width: 200,)
          ), onRefresh: rebuildDragDown),
        ),
        margin: EdgeInsets.all(16),
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
                onTap: () async {
                  AmpColors.changeMode();
                  dsbWidget = Container();
                  Animations.changeScreenNoAnimationReplace(new MyApp(initialIndex: 1,), context);
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
                  showInputEntryCredentials(context);
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
                onTap: () => showInputSelectCurrentClass(context),
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
                onTap: () => Animations.changeScreenEaseOutBackReplace(DevOptionsScreen(), context),
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
            onPressed: () => setState(() => Prefs.counter++),
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
          bottomSheet: Prefs.loadingBarEnabled ? LinearProgressIndicator(
            backgroundColor: AmpColors.blankGrey,
            valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
          ) : Container(height: 0,),
        )
      ),
    );
  }
}
