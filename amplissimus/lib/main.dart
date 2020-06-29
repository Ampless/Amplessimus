import 'dart:async';
import 'dart:ui';

import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/screens/dev_options.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/first_login.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/screens/register_timetable.dart';
import 'package:Amplissimus/uilib.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/widgets.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  bool firstRefresh = true;
  String fileString = 'assets/anims/data-white-to-black.html';
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    (() async {
      await Prefs.loadPrefs();

      if (CustomValues.isAprilFools)
        Prefs.currentThemeId = -1;
      else if (Prefs.currentThemeId < 0) Prefs.currentThemeId = 0;

      if (Prefs.useSystemTheme)
        AmpColors.isDarkMode =
            SchedulerBinding.instance.window.platformBrightness ==
                Brightness.dark;

      if (Prefs.firstLogin) {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => FirstLoginScreen()));
        });
      } else {
        await dsbUpdateWidget(() {}, cacheJsonPlans: Prefs.useJsonCache);
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => MyApp(initialIndex: 0)));
        });
      }
    })();
  }

  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'SplashScreen', message: 'Buiding Splash Screen');
    return Scaffold(
      body: Center(
        child: AnimatedContainer(
          color: Colors.black,
          height: double.infinity,
          width: double.infinity,
          duration: Duration(milliseconds: 1000),
          child: FlareActor('assets/anims/splash_screen.flr',
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: 'anim'),
        ),
      ),
      bottomSheet: LinearProgressIndicator(
        backgroundColor: Colors.grey,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
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
          canvasColor: AmpColors.materialColorBackground,
          primarySwatch: AmpColors.materialColorForeground,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(
          title: AmpStrings.appTitle,
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
  MyHomePage({Key key, this.title, @required this.initialIndex})
      : super(key: key);
  final int initialIndex;
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static TabController tabController;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final settingsScaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Color fabBackgroundColor = AmpColors.colorBackground;
  bool circularProgressIndicatorActive = false;
  String gradeDropDownValue = Prefs.grade.trim().toLowerCase();
  String letterDropDownValue = Prefs.char.trim().toLowerCase();

  void checkBrightness() {
    if (Prefs.useSystemTheme &&
        (SchedulerBinding.instance.window.platformBrightness !=
                Brightness.light) !=
            Prefs.isDarkMode) {
      AmpColors.switchMode();
      setState(() {
        fabBackgroundColor = Colors.transparent;
        rebuildNewBuild();
      });
      Future.delayed(Duration(milliseconds: 150), () {
        setState(() => fabBackgroundColor = AmpColors.colorBackground);
      });
    }
  }

  @override
  void initState() {
    ampInfo(ctx: '_MyHomePageState', message: 'initState()');
    if (letterDropDownValue.isEmpty)
      letterDropDownValue = CustomValues.lang.empty;
    if (gradeDropDownValue.isEmpty)
      gradeDropDownValue = CustomValues.lang.empty;
    SchedulerBinding.instance.window.onPlatformBrightnessChanged =
        checkBrightness;
    super.initState();
    tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
    Prefs.setTimer(Prefs.timer, rebuildTimer);
  }

  void rebuild() {
    try {
      setState(() {});
      ampInfo(ctx: 'MyApp', message: 'rebuilt!');
    } catch (e) {
      ampInfo(ctx: '_MyHomePageState][rebuild', message: errorString(e));
    }
  }

  void rebuildTimer() {
    if (tabController.index == 0) dsbUpdateWidget(rebuild);
  }

  Future<Null> rebuildDragDown() async {
    refreshKey.currentState?.show();
    await dsbUpdateWidget(rebuild,
        cachePostRequests: false, cacheJsonPlans: Prefs.useJsonCache);
  }

  Future<Null> rebuildNewBuild() async {
    setState(() => circularProgressIndicatorActive = true);
    await dsbUpdateWidget(rebuild, cacheJsonPlans: Prefs.useJsonCache);
    setState(() => circularProgressIndicatorActive = false);
  }

  void showInputSelectCurrentClass(BuildContext context) {
    ampSelectionDialog(
      context: context,
      title: CustomValues.lang.selectClass,
      inputChildren: (alertContext, setAlState) => [
        ampDropdownButton(
          value: gradeDropDownValue,
          items: FirstLoginValues.grades
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            setAlState(() {
              gradeDropDownValue = value;
              if (gradeDropDownValue == CustomValues.lang.empty)
                Prefs.grade = '';
              else
                Prefs.grade = value;
            });
          },
        ),
        Padding(padding: EdgeInsets.all(10)),
        ampDropdownButton(
          value: letterDropDownValue,
          items: FirstLoginValues.letters
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (value) {
            setAlState(() {
              letterDropDownValue = value;
              if (letterDropDownValue == CustomValues.lang.empty)
                Prefs.char = '';
              else
                Prefs.char = value;
            });
          },
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: Navigator.of(context).pop,
        onSave: () {
          rebuildNewBuild();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void showInputChangeLanguage(BuildContext context) {
    Language lang = CustomValues.lang;
    ampSelectionDialog(
      context: context,
      title: CustomValues.lang.changeLanguage,
      inputChildren: (alertContext, setAlState) => [
        ampDropdownButton(
          value: lang,
          items: Language.all.map<DropdownMenuItem<Language>>((value) {
            return DropdownMenuItem<Language>(
                value: value, child: Text(value.name));
          }).toList(),
          onChanged: (value) => setAlState(() => lang = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: Navigator.of(context).pop,
        onSave: () {
          CustomValues.lang = lang;
          rebuildNewBuild();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void showInputEntryCredentials(BuildContext context) {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController =
        TextEditingController(text: Prefs.username);
    final passwordInputFormController =
        TextEditingController(text: Prefs.password);
    ampTextDialog(
      context: context,
      title: CustomValues.lang.changeLoginPopup,
      children: (context) => [
        ampFormField(
          controller: usernameInputFormController,
          key: usernameInputFormKey,
          validator: Widgets.textFieldValidator,
          labelText: CustomValues.lang.username,
        ),
        Padding(padding: EdgeInsets.all(6)),
        ampFormField(
          controller: passwordInputFormController,
          key: passwordInputFormKey,
          validator: Widgets.textFieldValidator,
          labelText: CustomValues.lang.password,
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: () => Navigator.of(context).pop(),
        onSave: () {
          bool condA = passwordInputFormKey.currentState.validate();
          bool condB = usernameInputFormKey.currentState.validate();
          if (!condA || !condB) return;
          Prefs.username = usernameInputFormController.text.trim();
          Prefs.password = passwordInputFormController.text.trim();
          rebuildDragDown();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget get changeSubVisibilityWidget {
    bool display = true;
    Widget widget;
    if (Prefs.grade == '' && Prefs.char == '') display = false;
    display
        ? widget = Stack(
            children: <Widget>[
              ListTile(
                title: Text(
                  CustomValues.lang.allClasses,
                  style: TextStyle(color: AmpColors.colorForeground),
                ),
                trailing: Text(
                  '${Prefs.grade}${Prefs.char}',
                  style: TextStyle(color: AmpColors.colorForeground),
                ),
              ),
              Align(
                  child: Switch(
                      activeColor: AmpColors.colorForeground,
                      value: Prefs.oneClassOnly,
                      onChanged: (value) {
                        setState(() => Prefs.oneClassOnly = value);
                        dsbUpdateWidget(rebuild,
                            cacheJsonPlans: Prefs.useJsonCache);
                      }),
                  alignment: Alignment.center),
            ],
          )
        : widget = Container(height: 0);
    return widget;
  }

  Widget _settingsWidget(
      {@required void Function() onTap, @required Widget child}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(32.0))),
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        customBorder: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(32.0))),
        onTap: onTap,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    dsbApiHomeScaffoldKey = homeScaffoldKey;
    ampInfo(ctx: 'MyHomePage', message: 'Building MyHomePage...');
    var textStyle = TextStyle(color: AmpColors.colorForeground);
    if (dsbWidget == null) rebuildNewBuild();
    List<Widget> containers = [
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
          key: homeScaffoldKey,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Text(
                '${AmpStrings.appTitle}${Prefs.counterEnabled ? ' ' + Prefs.counter.toString() : ''}',
                style:
                    TextStyle(fontSize: 25, color: AmpColors.colorForeground)),
            centerTitle: true,
          ),
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
              key: refreshKey,
              child: !circularProgressIndicatorActive
                  ? ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        dsbWidget,
                        Divider(),
                        changeSubVisibilityWidget,
                        Padding(padding: EdgeInsets.all(30))
                      ],
                    )
                  : Center(
                      child: SizedBox(
                      child: Widgets.loadingWidget(1),
                      height: 200,
                      width: 200,
                    )),
              onRefresh: rebuildDragDown),
        ),
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 2),
      ),
      Container(
        color: Colors.transparent,
        child: Prefs.jsonTimetable == null
            ? Center(
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: AmpColors.colorForeground,
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    Animations.changeScreenEaseOutBackReplace(
                        RegisterTimetableScreen(), context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        MdiIcons.timetable,
                        color: AmpColors.colorForeground,
                        size: 200,
                      ),
                      Text(
                        'Stundenplan\neinrichten',
                        style: TextStyle(
                            color: AmpColors.colorForeground, fontSize: 32),
                        textAlign: TextAlign.center,
                      ),
                      Padding(padding: EdgeInsets.all(10)),
                    ],
                  ),
                ),
              )
            : ListView(
                children: [],
              ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(32.0),
                  ),
                ),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32.0),
                    ),
                  ),
                  onTap: () {
                    Prefs.devOptionsTimerCache();
                    if (Prefs.timesToggleDarkModePressed >= 10) {
                      Prefs.devOptionsEnabled = !Prefs.devOptionsEnabled;
                      Prefs.timesToggleDarkModePressed = 0;
                    }
                    AmpColors.switchMode();
                    if (Prefs.useSystemTheme) Prefs.useSystemTheme = false;
                    setState(() {
                      fabBackgroundColor = Colors.transparent;
                      rebuildNewBuild();
                    });
                    Future.delayed(Duration(milliseconds: 150), () {
                      setState(
                          () => fabBackgroundColor = AmpColors.colorBackground);
                    });
                  },
                  child: Widgets.toggleDarkModeWidget(
                      AmpColors.isDarkMode, textStyle),
                ),
              ),
              _settingsWidget(
                onTap: () async {
                  if (CustomValues.isAprilFools) return;
                  ampInfo(ctx: 'MyApp', message: 'switching design mode');
                  if (Prefs.currentThemeId >= 1)
                    Prefs.currentThemeId = 0;
                  else
                    Prefs.currentThemeId++;
                  print(Prefs.currentThemeId);
                  await rebuildNewBuild();
                  settingsScaffoldKey.currentState?.showSnackBar(SnackBar(
                    backgroundColor: AmpColors.colorBackground,
                    content: Text('Aussehen des Vertretungsplans geändert!',
                        style: AmpColors.textStyleForeground),
                    action: SnackBarAction(
                      textColor: AmpColors.colorForeground,
                      label: 'Anzeigen',
                      onPressed: () => tabController.animateTo(0),
                    ),
                  ));
                },
                child: Widgets.toggleDesignModeWidget(
                    AmpColors.isDarkMode, textStyle),
              ),
              _settingsWidget(
                onTap: () {
                  Prefs.useSystemTheme = !Prefs.useSystemTheme;
                  if (Prefs.useSystemTheme) {
                    var brightness =
                        SchedulerBinding.instance.window.platformBrightness;
                    bool darkModeEnabled = brightness != Brightness.light;
                    if (darkModeEnabled != Prefs.isDarkMode) {
                      AmpColors.switchMode();
                      setState(() {
                        fabBackgroundColor = Colors.transparent;
                        rebuildNewBuild();
                      });
                      Future.delayed(Duration(milliseconds: 150), () {
                        setState(() =>
                            fabBackgroundColor = AmpColors.colorBackground);
                      });
                    }
                  }
                  rebuild();
                },
                child:
                    Widgets.lockOnSystemTheme(AmpColors.isDarkMode, textStyle),
              ),
              _settingsWidget(
                onTap: () => showInputChangeLanguage(context),
                child: Widgets.setLanguageWidget(textStyle),
              ),
              _settingsWidget(
                onTap: () => showInputEntryCredentials(context),
                child: Widgets.entryCredentialsWidget(
                    AmpColors.isDarkMode, textStyle),
              ),
              _settingsWidget(
                onTap: () => showInputSelectCurrentClass(context),
                child: Widgets.setCurrentClassWidget(
                    AmpColors.isDarkMode, textStyle),
              ),
              _settingsWidget(
                onTap: () => showAboutDialog(
                    context: context,
                    applicationName: AmpStrings.appTitle,
                    applicationVersion: AmpStrings.version,
                    applicationIcon:
                        Image.asset('assets/images/logo.png', height: 40),
                    children: [Text(CustomValues.lang.appInfo)]),
                child: Widgets.appInfoWidget(AmpColors.isDarkMode, textStyle),
              ),
              _settingsWidget(
                onTap: () {
                  if (Prefs.devOptionsEnabled)
                    Animations.changeScreenEaseOutBackReplace(
                        DevOptionsScreen(), context);
                },
                child: Widgets.developerOptionsWidget(textStyle),
              ),
            ],
          ),
        ),
      )
    ];
    return SafeArea(
        child: Stack(
      children: <Widget>[
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
          floatingActionButton: Prefs.counterEnabled
              ? FloatingActionButton.extended(
                  elevation: 0,
                  backgroundColor: fabBackgroundColor,
                  splashColor: AmpColors.colorForeground,
                  onPressed: () => setState(() => Prefs.counter += 2),
                  icon: Icon(
                    Icons.add,
                    color: AmpColors.colorForeground,
                  ),
                  label: Text(
                    'Zählen',
                    style: TextStyle(color: AmpColors.colorForeground),
                  ),
                )
              : Container(),
          bottomNavigationBar: SizedBox(
            height: 55,
            child: TabBar(
              controller: tabController,
              indicatorColor: AmpColors.colorForeground,
              labelColor: AmpColors.colorForeground,
              tabs: <Widget>[
                Tab(icon: Icon(Icons.home), text: CustomValues.lang.start),
                Tab(
                    icon: Icon(MdiIcons.timetable),
                    text: CustomValues.lang.timetable),
                Tab(
                    icon: Icon(Icons.settings),
                    text: CustomValues.lang.settings)
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomSheet: Prefs.loadingBarEnabled
              ? LinearProgressIndicator(
                  backgroundColor: AmpColors.blankGrey,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
                )
              : Container(height: 0),
        )
      ],
    ));
  }
}
