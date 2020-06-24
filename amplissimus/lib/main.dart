import 'dart:async';
import 'dart:ui';

import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/dev_options/dev_options.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/first_login.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/widgets.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(SplashScreen());
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ampLogDebugInit(); //always comment out before committing
    return MaterialApp(title: AmpStrings.appTitle, home: SplashScreenPage());
  }
}

class SplashScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashScreenPageState();
}

class SplashScreenPageState extends State<SplashScreenPage> {
  String fileString = 'assets/anims/data-white-to-black.html';
  Color backgroundColor = AmpColors.blankWhite;
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.initState();
    Future.delayed(Duration(milliseconds: 50), () async {
      await Prefs.loadPrefs();
      setState(() => backgroundColor = AmpColors.colorBackground);
      CustomValues.checkForAprilFools();

      if(CustomValues.isAprilFools) Prefs.currentThemeId = -1;
      else if(Prefs.currentThemeId < 0) Prefs.currentThemeId = 0;

      if(Prefs.useSystemTheme && (SchedulerBinding.instance.window.platformBrightness != Brightness.light) != Prefs.designMode)
        AmpColors.changeMode();

      if(Prefs.firstLogin) {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirstLoginScreen()));
        });
      } else {
        await dsbUpdateWidget(() {}, cacheJsonPlans: Prefs.useJsonCache);
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp(initialIndex: 0)));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'SplashScreen', message: 'Buiding Splash Screen');
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          color: backgroundColor,
          height: double.infinity,
          width: double.infinity,
          duration: Duration(milliseconds: 1000),
          child: FlareActor(
            'assets/anims/splash_screen.flr',
            alignment:Alignment.center, 
            fit:BoxFit.contain, 
            animation:'anim'
          ),
        ),
      ),
      bottomSheet: LinearProgressIndicator(
        backgroundColor: AmpColors.blankGrey,
        valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) => child;
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
          canvasColor: Prefs.designMode ? AmpColors.primaryBlack : AmpColors.primaryWhite,
          primarySwatch: Prefs.designMode ? AmpColors.primaryWhite : AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(
          title: AmpStrings.appTitle,
          textStyle: TextStyle(
            color: AmpColors.colorForeground,
          ), 
          initialIndex: initialIndex,
        ),
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

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController tabController;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final settingsScaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Color fabBackgroundColor = AmpColors.colorBackground;
  bool circularProgressIndicatorActive = false;
  String gradeDropDownValue = Prefs.grade.trim().toLowerCase();
  String letterDropDownValue = Prefs.char.trim().toLowerCase();

  @override
  void initState() {
    if(Prefs.char.trim().toLowerCase().isEmpty)
      letterDropDownValue = CustomValues.lang.classSelectorEmpty;
    if(Prefs.grade.trim().toLowerCase().isEmpty)
      gradeDropDownValue = CustomValues.lang.classSelectorEmpty;
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  void rebuild() => setState(() {});

  Future<void> rebuildDragDown() async {
    refreshKey.currentState?.show();
    await dsbUpdateWidget(rebuild, cachePostRequests: false, cacheJsonPlans: Prefs.useJsonCache);
  }

  Future<void> rebuildNewBuild() async {
    setState(() => circularProgressIndicatorActive = true);
    await dsbUpdateWidget(rebuild, cacheJsonPlans: Prefs.useJsonCache);
    setState(() => circularProgressIndicatorActive = false);
  }

  void showInputSelectCurrentClass(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(CustomValues.lang.settingsSelectClass, style: TextStyle(color: AmpColors.colorForeground),),
          backgroundColor: AmpColors.colorBackground,
          content: StatefulBuilder(builder: (BuildContext alertContext, StateSetter setAlState) {
            return Theme(child: Row(mainAxisSize: MainAxisSize.min, children: [
              DropdownButton(
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                style: TextStyle(color: AmpColors.colorForeground,),
                value: gradeDropDownValue,
                items: FirstLoginValues.grades.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setAlState(() {
                    gradeDropDownValue = value;
                    if(gradeDropDownValue == CustomValues.lang.classSelectorEmpty)
                      Prefs.grade = '';
                    else Prefs.grade = value;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(10)),
              DropdownButton(
                underline: Container(
                  height: 2,
                  color: Colors.white,
                ),
                style: TextStyle(color: AmpColors.colorForeground),
                value: letterDropDownValue,
                items: FirstLoginValues.letters.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setAlState(() {
                    letterDropDownValue = value;
                    if(letterDropDownValue == CustomValues.lang.classSelectorEmpty)
                      Prefs.char = '';
                    else Prefs.char = value;
                  });
                },
              ),
            ]), data: ThemeData(canvasColor: Prefs.designMode ? AmpColors.primaryBlack : AmpColors.primaryWhite));
          }),
          actions: <Widget>[
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () => {Navigator.of(context).pop()},
              child: Text(CustomValues.lang.settingsChangeLoginPopupCancel),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                rebuildNewBuild();
                Navigator.of(context).pop();
              },
              child: Text(CustomValues.lang.settingsChangeLoginPopupSave),
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
          title: Text(CustomValues.lang.settingsChangeLoginPopup, style: TextStyle(color: AmpColors.colorForeground),),
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
                  labelText: CustomValues.lang.settingsChangeLoginPopupUsername,
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
                  labelText: CustomValues.lang.settingsChangeLoginPopupPassword,
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(CustomValues.lang.settingsChangeLoginPopupCancel),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                bool condA = passwordInputFormKey.currentState.validate();
                bool condB = usernameInputFormKey.currentState.validate();
                if(!condA || !condB) return;
                Prefs.username = usernameInputFormController.text.trim();
                Prefs.password = passwordInputFormController.text.trim();
                rebuildDragDown();
                Navigator.of(context).pop();
              },
              child: Text(CustomValues.lang.settingsChangeLoginPopupSave),
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
      ListTile(title: Text(CustomValues.lang.dsbUiAllClasses, style: TextStyle(color: AmpColors.colorForeground),), trailing: Text('${Prefs.grade}${Prefs.char}', style: TextStyle(color: AmpColors.colorForeground),),),
      Align(child: Switch(activeColor: AmpColors.colorForeground, value: Prefs.oneClassOnly, onChanged: (value) {
        setState(() => Prefs.oneClassOnly = value);
        dsbUpdateWidget(rebuild, cacheJsonPlans: Prefs.useJsonCache);
      }), alignment: Alignment.center),
    ],) : widget = Container(height: 0);
    return widget;
  }

  @override
  Widget build(BuildContext context) {
    dsbApiHomeScaffoldKey = homeScaffoldKey;
    ampInfo(ctx: 'MyHomePage', message: 'Building MyHomePage...');
    var textStyle = TextStyle(color: AmpColors.colorForeground);
    if(dsbWidget == null) rebuildNewBuild();
    List<Widget> containers = [
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
          key: homeScaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text('${AmpStrings.appTitle} ${Prefs.counterEnabled ? Prefs.counter : ''}', style: TextStyle(fontSize: 25, color: AmpColors.colorForeground)),
            centerTitle: true,
          ),
          backgroundColor: Colors.transparent,
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
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: Colors.transparent,
        child: Scaffold(
          key: settingsScaffoldKey,
          backgroundColor: Colors.transparent,
          body: GridView.count(
            crossAxisCount: 2,
            children: <Widget>[
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () async {
                    Prefs.devOptionsTimerCache();
                    if(Prefs.timesToggleDarkModePressed >= 10) {
                      Prefs.devOptionsEnabled = !Prefs.devOptionsEnabled;
                      Prefs.timesToggleDarkModePressed = 0;
                    }
                    AmpColors.changeMode();
                    if(Prefs.useSystemTheme) Prefs.useSystemTheme = false;
                    setState(() {
                      fabBackgroundColor = Colors.transparent;
                      rebuildNewBuild();
                    });
                    Future.delayed(Duration(milliseconds: 150), () {
                      setState(() => fabBackgroundColor = AmpColors.colorBackground);
                    });
                  },
                  child: Widgets.toggleDarkModeWidget(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () async {
                    if(CustomValues.isAprilFools) return;
                    ampInfo(ctx: 'MyApp', message: 'switching design mode');
                    if(Prefs.currentThemeId >= 1) Prefs.currentThemeId = 0; 
                    else Prefs.currentThemeId++;
                    await rebuildNewBuild();
                    tabController.animateTo(0);
                  },
                  child: Widgets.toggleDesignModeWidget(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () async {
                    Prefs.useSystemTheme = !Prefs.useSystemTheme;
                    if(Prefs.useSystemTheme) {
                      var brightness = SchedulerBinding.instance.window.platformBrightness;
                      bool darkModeEnabled = brightness == Brightness.dark;
                      if(darkModeEnabled != Prefs.designMode) {
                        AmpColors.changeMode();
                      }
                    }
                    rebuild();
                  },
                  child: Widgets.lockOnSystemTheme(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: AmpStrings.appTitle,
                      applicationVersion: AmpStrings.version,
                      applicationIcon: Image.asset('assets/images/logo.png', height: 40,),
                      children: [
                        Text(CustomValues.lang.appInfo)
                      ]
                    );
                  },
                  child: Widgets.appInfoWidget(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () {
                    showInputEntryCredentials(context);
                  },
                  child: Widgets.entryCredentialsWidget(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () => showInputSelectCurrentClass(context),
                  child: Widgets.setCurrentClassWidget(AmpColors.isDarkMode, textStyle),
                ),
              ),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                  onTap: () {
                    if(Prefs.devOptionsEnabled) Animations.changeScreenEaseOutBackReplace(DevOptionsScreen(), context);
                  },
                  child: Prefs.devOptionsEnabled ? Widgets.developerOptionsWidget(textStyle) : Container(),
                ),
              ),
            ],
          ),
        ),
      )
    ];
    return SafeArea(
      child: Stack(children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 150),
          color: AmpColors.colorBackground,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: TabBarView(
            controller: tabController,
            physics: ClampingScrollPhysics(),
            children: containers,
          ),
          floatingActionButton: Prefs.counterEnabled ? FloatingActionButton.extended(
            elevation: 0,
            backgroundColor: fabBackgroundColor,
            splashColor: AmpColors.colorForeground,
            onPressed: () => setState(() => Prefs.counter += 2),
            icon: Icon(Icons.add, color: AmpColors.colorForeground,),
            label: Text('Zählen', style: TextStyle(color: AmpColors.colorForeground),),
          ) : Container(),
          bottomNavigationBar: SizedBox(
            height: 55,
            child: TabBar(
              controller: tabController,
              indicatorColor: AmpColors.colorForeground,
              labelColor: AmpColors.colorForeground,
              tabs: <Widget>[
                new Tab(
                  icon: Icon(Icons.home),
                  text: CustomValues.lang.menuStart,
                ),
                new Tab(
                  icon: Icon(Icons.settings),
                  text: CustomValues.lang.menuSettings,
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
      ],)
      
    );
  }
}
