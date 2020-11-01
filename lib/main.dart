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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pedantic/pedantic.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:update/update.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(SplashScreen());
}

class SplashScreen extends StatelessWidget {
  SplashScreen({
    bool test = false,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers)
        httpPost,
    Future<String> Function(Uri url) httpGet,
  }) {
    httpPost ??= http.post;
    httpGet ??= http.get;
    testing = test;
    httpPostFunc = httpPost;
    httpGetFunc = httpGet;
  }

  @override
  Widget build(BuildContext context) => ampMatApp(SplashScreenPage());
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

      // if the program wont start within 15 secs, show some debug info
      final timeout = Timer(
        Duration(seconds: 15),
        () => ampChangeScreen(Timeout(), context),
      );

      final minimalLoadingTime = Future.delayed(Duration(milliseconds: 450));

      ampInfo('Splash', 'Loading SharedPreferences...');
      await Prefs.load();
      ampInfo('Splash', 'SharedPreferences (hopefully successfully) loaded.');
      ttColumns = ttLoadFromPrefs();

      if (Prefs.currentThemeId < 0) Prefs.currentThemeId = 0;

      if (Prefs.useSystemTheme)
        AmpColors.brightness =
            SchedulerBinding.instance.window.platformBrightness;

      if (!Prefs.firstLogin) await dsbUpdateWidget();

      await minimalLoadingTime;

      timeout.cancel();
      ampChangeScreen(
        Prefs.firstLogin ? FirstLoginScreen() : AmpApp(),
        context,
      );
    } catch (e) {
      ampErr('Splash.initState', errorString(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('Splash', 'Buiding Splash Screen');
      return Scaffold(
        body: Center(
          child: AnimatedContainer(
            color: Colors.black,
            height: double.infinity,
            width: double.infinity,
            duration: Duration(seconds: 1),
            child: FlareActor(
              'assets/splash_screen.json',
              alignment: Alignment.center,
              fit: BoxFit.contain,
              animation: 'anim',
            ),
          ),
        ),
        bottomSheet: ampLinearProgressIndicator(),
      );
    } catch (e) {
      ampErr('Splash.build', errorString(e));
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
      return ampMatApp(AmpHomePage(initialIndex));
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

var checkForUpdates = true;

class AmpHomePageState extends State<AmpHomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  void checkBrightness() {
    if (Prefs.useSystemTheme) {
      AmpColors.brightness =
          SchedulerBinding.instance.window.platformBrightness;
      rebuildDragDown();
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
    Prefs.timerInit(() => dsbUpdateWidget(callback: rebuild));
    (() async {
      if (!checkForUpdates || !Prefs.updatePopup) return;
      checkForUpdates = false;
      final update = await UpdateInfo.getFromGitHub(
        'Ampless/Amplessimus',
        AmpStrings.version,
        uncachedHttpGetFunc,
      );
      if (update != null)
        await ampDialog(
          title: Language.current.update,
          children: (_, __) => [ampText(Language.current.plsUpdate)],
          actions: (alCtx) => [
            ampDialogButton(Language.current.dismiss, Navigator.of(alCtx).pop),
            ampDialogButton(Language.current.open, () => launch(update.url)),
          ],
          context: context,
          widgetBuilder: ampRow,
        );
    })();
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

  Future<Null> selectClassDialog(BuildContext context) {
    var letter = Prefs.char;
    var grade = Prefs.grade;
    if (letter.isEmpty || !dsbLetters.contains(letter)) letter = dsbLetters[0];
    if (grade.isEmpty || !dsbGrades.contains(grade)) grade = dsbGrades[0];
    return ampDialog(
      context: context,
      title: Language.current.selectClass,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: grade,
          items: dsbGrades,
          onChanged: (value) => setAlState(() {
            grade = value;
            try {
              if (int.parse(value) > 10) letter = '';
              // ignore: empty_catches
            } catch (e) {}
          }),
        ),
        ampPadding(10),
        ampDropdownButton(
          value: letter,
          items: dsbLetters,
          onChanged: (value) => setAlState(() => letter = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.grade = grade;
          Prefs.char = letter;
          unawaited(rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampRow,
    );
  }

  Future<Null> changeLanguageDialog(BuildContext context) {
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
        context,
        save: () async {
          Language.current = lang;
          Prefs.dsbUseLanguage = use;
          unawaited(rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Future<Null> credentialDialog(BuildContext context) {
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
        context,
        save: () async {
          Prefs.username = usernameInputFormController.text.trim();
          Prefs.password = passwordInputFormController.text.trim();
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
            children: [
              ampListTile(
                Language.current.allClasses,
                trailing: '${Prefs.grade}${Prefs.char}',
              ),
              Align(
                child: ampSwitch(
                  Prefs.oneClassOnly,
                  (value) {
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
      final containers = [
        RefreshIndicator(
          key: refreshKey,
          child: Scaffold(
            key: homeScaffoldKey,
            appBar: ampAppBar(AmpStrings.appTitle),
            backgroundColor: Colors.transparent,
            body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                dsbWidget,
                ampDivider,
                changeSubVisibilityWidget,
              ],
            ),
          ),
          onRefresh: rebuildDragDown,
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
                        ampChangeScreen(RegisterTimetableScreen(), context);
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
                  onPressed: () => ampChangeScreen(
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
              children: [
                ampBigButton(
                  onTap: () {
                    Prefs.toggleDarkModePressed();
                    Prefs.useSystemTheme = false;
                    AmpColors.switchMode();
                    dsbUpdateWidget();
                    Future.delayed(
                      Duration(microseconds: testing ? 1 : 150000),
                      rebuild,
                    );
                  },
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.lightbulbOn
                      : MdiIcons.lightbulbOnOutline,
                  text: AmpColors.isDarkMode
                      ? Language.current.lightsOn
                      : Language.current.lightsOff,
                ),
                ampBigButton(
                  onTap: () async {
                    ampInfo('AmpApp', 'switching design mode');
                    Prefs.currentThemeId = (Prefs.currentThemeId + 1) % 2;
                    await dsbUpdateWidget();
                    rebuild();
                    settingsScaffoldKey.currentState?.showSnackBar(ampSnackBar(
                      Language.current.changedAppearance,
                      Language.current.show,
                      () => setState(() => tabController.index = 0),
                    ));
                  },
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.clipboardList
                      : MdiIcons.clipboardListOutline,
                  text: Language.current.changeAppearance,
                ),
                ampBigButton(
                  onTap: () async {
                    Prefs.useSystemTheme = !Prefs.useSystemTheme;
                    checkBrightness();
                  },
                  icon: MdiIcons.brightness6,
                  text: Prefs.useSystemTheme
                      ? Language.current.lightsNoSystem
                      : Language.current.lightsUseSystem,
                ),
                ampBigButton(
                  onTap: () => changeLanguageDialog(context),
                  icon: MdiIcons.translate,
                  text: Language.current.changeLanguage,
                ),
                ampBigButton(
                  onTap: () => credentialDialog(context),
                  icon:
                      AmpColors.isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
                  text: Language.current.changeLogin,
                ),
                ampBigButton(
                  onTap: () => selectClassDialog(context),
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.school
                      : MdiIcons.schoolOutline,
                  text: Language.current.selectClass,
                ),
                ampBigButton(
                  onTap: () => showAboutDialog(
                      context: context,
                      applicationName: AmpStrings.appTitle,
                      applicationVersion: AmpStrings.version,
                      applicationIcon:
                          SvgPicture.asset('assets/logo.svg', height: 40),
                      children: [Text(Language.current.appInfo)]),
                  icon: AmpColors.isDarkMode
                      ? MdiIcons.folderInformation
                      : MdiIcons.folderInformationOutline,
                  text: Language.current.settingsAppInfo,
                ),
                ampBigButton(
                  onTap: () {
                    if (Prefs.devOptionsEnabled)
                      ampChangeScreen(DevOptionsScreen(), context);
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
      return ampPageBase(Scaffold(
        backgroundColor: Colors.transparent,
        body: TabBarView(
          controller: tabController,
          physics: ClampingScrollPhysics(),
          children: containers,
        ),
        bottomNavigationBar: ampTabBar(tabController, [
          ampTab(Icons.home, Language.current.start),
          ampTab(MdiIcons.timetable, Language.current.timetable),
          ampTab(Icons.settings, Language.current.settings),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ));
    } catch (e) {
      ampErr('AmpHomePageState', errorString(e));
      return ampText(errorString(e));
    }
  }
}
