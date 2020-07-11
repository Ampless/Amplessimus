import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/uilib.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../animations.dart';

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
          await dsbUpdateWidget();
          Animations.changeScreenEaseOutBackReplace(
              MyApp(initialIndex: 2), context);
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
          title: ampText('Entwickleroptionen', size: 20),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          color: AmpColors.colorBackground,
          margin: EdgeInsets.all(16),
          child: Center(
            child: ListView(
              children: [
                ampDivider,
                ampSwitchWithText(
                  text: 'Entwickleroptionen aktiviert',
                  value: Prefs.devOptionsEnabled,
                  onChanged: (value) =>
                      setState(() => Prefs.devOptionsEnabled = value),
                ),
                ampDivider,
                ampSwitchWithText(
                  text: 'Hilfe für Langeweile aktiviert',
                  value: Prefs.counterEnabled,
                  onChanged: (value) =>
                      setState(() => Prefs.counterEnabled = value),
                ),
                ampSwitchWithText(
                  text: 'App schließt bei zurück-Taste',
                  value: Prefs.closeAppOnBackPress,
                  onChanged: (value) =>
                      setState(() => Prefs.closeAppOnBackPress = value),
                ),
                ampSwitchWithText(
                  text: 'Dauerhafter Ladebalken',
                  value: Prefs.loadingBarEnabled,
                  onChanged: (value) =>
                      setState(() => Prefs.loadingBarEnabled = value),
                ),
                ampSwitchWithText(
                  text: 'JSON Cache benutzen',
                  value: Prefs.useJsonCache,
                  onChanged: (value) {
                    Prefs.useJsonCache = value;
                    dsbUpdateWidget(
                        callback: () => setState(() {}), cacheJsonPlans: value);
                  },
                ),
                ampDivider,
                ListTile(
                  title: ampText('Listenelementabstand'),
                  trailing: ampText('${Prefs.subListItemSpace}'),
                  onTap: () => showInputSubListItemSpacingDialog(context),
                ),
                ListTile(
                  title: ampText('Refreshtimer (in Minuten)'),
                  trailing: ampText('${Prefs.timer}'),
                  onTap: () => showInputTimerDialog(context),
                ),
                ampDivider,
                Divider(color: Colors.transparent, height: 10),
                ampRaisedButton(
                  text: 'Print Cache',
                  onPressed: Prefs.listCache,
                ),
                ampRaisedButton(
                  text: 'Clear Cache',
                  onPressed: Prefs.clearCache,
                ),
                ampRaisedButton(
                  text: 'Set Cache to Kekw',
                  onPressed: () => Prefs.dsbJsonCache = '[{\"day\":4,\"date\":\"3.7.2020 Freitag\",\"subs\":['
                      '{\"affectedClass\":\"5c\",\"hours\":[3],\"teacher\":\"Häußler\",\"subject\":\"D\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"9b\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Bio\",\"notes\":\"\",\"isFree\":true}]},'
                      '{\"day\":0,\"date\":\"6.7.2020 Montag\",\"subs\":['
                      '{\"affectedClass\":\"5cd\",\"hours\":[2],\"teacher\":\"Wolf\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6b\",\"hours\":[5],\"teacher\":\"Himmel\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[3],\"teacher\":\"Willer\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[4],\"teacher\":\"Cap\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Frz\",\"notes\":\"\",\"isFree\":true},'
                      '{\"affectedClass\":\"9c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":true}]}]',
                ),
                ampRaisedButton(
                    text: 'Set Cache to Input',
                    onPressed: () => showCacheDialog(context)),
                ampRaisedButton(
                    text: 'Stundenplan löschen',
                    onPressed: () {
                      Prefs.jsonTimetable = null;
                      setState(() {});
                    }),
                RaisedButton.icon(
                  color: Colors.red,
                  icon: ampIcon(Icons.delete),
                  label: ampText('App-Daten löschen'),
                  onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            title: ampText('App-Daten löschen'),
                            content:
                                ampText('Löschen der App-Daten bestätigen?'),
                            backgroundColor: AmpColors.colorBackground,
                            actions: ampDialogButtonsSaveAndCancel(
                              onCancel: Navigator.of(context).pop,
                              onSave: () {
                                Prefs.clear();
                                SystemNavigator.pop();
                              },
                            ),
                          );
                        });
                  },
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: ampFab(
          onPressed: () {
            dsbUpdateWidget();
            Animations.changeScreenEaseOutBackReplace(
              MyApp(initialIndex: 2),
              context,
            );
          },
          label: 'zurück',
          icon: Icons.arrow_back,
        ),
      )
    ]);
  }

  void showInputSubListItemSpacingDialog(BuildContext context) {
    final inputFormKey = GlobalKey<FormFieldState>();
    final inputFormController =
        TextEditingController(text: Prefs.subListItemSpace.toString());
    ampDialog(
      context: context,
      title: 'Listenelementabstand',
      children: (context, setAlState) => [
        ampFormField(
          controller: inputFormController,
          key: inputFormKey,
          keyboardType: TextInputType.number,
          validator: numberValidator,
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: () => Navigator.of(context).pop(),
        onSave: () {
          if (!inputFormKey.currentState.validate()) return;
          Prefs.subListItemSpace =
              double.parse(inputFormController.text.trim());
          setState(() => Prefs.subListItemSpace);
          Navigator.of(context).pop();
        },
      ),
      rowOrColumn: ampColumn,
    );
  }

  void showCacheDialog(BuildContext context) {
    final inputFormKey = GlobalKey<FormFieldState>();
    final inputFormController =
        TextEditingController(text: Prefs.dsbJsonCache.toString());
    ampDialog(
      context: context,
      title: 'Cache',
      children: (context, setAlState) => [
        ampFormField(
          controller: inputFormController,
          key: inputFormKey,
          keyboardType: TextInputType.multiline,
          validator: textFieldValidator,
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: () => Navigator.of(context).pop(),
        onSave: () {
          if (!inputFormKey.currentState.validate()) return;
          Prefs.dsbJsonCache = inputFormController.text.trim();
          Navigator.of(context).pop();
        },
      ),
      rowOrColumn: ampColumn,
    );
  }

  void showInputTimerDialog(BuildContext context) {
    final timerInputFormKey = GlobalKey<FormFieldState>();
    final timerInputFormController =
        TextEditingController(text: Prefs.timer.toString());
    ampDialog(
      context: context,
      title: 'Timer (Minuten)',
      children: (context, setAlState) => [
        ampFormField(
          controller: timerInputFormController,
          key: timerInputFormKey,
          keyboardType: TextInputType.number,
          validator: numberValidator,
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        onCancel: () => Navigator.of(context).pop(),
        onSave: () {
          if (!timerInputFormKey.currentState.validate()) return;
          try {
            setState(() => Prefs.setTimer(
                int.parse(timerInputFormController.text.trim()), () {}));
          } catch (e) {
            return;
          }
          Navigator.of(context).pop();
        },
      ),
      rowOrColumn: ampColumn,
    );
  }
}

class DevOptionsValues {
  static TabController tabController;
}
