import 'dart:async';

import 'colors.dart' as AmpColors;
import 'dsbapi.dart';
import 'ui/first_login.dart';
import 'langs/language.dart';
import 'logging.dart';
import 'prefs.dart' as Prefs;
import 'ui/settings.dart';
import 'ui/splash_screen.dart';
import 'uilib.dart';
import 'appinfo.dart';
import 'wpemails.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:pedantic/pedantic.dart';
import 'package:update/update.dart';

void main() {
  runApp(SplashScreen());
}

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
    AmpColors.brightness = SchedulerBinding.instance.window.platformBrightness;
    Future.delayed(Duration(milliseconds: 150), rebuild);
  }

  @override
  void initState() {
    ampInfo('AmpHomePageState', 'initState()');
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
        uncachedHttp.get,
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
    if (Prefs.wpeDomain.isNotEmpty)
      wpemailsave = await wpemails(Prefs.wpeDomain);
    await dsb;
    rebuild();
  }

  Future<Null> wpemailDomainPopup() {
    final domainFormField = AmpFormField(Prefs.wpeDomain);
    return ampDialog(
      context: context,
      title: Language.current.wpemailDomain,
      children: (context, setAlState) => [
        ampPadding(2),
        domainFormField.formField(
          labelText: Language.current.wpemailDomain,
          keyboardType: TextInputType.url,
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.wpeDomain = domainFormField.text.trim();
          unawaited(rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Widget get changeSubVisibilityWidget => Stack(
        children: [
          ampListTile(
            null,
            leading: Language.current.allClasses,
            trailing: '${Prefs.grade}${Prefs.char}',
          ),
          Center(
            child: ampSwitch(
              Prefs.oneClassOnly,
              (value) {
                Prefs.oneClassOnly = value;
                dsbUpdateWidget(callback: rebuild, useJsonCache: true);
              },
            ),
          ),
        ],
      );

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
          child: Scaffold(
            appBar: ampAppBar(appTitle),
            backgroundColor: Colors.transparent,
            body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                dsbWidget,
                ampDivider,
                changeSubVisibilityWidget,
                wpemailsave == null || wpemailsave.isEmpty
                    ? ampRaisedButton(Language.current.addWpeDomain,
                        () => wpemailDomainPopup())
                    : wpemailWidget(wpemailsave),
              ],
            ),
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
          ampTab(Icons.home_outlined, Language.current.start),
          ampTab(Icons.settings_outlined, Language.current.settings),
        ]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ));
    } catch (e) {
      ampErr('AmpHomePageState', errorString(e));
      return ampText(errorString(e));
    }
  }
}
