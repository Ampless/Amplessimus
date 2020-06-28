import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/uilib.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../animations.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: MaterialApp(
          builder: (context, child) =>
              ScrollConfiguration(behavior: MyBehavior(), child: child),
          title: AmpStrings.appTitle,
          theme: ThemeData(
            canvasColor: AmpColors.materialColorBackground,
            primarySwatch: AmpColors.materialColorForeground,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: DevOptionsScreenPage(
              title: AmpStrings.appTitle,
          ),
        ),
        onWillPop: () async {
          dsbUpdateWidget(() {});
          Animations.changeScreenEaseOutBackReplace(MyApp(initialIndex: 2), context);
          return false;
        });
  }
}

class DevOptionsScreenPage extends StatefulWidget {
  DevOptionsScreenPage({this.title});
  final String title;
  @override
  State<StatefulWidget> createState() => DevOptionsScreenPageState();
}

class DevOptionsScreenPageState extends State<DevOptionsScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    DevOptionsValues.tabController =
        TabController(length: 2, vsync: this, initialIndex: 1);
    DevOptionsValues.tabController.animation.addListener(() {
      if (DevOptionsValues.tabController.index < 1) {
        Animations.changeScreenNoAnimationReplace(
          MyApp(
            initialIndex: 2,
          ),
          context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: DevOptionsValues.tabController, children: [
      MyApp(initialIndex: 2),
      Scaffold(
        backgroundColor: AmpColors.colorBackground,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Entwickleroptionen',
              style: TextStyle(fontSize: 20, color: AmpColors.colorForeground)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          color: AmpColors.colorBackground,
          margin: EdgeInsets.all(16),
          child: Center(
            child: ListView(
              children: [
                Divider(
                    color: AmpColors.colorForeground,
                    height: Prefs.subListItemSpace.toDouble() + 2),
                ampSwitchWithText(
                  text: 'Entwickleroptionen aktiviert',
                  value: Prefs.devOptionsEnabled,
                  onChanged: (value) => setState(() => Prefs.devOptionsEnabled = value),
                ),
                Divider(
                  color: AmpColors.colorForeground,
                  height: Prefs.subListItemSpace.toDouble(),
                ),
                ampSwitchWithText(
                  text: 'Hilfe für Langeweile aktiviert',
                  value: Prefs.counterEnabled,
                  onChanged: (value) => setState(() => Prefs.counterEnabled = value),
                ),
                ampSwitchWithText(
                  text: 'App schließt bei zurück-Taste',
                  value: Prefs.closeAppOnBackPress,
                  onChanged: (value) => setState(() => Prefs.closeAppOnBackPress = value),
                ),
                ampSwitchWithText(
                  text: 'Dauerhafter Ladebalken',
                  value: Prefs.loadingBarEnabled,
                  onChanged: (value) => setState(() => Prefs.loadingBarEnabled = value),
                ),
                ampSwitchWithText(
                  text: 'JSON Cache benutzen',
                  value: Prefs.useJsonCache,
                  onChanged: (value) {
                    Prefs.useJsonCache = value;
                    dsbUpdateWidget(() => setState(() {}),
                        cacheJsonPlans: value);
                  },
                ),
                Divider(
                    color: AmpColors.colorForeground,
                    height: Prefs.subListItemSpace.toDouble()),
                ListTile(
                  title: Text('Listenelementabstand', style: AmpColors.textStyleForeground),
                  trailing: Text('${Prefs.subListItemSpace}',
                      style: AmpColors.textStyleForeground),
                  onTap: () => showInputSubListItemSpacingDialog(context),
                ),
                Divider(
                    color: AmpColors.colorForeground,
                    height: Prefs.subListItemSpace.toDouble()),
                Divider(color: Colors.transparent, height: 10),
                RaisedButton(
                    child: Text('Print Cache'), onPressed: Prefs.listCache),
                RaisedButton(
                  child: Text('Cache leeren'),
                  onPressed: () => Prefs.clearCache(),
                ),
                RaisedButton(
                    child: Text('JSON importieren'),
                    onPressed: () async {
                      Prefs.dsbJsonCache = '['
                          '{"title":"Montag","date":"15.6.2020 Montag","subs": []},'
                          '{"title":"Dienstag","date":"16.6.2020 Dienstag","subs": ['
                          '{"class":"5cd","lessons":[3],"teacher":"Häußler","subject":"Spo","notes": "Mitbetreuung"},'
                          '{"class":"7b","lessons": [5],"teacher":"Rosemann","subject":"E","notes":""},'
                          '{"class":"7b","lessons": [6],"teacher":"---","subject":"E","notes":""},'
                          '{"class":"11q","lessons": [1],"teacher":"Wolf","subject":"1sk1","notes":""}'
                          ']}'
                          ']';
                      dsbUpdateWidget(() => setState(() {}),
                          cacheJsonPlans: Prefs.useJsonCache);
                    }),
                RaisedButton.icon(
                  color: Colors.red,
                  icon: Icon(Icons.delete, color: AmpColors.colorForeground),
                  label: Text('App-Daten löschen',
                      style: TextStyle(color: AmpColors.colorForeground)),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('App-Daten löschen',
                                style: AmpColors.textStyleForeground),
                            content: Text('Löschen der App-Daten bestätigen?',
                                style: AmpColors.textStyleForeground),
                            backgroundColor: AmpColors.colorBackground,
                            actions: <Widget>[
                              ampDialogButton(
                                text: 'Abbrechen',
                                onPressed: Navigator.of(context).pop,
                              ),
                              ampDialogButton(
                                text: 'Bestätigen',
                                onPressed: () {
                                  Prefs.clear();
                                  SystemNavigator.pop();
                                },
                              ),
                            ],
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: AmpColors.colorBackground,
          splashColor: AmpColors.colorForeground,
          onPressed: () {
            dsbUpdateWidget(() {});
            Animations.changeScreenEaseOutBackReplace(MyApp(initialIndex: 2), context);
          },
          label: Text(
            'zurück',
            style: TextStyle(color: AmpColors.colorForeground),
          ),
          icon: Icon(
            Icons.arrow_back,
            color: AmpColors.colorForeground,
          ),
        ),
      )
    ]);
  }

  void showInputSubListItemSpacingDialog(BuildContext context) {
    final subListSpacingInputFormKey = GlobalKey<FormFieldState>();
    final subListSpacingInputFormController =
        TextEditingController(text: Prefs.subListItemSpace.toString());
    ampTextDialog(
      context: context,
      title: 'Listenelementabstand',
      children: (context) => [
        ampFormField(
          controller: subListSpacingInputFormController,
          key: subListSpacingInputFormKey,
          keyboardType: TextInputType.number,
          validator: Widgets.numberValidator,
        ),
      ],
      actions: (context) => [
        ampDialogButton(
          text: 'Abbrechen',
          onPressed: () => Navigator.of(context).pop(),
        ),
        ampDialogButton(
          text: 'Speichern',
          onPressed: () {
            String err =
                Widgets.numberValidator(subListSpacingInputFormController.text);
            if (err != null) {
              ampErr(ctx: 'DEVOPTIONS', message: errorString(err));
              return;
            }
            Prefs.subListItemSpace =
                int.tryParse(subListSpacingInputFormController.text.trim());
            setState(() => Prefs.subListItemSpace);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class DevOptionsValues {
  static TabController tabController;
}
