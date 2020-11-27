import 'dart:io';

import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevOptions extends StatefulWidget {
  DevOptions();
  @override
  State<StatefulWidget> createState() => DevOptionsState();
}

class DevOptionsState extends State<DevOptions>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ampAppBar('Entwickleroptionen'),
        backgroundColor: Colors.transparent,
        body: ampPageBase(
          ListView(
            children: [
              ampDivider,
              ampSwitchWithText(
                text: 'Entwickleroptionen aktiviert',
                value: Prefs.devOptionsEnabled,
                onChanged: (value) =>
                    setState(() => Prefs.devOptionsEnabled = value),
              ),
              ampSwitchWithText(
                text: 'JSON Cache benutzen',
                value: Prefs.useJsonCache,
                onChanged: (value) =>
                    setState(() => Prefs.useJsonCache = value),
              ),
              ampSwitchWithText(
                text: 'Update Notifier',
                value: Prefs.updatePopup,
                onChanged: (v) => setState(() => Prefs.updatePopup = v),
              ),
              ampDivider,
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
                () => Prefs.dsbJsonCache = '[{\"day\":4,\"date\":\"25.9.2020 Freitag\",\"subs\":['
                    '{\"affectedClass\":\"5c\",\"hours\":[3],\"teacher\":\"Häußler\",\"subject\":\"D\",\"notes\":\"\",\"isFree\":false},'
                    '{\"affectedClass\":\"9b\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Bio\",\"notes\":\"\",\"isFree\":true}]},'
                    '{\"day\":0,\"date\":\"28.9.2020 Montag\",\"subs\":['
                    '{\"affectedClass\":\"5cd\",\"hours\":[2],\"teacher\":\"Wolf\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                    '{\"affectedClass\":\"6b\",\"hours\":[5],\"teacher\":\"Gnan\",\"subject\":\"Kath\",\"notes\":\"\",\"isFree\":false},'
                    '{\"affectedClass\":\"6c\",\"hours\":[3],\"teacher\":\"Albl\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                    '{\"affectedClass\":\"6c\",\"hours\":[4],\"teacher\":\"Fikrle\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":false},'
                    '{\"affectedClass\":\"6c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"Frz\",\"notes\":\"\",\"isFree\":true},'
                    '{\"affectedClass\":\"9c\",\"hours\":[6],\"teacher\":\"---\",\"subject\":\"E\",\"notes\":\"\",\"isFree\":true}]}]',
              ),
              ampRaisedButton(
                  'Set Cache to Input', () => showCacheDialog(context)),
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
                      context,
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
        floatingActionButton: ampFab(
          onPressed: () {
            dsbUpdateWidget();
            ampChangeScreen(AmpHomePage(2), context);
          },
          label: 'zurück',
          icon: Icons.arrow_back,
        ),
      );

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
        context,
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
        context,
        save: () {
          if (!timerInputFormKey.currentState.validate()) return;
          try {
            setState(() =>
                Prefs.timer = int.parse(timerInputFormController.text.trim()));
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
