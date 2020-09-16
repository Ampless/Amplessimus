import 'dart:async';
import 'dart:ui';

import 'package:Amplessimus/screens/dev_options.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/screens/register_timetable.dart';
import 'package:Amplessimus/screens/timeout.dart';
import 'package:Amplessimus/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:dsbuntis/dsbuntis.dart';
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
  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      // if the program wont start within 30 secs, show some debug info
      final timeout = Timer(
        Duration(seconds: 30),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => Timeout()),
        ),
      );

      ampInfo('SplashScreen', 'Loading SharedPreferences...');
      await Prefs.load();
      Prefs.devOptionsEnabled = Prefs.devOptionsEnabled;
      ampInfo('SplashScreen', 'SharedPreferences successfully loaded.');
      ttColumns = ttLoadFromPrefs();

      if (Prefs.currentThemeId < 0) Prefs.currentThemeId = 0;

      if (Prefs.useSystemTheme)
        AmpColors.brightness =
            SchedulerBinding.instance.window.platformBrightness;

      if (!Prefs.firstLogin) await dsbUpdateWidget();

      Future.delayed(Duration(seconds: 1), () {
        timeout.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => Prefs.firstLogin ? FirstLoginScreen() : AmpApp(),
          ),
        );
      });
    } catch (e) {
      ampErr('SplashScreenPageState.initState', errorString(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('SplashScreen', 'Buiding Splash Screen');
      return Scaffold(
        body: Center(
          child: AnimatedContainer(
            color: Colors.black,
            height: double.infinity,
            width: double.infinity,
            duration: Duration(seconds: 1),
            child: FlareActor(
              'assets/anims/splash_screen.json',
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: 'anim',
            ),
          ),
        ),
        bottomSheet: ampLinearProgressIndicator(),
      );
    } catch (e) {
      ampErr('SplashScreenPageState', errorString(e));
      return ampText(errorString(e));
    }
  }
}

class AmpApp extends StatelessWidget {
  AmpApp([this.initialIndex = 0]);
  final int initialIndex;
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('AmpApp', 'Building Main Page');
      return ampMatApp(
        AmpHomePage(initialIndex),
        pop: () async => Prefs.closeAppOnBackPress,
      );
    } catch (e) {
      ampErr('AmpApp', errorString(e));
      return ampText(errorString(e));
    }
  }
}

class AmpHomePage extends StatefulWidget {
  AmpHomePage(this.initialIndex, {Key key}) : super(key: key);
  final int initialIndex;
  @override
  AmpHomePageState createState() => AmpHomePageState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final settingsScaffoldKey = GlobalKey<ScaffoldState>();
final refreshKey = GlobalKey<RefreshIndicatorState>();

class AmpHomePageState extends State<AmpHomePage>
    with SingleTickerProviderStateMixin {
  bool circularProgressIndicatorActive = false;
  TabController tabController;

  void checkBrightness() {
    if (Prefs.useSystemTheme) {
      AmpColors.brightness =
          SchedulerBinding.instance.window.platformBrightness;
      rebuildNewBuild();
      Future.delayed(Duration(milliseconds: 150), rebuild);
    }
  }

  @override
  void initState() {
    ampInfo('AmpHomePageState', 'initState()');
    SchedulerBinding.instance.window.onPlatformBrightnessChanged =
        checkBrightness;
    super.initState();
    tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialIndex);
    Prefs.setTimer(Prefs.timer, () => dsbUpdateWidget(callback: rebuild));
  }

  void rebuild() {
    try {
      setState(() {});
      ampInfo('AmpApp', 'rebuilt!');
    } catch (e) {
      ampInfo('AmpHomePageState.rebuild', errorString(e));
    }
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

  Future<Null> showInputSelectCurrentClass(BuildContext context) {
    var letterDropDownValue = Prefs.char.trim().toLowerCase();
    var gradeDropDownValue = Prefs.grade.trim().toLowerCase();
    if (letterDropDownValue.isEmpty ||
        !FirstLoginValues.letters.contains(letterDropDownValue))
      letterDropDownValue = FirstLoginValues.letters[0];
    if (gradeDropDownValue.isEmpty ||
        !FirstLoginValues.grades.contains(gradeDropDownValue))
      gradeDropDownValue = FirstLoginValues.grades[0];
    return ampDialog(
      context: context,
      title: Language.current.selectClass,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: gradeDropDownValue,
          items: FirstLoginValues.grades,
          onChanged: (value) => setAlState(() => gradeDropDownValue = value),
        ),
        ampPadding(10),
        ampDropdownButton(
          value: letterDropDownValue,
          items: FirstLoginValues.letters,
          onChanged: (value) => setAlState(() => letterDropDownValue = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context: context,
        save: () async {
          Prefs.grade = gradeDropDownValue;
          Prefs.char = letterDropDownValue;
          await Prefs.waitForMutex();
          unawaited(rebuildNewBuild());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampRow,
    );
  }

  Future<Null> showInputChangeLanguage(BuildContext context) {
    var lang = Language.current;
    var use = Prefs.dsbUseLanguage;
    return ampDialog(
      context: context,
      title: Language.current.changeLanguage,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: lang,
          itemToDropdownChild: (i) => ampText(i.name),
          items: Language.all,
          onChanged: (value) => setAlState(() => lang = value),
        ),
        ampSizedDivider(5),
        ampSwitchWithText(
          text: Language.current.useForDsb,
          value: use,
          onChanged: (value) => setAlState(() => use = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context: context,
        save: () async {
          Language.current = lang;
          Prefs.dsbUseLanguage = use;
          await Prefs.waitForMutex();
          unawaited(rebuildNewBuild());

          FirstLoginValues.grades[0] = Language.current.empty;
          FirstLoginValues.letters[0] = Language.current.empty;
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Future<Null> showInputEntryCredentials(BuildContext context) {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController =
        TextEditingController(text: Prefs.username);
    final passwordInputFormController =
        TextEditingController(text: Prefs.password);
    var passwordHidden = true;
    return ampDialog(
      context: context,
      title: Language.current.changeLoginPopup,
      children: (context, setAlState) => [
        ampPadding(2),
        ampFormField(
          controller: usernameInputFormController,
          key: usernameInputFormKey,
          labelText: Language.current.username,
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
          labelText: Language.current.password,
          keyboardType: TextInputType.visiblePassword,
          obscureText: passwordHidden,
          autofillHints: [AutofillHints.password],
        )
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context: context,
        save: () async {
          Prefs.username = usernameInputFormController.text.trim();
          Prefs.password = passwordInputFormController.text.trim();
          await Prefs.waitForMutex();
          unawaited(rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Widget get changeSubVisibilityWidget {
    return Prefs.grade.isEmpty && Prefs.char.isEmpty
        ? ampNull
        : Stack(
            children: <Widget>[
              ListTile(
                title: ampText(Language.current.allClasses),
                trailing: ampText('${Prefs.grade}${Prefs.char}'),
              ),
              Align(
                child: ampSwitch(
                  value: Prefs.oneClassOnly,
                  onChanged: (value) {
                    Prefs.oneClassOnly = value;
                    dsbUpdateWidget(callback: rebuild);
                  },
                ),
                alignment: Alignment.center,
              ),
            ],
          );
  }

  int lastUpdate = 0;
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('MyHomePage', 'Building MyHomePage...');
      if (dsbWidget == null) {
        dsbUpdateWidget();
        lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
      if (lastUpdate <
          DateTime.now()
              .subtract(Duration(minutes: Prefs.timer))
              .millisecondsSinceEpoch) {
        dsbUpdateWidget();
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
              onRefresh: rebuildDragDown,
            ),
          ),
          margin: EdgeInsets.only(left: 8, right: 8, bottom: 2),
        ),
        Scaffold(
          appBar: ampAppBar(Language.current.timetable),
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
                        ampEaseOutBackReplacement(
                          RegisterTimetableScreen(),
                          context,
                        );
                      },
                      child: ampColumn(
                        [
                          ampIcon(MdiIcons.timetable, size: 200),
                          ampText(
                            Language.current.setupTimetable,
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
                        children: ttWidgets(
                          dsbPlans,
                          ttColumns,
                          Prefs.filterTimetables,
                        ),
                      ),
                      ampDivider,
                      ampSwitchWithText(
                        text: Language.current.filterTimetables,
                        value: Prefs.filterTimetables,
                        onChanged: (value) =>
                            setState(() => Prefs.filterTimetables = value),
                      ),
                      ampPadding(24),
                    ],
                  ),
          ),
          floatingActionButton: Prefs.jsonTimetable == null
              ? ampNull
              : ampFab(
                  onPressed: () => ampEaseOutBackReplacement(
                    RegisterTimetableScreen(),
                    context,
                  ),
                  label: Language.current.edit,
                  icon: Icons.edit,
                ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 150),
          color: Colors.transparent,
          child: Scaffold(
            appBar: ampAppBar(Language.current.settings),
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
                    Prefs.useSystemTheme = false;
                    dsbUpdateWidget();
                    Future.delayed(
                        Duration(
                          microseconds: FirstLoginValues.testing ? 1 : 150000,
                        ),
                        rebuild);
                  },
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.lightbulbOn
                      : MdiIcons.lightbulbOnOutline,
                  text: AmpColors.isDarkMode
                      ? Language.current.lightsOn
                      : Language.current.lightsOff,
                ),
                ampBigAmpButton(
                  onTap: () async {
                    ampInfo('MyApp', 'switching design mode');
                    Prefs.currentThemeId = (Prefs.currentThemeId + 1) % 2;
                    await dsbUpdateWidget();
                    rebuild();
                    settingsScaffoldKey.currentState?.showSnackBar(ampSnackBar(
                      Language.current.changedAppearance,
                      ampSnackBarAction(
                        Language.current.show,
                        () => setState(() => tabController.index = 0),
                      ),
                    ));
                  },
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.clipboardList
                      : MdiIcons.clipboardListOutline,
                  text: Language.current.changeAppearance,
                ),
                ampBigAmpButton(
                  onTap: () async {
                    Prefs.useSystemTheme = !Prefs.useSystemTheme;
                    await Prefs.waitForMutex();
                    checkBrightness();
                  },
                  icon: MdiIcons.brightness6,
                  text: Prefs.useSystemTheme
                      ? Language.current.lightsNoSystem
                      : Language.current.lightsUseSystem,
                ),
                ampBigAmpButton(
                  onTap: () => showInputChangeLanguage(context),
                  icon: MdiIcons.translate,
                  text: Language.current.changeLanguage,
                ),
                ampBigAmpButton(
                  onTap: () => showInputEntryCredentials(context),
                  icon:
                      AmpColors.isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
                  text: Language.current.changeLogin,
                ),
                ampBigAmpButton(
                  onTap: () => showInputSelectCurrentClass(context),
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.school
                      : MdiIcons.schoolOutline,
                  text: Language.current.selectClass,
                ),
                ampBigAmpButton(
                  onTap: () => showAboutDialog(
                      context: context,
                      applicationName: AmpStrings.appTitle,
                      applicationVersion: AmpStrings.version,
                      applicationIcon:
                          Image.asset('assets/images/logo.png', height: 40),
                      children: [Text(Language.current.appInfo)]),
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.folderInformation
                      : MdiIcons.folderInformationOutline,
                  text: Language.current.settingsAppInfo,
                ),
                ampBigAmpButton(
                  onTap: () {
                    if (Prefs.devOptionsEnabled)
                      ampEaseOutBackReplacement(
                        DevOptionsScreen(),
                        context,
                      );
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
        children: [
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
            bottomNavigationBar: SizedBox(
              height: 55,
              child: TabBar(
                controller: tabController,
                indicatorColor: AmpColors.colorForeground,
                labelColor: AmpColors.colorForeground,
                tabs: [
                  ampTab(Icons.home, Language.current.start),
                  ampTab(MdiIcons.timetable, Language.current.timetable),
                  ampTab(Icons.settings, Language.current.settings),
                ],
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
          )
        ],
      ));
    } catch (e) {
      ampErr('AmpHomePageState', errorString(e));
      return ampText(errorString(e));
    }
  }
}
