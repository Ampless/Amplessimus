import 'dart:async';
import 'dart:ui';

import 'package:Amplessimus/animations.dart';
import 'package:Amplessimus/screens/dev_options.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/screens/register_timetable.dart';
import 'package:Amplessimus/timetable/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/validators.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:pedantic/pedantic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() {
  runApp(SplashScreen());
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: AmpStrings.appTitle, home: SplashScreenPage());
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
      CustomValues.ttColumns = ttLoadFromPrefs();

      if (CustomValues.isAprilFools)
        Prefs.currentThemeId = -1;
      else if (Prefs.currentThemeId < 0) Prefs.currentThemeId = 0;

      if (Prefs.useSystemTheme)
        AmpColors.isDarkMode =
            SchedulerBinding.instance.window.platformBrightness ==
                Brightness.dark;

      if (!Prefs.firstLogin) await dsbUpdateWidget();

      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Prefs.firstLogin ? FirstLoginScreen() : AmpApp(),
          ),
        );
      });
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
          child: FlareActor('assets/anims/splash_screen.json',
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

class AmpApp extends StatelessWidget {
  AmpApp({this.initialIndex = 0});
  final int initialIndex;
  @override
  Widget build(BuildContext context) {
    ampInfo(ctx: 'AmpApp', message: 'Building Main Page');
    return WillPopScope(
      child: ampMatApp(
        title: AmpStrings.appTitle,
        home: AmpHomePage(initialIndex: initialIndex),
      ),
      onWillPop: () => Future(() => Prefs.closeAppOnBackPress),
    );
  }
}

class AmpHomePage extends StatefulWidget {
  AmpHomePage({Key key, @required this.initialIndex}) : super(key: key);
  final int initialIndex;
  @override
  AmpHomePageState createState() => AmpHomePageState();
}

class AmpHomePageState extends State<AmpHomePage>
    with SingleTickerProviderStateMixin {
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  final settingsScaffoldKey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  Color fabBackgroundColor = AmpColors.colorBackground;
  bool circularProgressIndicatorActive = false;
  String gradeDropDownValue = Prefs.grade.trim().toLowerCase();
  String letterDropDownValue = Prefs.char.trim().toLowerCase();
  bool passwordHidden = true;
  int _currentIndex;
  TabController tabController;

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
    ampInfo(ctx: 'AmpHomePageState', message: 'initState()');
    if (letterDropDownValue.isEmpty)
      letterDropDownValue = FirstLoginValues.grades[0];
    if (gradeDropDownValue.isEmpty)
      gradeDropDownValue = FirstLoginValues.grades[0];
    SchedulerBinding.instance.window.onPlatformBrightnessChanged =
        checkBrightness;
    super.initState();
    _currentIndex = widget.initialIndex;
    tabController =
        TabController(length: 3, vsync: this, initialIndex: _currentIndex);
    Prefs.setTimer(Prefs.timer, rebuildTimer);
  }

  void rebuild() {
    try {
      setState(() {});
      ampInfo(ctx: 'AmpApp', message: 'rebuilt!');
    } catch (e) {
      ampInfo(ctx: 'AmpHomePageState][rebuild', message: errorString(e));
    }
  }

  void rebuildTimer() {
    dsbUpdateWidget(callback: rebuild);
  }

  Future<Null> rebuildDragDown() async {
    unawaited(refreshKey.currentState?.show());
    await dsbUpdateWidget(callback: rebuild, cachePostRequests: false);
  }

  Future<Null> rebuildNewBuild() async {
    setState(() => circularProgressIndicatorActive = true);
    await dsbUpdateWidget();
    setState(() => circularProgressIndicatorActive = false);
  }

  void showInputSelectCurrentClass(BuildContext context) async {
    if (Prefs.char.trim().isEmpty)
      letterDropDownValue = FirstLoginValues.letters[0];
    if (Prefs.grade.trim().isEmpty)
      gradeDropDownValue = FirstLoginValues.grades[0];
    if (!FirstLoginValues.letters.contains(letterDropDownValue)) return;
    if (!FirstLoginValues.grades.contains(gradeDropDownValue)) return;
    await ampDialog(
      context: context,
      title: CustomValues.lang.selectClass,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: gradeDropDownValue,
          items: FirstLoginValues.grades
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: ampText(value),
            );
          }).toList(),
          onChanged: (value) {
            setAlState(() {
              gradeDropDownValue = value;
              Prefs.grade = value;
            });
          },
        ),
        ampPadding(10),
        ampDropdownButton(
          value: letterDropDownValue,
          items: FirstLoginValues.letters
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: ampText(value),
            );
          }).toList(),
          onChanged: (value) {
            setAlState(() {
              letterDropDownValue = value;
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
      rowOrColumn: ampRow,
    );
  }

  void showInputChangeLanguage(BuildContext context) {
    var lang = CustomValues.lang;
    var use = Prefs.dsbUseLanguage;
    ampDialog(
      context: context,
      title: CustomValues.lang.changeLanguage,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: lang,
          items: Language.all.map<DropdownMenuItem<Language>>((value) {
            return DropdownMenuItem<Language>(
              value: value,
              child: ampText(value.name),
            );
          }).toList(),
          onChanged: (value) => setAlState(() => lang = value),
        ),
        ampSizedDivider(5),
        ampSwitchWithText(
          text: CustomValues.lang.useForDsb,
          value: use,
          onChanged: (value) => setAlState(() => use = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: Navigator.of(context).pop,
        onSave: () {
          CustomValues.lang = lang;
          Prefs.dsbUseLanguage = use;
          rebuildNewBuild();

          FirstLoginValues.grades[0] = CustomValues.lang.empty;
          FirstLoginValues.letters[0] = CustomValues.lang.empty;
          Navigator.of(context).pop();
        },
      ),
      rowOrColumn: ampColumn,
    );
  }

  void showInputEntryCredentials(BuildContext context) {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController =
        TextEditingController(text: Prefs.username);
    final passwordInputFormController =
        TextEditingController(text: Prefs.password);
    ampDialog(
      context: context,
      title: CustomValues.lang.changeLoginPopup,
      children: (context, setAlState) => [
        ampPadding(2),
        ampFormField(
          controller: usernameInputFormController,
          key: usernameInputFormKey,
          validator: textFieldValidator,
          labelText: CustomValues.lang.username,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: [AutofillHints.username],
        ),
        ampPadding(6),
        ampFormField(
          suffixIcon: IconButton(
            onPressed: () => setAlState(() => passwordHidden = !passwordHidden),
            icon: passwordHidden
                ? ampIcon(Icons.visibility)
                : ampIcon(Icons.visibility_off),
          ),
          controller: passwordInputFormController,
          key: passwordInputFormKey,
          validator: textFieldValidator,
          labelText: CustomValues.lang.password,
          keyboardType: TextInputType.visiblePassword,
          obscureText: passwordHidden,
          autofillHints: [AutofillHints.password],
        )
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: () => Navigator.of(context).pop(),
        onSave: () {
          var condA = passwordInputFormKey.currentState.validate();
          var condB = usernameInputFormKey.currentState.validate();
          if (!condA || !condB) return;
          Prefs.username = usernameInputFormController.text.trim();
          Prefs.password = passwordInputFormController.text.trim();
          rebuildDragDown();
          Navigator.of(context).pop();
        },
      ),
      rowOrColumn: ampColumn,
    );
  }

  Widget get changeSubVisibilityWidget {
    var display = true;
    if (Prefs.grade == '' && Prefs.char == '') display = false;
    return display
        ? Stack(
            children: <Widget>[
              ListTile(
                title: ampText(CustomValues.lang.allClasses),
                trailing: ampText('${Prefs.grade}${Prefs.char}'),
              ),
              Align(
                  child: Switch(
                      activeColor: AmpColors.colorForeground,
                      value: Prefs.oneClassOnly,
                      onChanged: (value) {
                        Prefs.oneClassOnly = value;
                        dsbUpdateWidget(callback: rebuild);
                      }),
                  alignment: Alignment.center),
            ],
          )
        : ampNull;
  }

  int lastUpdate = 0;
  @override
  Widget build(BuildContext context) {
    dsbApiHomeScaffoldKey = homeScaffoldKey;
    ampInfo(ctx: 'MyHomePage', message: 'Building MyHomePage...');
    if (dsbWidget == null) {
      rebuildNewBuild();
      lastUpdate = DateTime.now().millisecondsSinceEpoch;
    }
    if (lastUpdate <
        DateTime.now()
            .subtract(Duration(minutes: Prefs.timer))
            .millisecondsSinceEpoch) {
      rebuildDragDown();
      lastUpdate = DateTime.now().millisecondsSinceEpoch;
    }
    var containers = [
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
          key: homeScaffoldKey,
          appBar: ampAppBar(AmpStrings.appTitle),
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
              key: refreshKey,
              child: !circularProgressIndicatorActive
                  ? ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: [
                        dsbWidget,
                        ampDivider,
                        changeSubVisibilityWidget,
                        //ampRaisedButton(text: 'rebuild', onPressed: rebuild),
                      ],
                    )
                  : Center(
                      child: SizedBox(
                      child: SpinKitWave(
                        size: 100,
                        duration: Duration(milliseconds: 1050),
                        color: AmpColors.colorForeground,
                      ),
                      height: 200,
                      width: 200,
                    )),
              onRefresh: rebuildDragDown),
        ),
        margin: EdgeInsets.only(left: 8, right: 8, bottom: 2),
      ),
      Scaffold(
        appBar: ampAppBar(CustomValues.lang.timetable),
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(left: 10, right: 10),
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
                        ampIcon(MdiIcons.timetable, size: 200),
                        ampText(
                          CustomValues.lang.setupTimetable,
                          size: 32,
                          textAlign: TextAlign.center,
                        ),
                        ampPadding(10),
                      ],
                    ),
                  ),
                )
              : ListView(
                  children: [
                    Column(
                      children: timetableWidget(
                        timetablePlans,
                        filtered: Prefs.filterTimetables,
                      ),
                    ),
                    ampDivider,
                    ampSwitchWithText(
                      text: CustomValues.lang.filterTimetables,
                      value: Prefs.filterTimetables,
                      onChanged: (value) =>
                          setState(() => Prefs.filterTimetables = value),
                    ),
                    ampPadding(24),
                  ],
                ),
        ),
        floatingActionButton: Prefs.jsonTimetable != null
            ? ampFab(
                onPressed: () => Animations.changeScreenEaseOutBackReplace(
                    RegisterTimetableScreen(), context),
                label: CustomValues.lang.edit,
                icon: Icons.edit,
              )
            : ampNull,
      ),
      AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: Colors.transparent,
        child: Scaffold(
          key: settingsScaffoldKey,
          backgroundColor: Colors.transparent,
          body: GridView.count(
            crossAxisCount: 2,
            children: FirstLoginValues.settingsButtons = <Widget>[
              ampBigAmpButton(
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
                icon: AmpColors.isDarkMode
                    ? MdiIcons.lightbulbOn
                    : MdiIcons.lightbulbOnOutline,
                text: AmpColors.isDarkMode
                    ? CustomValues.lang.lightsOn
                    : CustomValues.lang.lightsOff,
              ),
              ampBigAmpButton(
                onTap: () async {
                  if (CustomValues.isAprilFools) return;
                  ampInfo(ctx: 'MyApp', message: 'switching design mode');
                  if (Prefs.currentThemeId >= 1)
                    Prefs.currentThemeId = 0;
                  else
                    Prefs.currentThemeId++;
                  await rebuildNewBuild();
                  settingsScaffoldKey.currentState?.showSnackBar(SnackBar(
                    backgroundColor: AmpColors.colorBackground,
                    content: ampText(CustomValues.lang.changedAppearance),
                    action: SnackBarAction(
                      textColor: AmpColors.colorForeground,
                      label: CustomValues.lang.show,
                      onPressed: () => setState(() => _currentIndex = 0),
                    ),
                  ));
                },
                icon: AmpColors.isDarkMode
                    ? MdiIcons.clipboardList
                    : MdiIcons.clipboardListOutline,
                text: CustomValues.lang.changeAppearance,
              ),
              ampBigAmpButton(
                onTap: () {
                  var ust = !Prefs.useSystemTheme;
                  setState(() => Prefs.useSystemTheme = ust);
                  if (ust) {
                    var brightness =
                        SchedulerBinding.instance.window.platformBrightness;
                    var darkModeEnabled = brightness != Brightness.light;
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
                icon: MdiIcons.brightness6,
                text: Prefs.useSystemTheme
                    ? CustomValues.lang.lightsNoSystem
                    : CustomValues.lang.lightsUseSystem,
              ),
              ampBigAmpButton(
                onTap: () => showInputChangeLanguage(context),
                icon: MdiIcons.translate,
                text: CustomValues.lang.changeLanguage,
              ),
              ampBigAmpButton(
                onTap: () => showInputEntryCredentials(context),
                icon: AmpColors.isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
                text: CustomValues.lang.changeLogin,
              ),
              ampBigAmpButton(
                onTap: () => showInputSelectCurrentClass(context),
                icon: AmpColors.isDarkMode
                    ? MdiIcons.school
                    : MdiIcons.schoolOutline,
                text: CustomValues.lang.selectClass,
              ),
              ampBigAmpButton(
                onTap: () => showAboutDialog(
                    context: context,
                    applicationName: AmpStrings.appTitle,
                    applicationVersion: AmpStrings.version,
                    applicationIcon:
                        Image.asset('assets/images/logo.png', height: 40),
                    children: [Text(CustomValues.lang.appInfo)]),
                icon: AmpColors.isDarkMode
                    ? MdiIcons.folderInformation
                    : MdiIcons.folderInformationOutline,
                text: CustomValues.lang.settingsAppInfo,
              ),
              ampBigAmpButton(
                onTap: () {
                  if (Prefs.devOptionsEnabled)
                    Animations.changeScreenEaseOutBackReplace(
                        DevOptionsScreen(), context);
                },
                icon: MdiIcons.codeBrackets,
                text: 'Entwickleroptionen',
                visible: Prefs.devOptionsEnabled,
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
          floatingActionButton: ampNull,
          bottomNavigationBar: SizedBox(
            height: 55,
            child: TabBar(
              controller: tabController,
              indicatorColor: AmpColors.colorForeground,
              labelColor: AmpColors.colorForeground,
              tabs: <Widget>[
                ampTab(Icons.home, CustomValues.lang.start),
                ampTab(MdiIcons.timetable, CustomValues.lang.timetable),
                ampTab(Icons.settings, CustomValues.lang.settings),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomSheet: ampNull,
        )
      ],
    ));
  }
}
