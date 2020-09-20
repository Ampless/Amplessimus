import 'dart:io';

import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/screens/loading_animation.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ampMatApp(DevOptionsScreenPage(), pop: () async {
      await dsbUpdateWidget();
      ampChangeScreen(AmpApp(2), context);
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
  Widget build(BuildContext context) => Scaffold(
        appBar: ampAppBar('Entwickleroptionen'),
        backgroundColor: Colors.transparent,
        body: ampPageBase(
          Center(
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
                  onChanged: (value) =>
                      setState(() => Prefs.useJsonCache = value),
                ),
                ampDivider,
                ampListTile(
                  'Listenelementabstand',
                  trailing: '${Prefs.subListItemSpace}',
                  onTap: () => showInputSubListItemSpacingDialog(context),
                ),
                ampListTile(
                  'Refreshtimer (Minuten)',
                  trailing: '${Prefs.timer}',
                  onTap: () => showInputTimerDialog(context),
                ),
                ampDivider,
                ampPadding(5),
                ampRaisedButton('Print Cache', Prefs.listCache),
                ampRaisedButton('Clear Cache', Prefs.clearCache),
                ampRaisedButton(
                  'Set Cache to Kekw',
                  () => Prefs.dsbJsonCache = '[{\"day\":4,\"date\":\"24.7.2020 Freitag\",\"subs\":['
                      '{\"affectedClass\":\"5c\",\"hours\":[3],\"teacher\":\"Häußler\",\"subject\":\"D\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"9b\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Bio\",\"notes\":\"\",\"isFree\":true}]},'
                      '{\"day\":0,\"date\":\"27.7.2020 Montag\",\"subs\":['
                      '{\"affectedClass\":\"5cd\",\"hours\":[2],\"teacher\":\"Wolf\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6b\",\"hours\":[5],\"teacher\":\"Gnan\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[3],\"teacher\":\"Albl\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[4],\"teacher\":\"Fikrle\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                      '{\"affectedClass\":\"6c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Frz\",\"notes\":\"\",\"isFree\":true},'
                      '{\"affectedClass\":\"9c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":true}]}]',
                ),
                ampRaisedButton(
                    'Set Cache to Input', () => showCacheDialog(context)),
                ampRaisedButton('Stundenplan löschen', () {
                  Prefs.jsonTimetable = null;
                  setState(() {});
                }),
                ampRaisedButton('Schlechte Ladeanimation', () {
                  ampChangeScreen(
                    ampMatApp(AmpLoadingAnimation(), pop: () async => false),
                    context,
                  );
                }),
                ampRaisedButton('Log leeeeeEHREn', () => setState(ampClearLog)),
                ampRaisedButton(
                  'App-Daten löschen',
                  () {
                    ampDialog(
                      title: 'App-Daten löschen',
                      context: context,
                      widgetBuilder: ampRow,
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
                ampLogWidget,
              ],
            ),
          ),
        ),
        floatingActionButton: ampFab(
          onPressed: () {
            dsbUpdateWidget();
            ampChangeScreen(AmpApp(2), context);
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
          validator: (value) => num.tryParse(value) == null
              ? Language.current.widgetValidatorInvalid
              : null,
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
      widgetBuilder: ampColumn,
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
      widgetBuilder: ampColumn,
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
          validator: (value) => num.tryParse(value) == null
              ? Language.current.widgetValidatorInvalid
              : null,
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
      widgetBuilder: ampColumn,
    );
  }
}
