import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pedantic/pedantic.dart';
import 'package:update/update.dart';
import '../appinfo.dart';
import '../dsbapi.dart' as dsb;
import '../logging.dart';
import '../prefs.dart' as prefs;
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
    if (!prefs.useSystemTheme) return;
    prefs.brightness = SchedulerBinding.instance.window.platformBrightness;
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
    prefs.timerInit(() => rebuildDragDown());
    (() async {
      if (!checkForUpdates || !prefs.updatePopup) return;
      ampInfo('UN', 'Searching for updates...');
      checkForUpdates = false;
      final update = await UpdateInfo.getFromGitHub(
        'Ampless/Amplessimus',
        await appVersion,
        http.get,
      );
      if (update != null) {
        ampInfo('UN', 'Found an update, displaying the dialog.');
        final old = await appVersion;
        await ampDialog(
          context,
          title: Language.current.update,
          children: (_, __) =>
              [ampText(Language.current.plsUpdate(old, update.version))],
          actions: (alCtx) => [
            ampDialogButton(Language.current.dismiss, Navigator.of(alCtx).pop),
            ampDialogButton(
                Language.current.open, () => ampOpenUrl(update.url)),
          ],
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
    final d = dsb.updateWidget();
    await wpemailUpdate();
    await d;
    rebuild();
  }

  int _lastUpdate = 0;
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('AmpHomePageState', 'Building HomePage...');
      scaffoldMessanger = ScaffoldMessenger.of(context);
      if (_lastUpdate <
          DateTime.now()
              .subtract(Duration(minutes: prefs.timer))
              .millisecondsSinceEpoch) {
        rebuildDragDown();
        _lastUpdate = DateTime.now().millisecondsSinceEpoch;
      }
      final tabs = [
        RefreshIndicator(
          key: refreshKey,
          child: ListView(
            children: [
              ampTitle(appTitle),
              dsb.widget,
              wpemailsave.isNotEmpty ? Divider(height: 20) : ampNull,
              wpemailsave.isNotEmpty ? wpemailWidget() : ampNull,
            ],
          ),
          onRefresh: rebuildDragDown,
        ),
        Settings(this),
      ];
      return SafeArea(
          child: Scaffold(
        body: TabBarView(
          controller: tabController,
          physics: ClampingScrollPhysics(),
          children: tabs,
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
