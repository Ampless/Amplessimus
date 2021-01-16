import 'dart:io';

import '../main.dart';
import 'first_login.dart';
import '../logging.dart';
import '../uilib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevOptions extends StatefulWidget {
  @override
  _DevOptionsState createState() => _DevOptionsState();
}

class _DevOptionsState extends State<DevOptions> {
  @override
  Widget build(BuildContext context) {
    if (!prefs.devOptionsEnabled) return ampNull;
    return ampColumn(
      [
        Divider(),
        ampSwitchWithText(
          'Entwickleroptionen aktiviert',
          prefs.devOptionsEnabled,
          (v) => setState(() => prefs.devOptionsEnabled = v),
        ),
        ampSwitchWithText(
          'JSON Cache benutzen',
          prefs.useJsonCache,
          (v) => setState(() => prefs.useJsonCache = v),
        ),
        ampSwitchWithText(
          'Update Notifier',
          prefs.updatePopup,
          (v) => setState(() => prefs.updatePopup = v),
        ),
        Divider(),
        ListTile(
          title: ampText('Refreshtimer (Minuten)'),
          trailing: ampText('${prefs.timer}'),
          onTap: () => _inputTimerDialog(context),
        ),
        Divider(),
        ampPadding(5),
        ampRaisedButton('Print Cache', prefs.listCache),
        ampRaisedButton('Clear Cache', prefs.clearCache),
        ampRaisedButton(
          'Set Cache to Kekw',
          () => prefs.dsbJsonCache = '[{\"day\":4,\"date\":\"4.12.2020 Freitag\",\"subs\":['
              '{\"class\":\"5c\",\"lesson\":3,\"sub_teacher\":\"Häußler\",\"subject\":\"D\",\"notes\":\"\",\"free\":false},'
              '{\"class\":\"9b\",\"lesson\":6,\"sub_teacher\":\"---\",\"subject\":\"Bio\",\"notes\":\"\",\"free\":true}]},'
              '{\"day\":0,\"date\":\"7.12.2020 Montag\",\"subs\":['
              '{\"class\":\"5cd\",\"lesson\":2,\"sub_teacher\":\"Wolf\",\"subject\":\"Kath\",\"notes\":\"\",\"free\":false},'
              '{\"class\":\"6b\",\"lesson\":5,\"sub_teacher\":\"Gnan\",\"subject\":\"Kath\",\"notes\":\"\",\"free\":false},'
              '{\"class\":\"6c\",\"lesson\":3,\"sub_teacher\":\"Albl\",\"subject\":\"E\",\"notes\":\"\",\"free\":false},'
              '{\"class\":\"6c\",\"lesson\":4,\"sub_teacher\":\"Fikrle\",\"subject\":\"E\",\"notes\":\"\",\"free\":false},'
              '{\"class\":\"6c\",\"lesson\":6,\"sub_teacher\":\"---\",\"subject\":\"Frz\",\"notes\":\"\",\"free\":true},'
              '{\"class\":\"9c\",\"lesson\":6,\"sub_teacher\":\"---\",\"subject\":\"E\",\"notes\":\"\",\"free\":true}]}]',
        ),
        ampRaisedButton('Set Cache to Input', () => _cacheDialog(context)),
        ampRaisedButton('Log leeeeeEHREn', () => setState(ampClearLog)),
        ampRaisedButton(
            'först lockin', () => ampChangeScreen(FirstLogin(), context)),
        ampRaisedButton(
          'App-Daten löschen',
          () {
            ampDialog(
              context,
              title: 'App-Daten löschen',
              widgetBuilder: ampRow,
              children: (_, __) => [ampText('Sicher?')],
              actions: (context) => ampDialogButtonsSaveAndCancel(
                context,
                save: () async {
                  await prefs.clear();
                  exit(0);
                },
              ),
            );
          },
        ),
        ampLogWidget,
      ],
    );
  }

  void _cacheDialog(BuildContext context) {
    final cacheFormField = AmpFormField(prefs.dsbJsonCache, labelText: 'Cache');
    ampDialog(
      context,
      children: (_, __) => [cacheFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          prefs.dsbJsonCache = cacheFormField.text.trim();
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  void _inputTimerDialog(BuildContext context) {
    final timerFormField = AmpFormField(
      prefs.timer,
      keyboardType: TextInputType.number,
      labelText: 'Timer (Minuten)',
    );
    ampDialog(
      context,
      children: (_, __) => [timerFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          try {
            setState(() => prefs.timer = int.parse(timerFormField.text.trim()));
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
