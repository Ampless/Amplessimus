import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:update/update.dart';
import '../appinfo.dart';
import '../dsbapi.dart';
import '../logging.dart';
import '../prefs.dart' as Prefs;
import '../uilib.dart';
import '../wpemails.dart';
import '../langs/language.dart';
import 'first_login.dart';
import 'settings.dart';

class AmpHomePage extends StatefulWidget {
  AmpHomePage(this.initialIndex, {Key key}) : super(key: key);
  final int initialIndex;
  @override
  AmpHomePageState createState() => AmpHomePageState();
}

ScaffoldMessengerState scaffoldMessanger;
final refreshKey = GlobalKey<RefreshIndicatorState>();

var checkForUpdates = true;

class AmpHomePageState extends State<AmpHomePage>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  void checkBrightness() {
    if (!Prefs.useSystemTheme) return;
    Prefs.brightness = SchedulerBinding.instance.window.platformBrightness;
    Future.delayed(Duration(milliseconds: 150), rebuild);
  }

  @override
  void initState() {
    ampInfo('AmpHomePageState', 'initState()');
    checkBrightness();
    SchedulerBinding.instance.window.onPlatformBrightnessChanged =
        checkBrightness;
    super.initState();
    tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
    Prefs.timerInit(() => dsbUpdateWidget(callback: rebuild));
    (() async {
      if (!checkForUpdates || !Prefs.updatePopup) return;
      ampInfo('UN', 'Searching for updates...');
      checkForUpdates = false;
      final update = await UpdateInfo.getFromGitHub(
        'Ampless/Amplessimus',
        appVersion,
        http.get,
      );
      if (update != null) {
        ampInfo('UN', 'Found an update, displaying the dialog.');
        await ampDialog(
          title: Language.current.update,
          children: (_, __) => [ampText(Language.current.plsUpdate)],
          actions: (alCtx) => [
            ampDialogButton(Language.current.dismiss, Navigator.of(alCtx).pop),
            ampDialogButton(
                Language.current.open, () => ampOpenUrl(update.url)),
          ],
          context: context,
          widgetBuilder: ampRow,
        );
      }
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
    final dsb = dsbUpdateWidget();
    await wpemailUpdate();
    await dsb;
    rebuild();
  }

  int lastUpdate = 0;
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('AmpHomePageState', 'Building HomePage...');
      scaffoldMessanger = ScaffoldMessenger.of(context);
      if (lastUpdate <
          DateTime.now()
              .subtract(Duration(minutes: Prefs.timer))
              .millisecondsSinceEpoch) {
        refreshKey.currentState?.show();
        dsbUpdateWidget(callback: rebuild);
        lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
      final containers = [
        //ptr doesnt seem to always work everywhere (might have to consider Expanded)
        RefreshIndicator(
          key: refreshKey,
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: [
              ampAppBar(appTitle),
              dsbWidget,
              wpemailsave.isNotEmpty ? ampSizedDivider(20) : ampNull,
              wpemailsave.isNotEmpty ? wpemailWidget() : ampNull,
            ],
          ),
          onRefresh: rebuildDragDown,
        ),
        Settings(this),
      ];
      return ampPageBase(Scaffold(
        backgroundColor: Colors.transparent,
        body: TabBarView(
          controller: tabController,
          physics: ClampingScrollPhysics(),
          children: containers,
        ),
        bottomNavigationBar: ampTabBar(tabController, [
          ampTab(Icons.home, Icons.home_outlined, Language.current.start),
          ampTab(Icons.settings, Icons.settings_outlined,
              Language.current.settings),
        ]),
      ));
    } catch (e) {
      ampErr('AmpHomePageState', errorString(e));
      return ampText(errorString(e));
    }
  }
}
