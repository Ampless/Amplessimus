import 'dart:io';

import 'package:amplessimus/ui/settings.dart';

import 'first_login.dart';
import '../langs/language.dart';
import '../logging.dart';
// ignore: library_prefixes
import '../prefs.dart' as Prefs;
import '../uilib.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DevOptions extends StatefulWidget {
  DevOptions(this.parent);
  final SettingsState parent;
  @override
  State<StatefulWidget> createState() => DevOptionsState();
}

class DevOptionsState extends State<DevOptions>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    if (!Prefs.devOptionsEnabled) return ampNull;
    return ampColumn(
      [
        Divider(),
        ampSwitchWithText(
          'Entwickleroptionen aktiviert',
          Prefs.devOptionsEnabled,
          (v) => setState(() => Prefs.devOptionsEnabled = v),
        ),
        ampSwitchWithText(
          'JSON Cache benutzen',
          Prefs.useJsonCache,
          (v) => setState(() => Prefs.useJsonCache = v),
        ),
        ampSwitchWithText(
          'Update Notifier',
          Prefs.updatePopup,
          (v) => setState(() => Prefs.updatePopup = v),
        ),
        Divider(),
        ListTile(
          title: ampText('Refreshtimer (Minuten)'),
          trailing: ampText('${Prefs.timer}'),
          onTap: () => _inputTimerDialog(context),
        ),
        Divider(),
        ampPadding(5),
        ampRaisedButton('Print Cache', Prefs.listCache),
        ampRaisedButton('Clear Cache', Prefs.clearCache),
        ampRaisedButton(
          'Set Cache to Kekw',
          () => Prefs.dsbJsonCache = '[{\"day\":4,\"date\":\"4.12.2020 Freitag\",\"subs\":['
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
    );
  }

  void _cacheDialog(BuildContext context) {
    final cacheFormField = AmpFormField(Prefs.dsbJsonCache);
    ampDialog(
      context: context,
      title: 'Cache',
      children: (_, __) => [cacheFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          Prefs.dsbJsonCache = cacheFormField.text.trim();
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  void _inputTimerDialog(BuildContext context) {
    final timerFormField =
        AmpFormField(Prefs.timer, keyboardType: TextInputType.number);
    ampDialog(
      context: context,
      title: 'Timer (Minuten)',
      children: (context, setAlState) => [timerFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () {
          try {
            setState(() => Prefs.timer = int.parse(timerFormField.text.trim()));
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
