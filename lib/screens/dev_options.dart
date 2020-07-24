import 'dart:io';

import 'package:Amplessimus/animations.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: ampMatApp(
          title: AmpStrings.appTitle,
          home: DevOptionsScreenPage(),
        ),
        onWillPop: () async {
          await dsbUpdateWidget();
          Animations.changeScreenEaseOutBackReplace(
              AmpApp(initialIndex: 2), context);
          return false;
        });
  }
}

class DevOptionsScreenPage extends StatefulWidget {
  DevOptionsScreenPage();
  @override
  State<StatefulWidget> createState() => DevOptionsScreenPageState();
}

class DevOptionsScreenPageState extends State<DevOptionsScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    ampInfo(ctx: 'DevOptionsScreenPageState', message: 'initState()');
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ampAppBar('Entwickleroptionen'),
        backgroundColor: Colors.transparent,
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
                  text: 'App schließt bei zurück-Taste',
                  value: Prefs.closeAppOnBackPress,
                  onChanged: (value) =>
                      setState(() => Prefs.closeAppOnBackPress = value),
                ),
                ampSwitchWithText(
                  text: 'JSON Cache benutzen',
                  value: Prefs.useJsonCache,
                  onChanged: (value) {
                    setState(() => Prefs.useJsonCache = value);
                  },
                ),
                ampDivider,
                ListTile(
                  title: ampText('Listenelementabstand'),
                  trailing: ampText('${Prefs.subListItemSpace}'),
                  onTap: () => showInputSubListItemSpacingDialog(context),
                ),
                ListTile(
                  title: ampText('Refreshtimer (Minuten)'),
                  trailing: ampText('${Prefs.timer}'),
                  onTap: () => showInputTimerDialog(context),
                ),
                ampDivider,
                ampPadding(5),
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
                      '{\"affectedClass\":\"6b\",\"hours\":[5],\"teacher\":\"Gnan\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[3],\"teacher\":\"Lehnert\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[4],\"teacher\":\"Häußler\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
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
                    ampDialog(
                      title: 'App-Daten löschen',
                      context: context,
                      rowOrColumn: ampRow,
                      children: (_, __) => [ampText('Sicher?')],
                      actions: (context) => ampDialogButtonsSaveAndCancel(
                        context: context,
                        save: () async {
                          await Prefs.clear();
                          exit(0);
                        },
                      ),
                    );
                  },
                ),
                logWidget,
              ],
            ),
          ),
        ),
        floatingActionButton: ampFab(
          onPressed: () {
            dsbUpdateWidget();
            Animations.changeScreenEaseOutBackReplace(
              AmpApp(initialIndex: 2),
              context,
            );
          },
          label: 'zurück',
          icon: Icons.arrow_back,
        ),
      );

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
        context: context,
        save: () {
          if (!inputFormKey.currentState.validate()) return;
          Prefs.subListItemSpace =
              double.parse(inputFormController.text.trim());
          setState(Prefs.waitForMutex);
          Navigator.pop(context);
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
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context: context,
        save: () {
          Prefs.dsbJsonCache = inputFormController.text.trim();
          Navigator.pop(context);
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
        context: context,
        save: () {
          if (!timerInputFormKey.currentState.validate()) return;
          try {
            setState(() => Prefs.setTimer(
                int.parse(timerInputFormController.text.trim()), () {}));
          } catch (e) {
            return;
          }
          Navigator.pop(context);
        },
      ),
      rowOrColumn: ampColumn,
    );
  }
}