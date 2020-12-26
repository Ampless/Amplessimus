import 'package:amplessimus/main.dart';

import '../dsbapi.dart';
import '../langs/language.dart';
import '../logging.dart';
import 'dev_options.dart';
import '../uilib.dart';
import 'package:flutter/material.dart';
// ignore: library_prefixes
import '../prefs.dart' as Prefs;
import '../appinfo.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pedantic/pedantic.dart';

import 'home_page.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;
  Settings(this.parent);

  @override
  State<StatefulWidget> createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  Future<Null> credentialDialog() {
    final usernameFormField = AmpFormField.username;
    final passwordFormField = AmpFormField.password;
    var hide = true;
    return ampDialog(
      context: context,
      title: Language.current.changeLoginPopup,
      children: (context, setAlState) => [
        AutofillGroup(
          child: ampColumn([
            usernameFormField.flutter(),
            passwordFormField.flutter(
              suffixIcon:
                  ampHidePwdBtn(hide, () => setAlState(() => hide = !hide)),
              obscureText: hide,
            )
          ]),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.username = usernameFormField.text.trim();
          Prefs.password = passwordFormField.text.trim();
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Future<Null> wpemailDomainPopup() {
    final domainFormField = AmpFormField(
      Prefs.wpeDomain,
      labelText: Language.current.wpemailDomain,
      keyboardType: TextInputType.url,
    );
    return ampDialog(
      context: context,
      children: (context, setAlState) => [domainFormField.flutter()],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.wpeDomain = domainFormField.text.trim();
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  Widget get changeSubVisibilityWidget => Stack(
        children: [
          ListTile(
            title: ampText(Language.current.allClasses),
            trailing: ampRow(
              [
                ampDropdownButton(
                  value: Prefs.classGrade,
                  items: dsbGrades,
                  onChanged: (v) => setState(Prefs.setClassGrade(v)),
                ),
                ampPadding(8),
                ampDropdownButton(
                  value: Prefs.classLetter,
                  items: dsbLetters,
                  onChanged: (v) => setState(() => Prefs.classLetter = v),
                ),
              ],
            ),
          ),
          Center(
            child: ampSwitch(
              Prefs.oneClassOnly,
              (value) {
                setState(() => Prefs.oneClassOnly = value);
                widget.parent.rebuildDragDown();
              },
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          ampTitle(Language.current.settings),
          ampSwitchWithText(
            Language.current.darkMode,
            Prefs.isDarkMode,
            (v) async {
              Prefs.toggleDarkModePressed();
              setState(() {
                Prefs.useSystemTheme = false;
                Prefs.isDarkMode = v;
              });
              await dsbUpdateWidget();
              Future.delayed(
                Duration(milliseconds: 150),
                widget.parent.rebuild,
              );
              Future.delayed(
                Duration(milliseconds: 150),
                () => rebuildWholeApp(),
              );
            },
          ),
          ampSwitchWithText(
            Language.current.useSystemTheme,
            Prefs.useSystemTheme,
            (v) {
              Prefs.useSystemTheme = v;
              widget.parent.checkBrightness();
            },
          ),
          ampSwitchWithText(
            Language.current.highContrastMode,
            Prefs.highContrast,
            (v) async {
              ampInfo('Settings', 'switching design mode');
              setState(() => Prefs.highContrast = v);
              await dsbUpdateWidget(true);
              widget.parent.rebuild();
            },
          ),
          Divider(),
          ampWidgetWithText(
            Language.current.changeLanguage,
            ampDropdownButton(
              value: Language.current,
              itemToDropdownChild: (i) => ampText(i.name),
              items: Language.all,
              onChanged: (v) {
                setState(() => Language.current = v);
                widget.parent.rebuildDragDown();
              },
            ),
          ),
          ampSwitchWithText(
            Language.current.useForDsb,
            Prefs.dsbUseLanguage,
            (v) {
              setState(() => Prefs.dsbUseLanguage = v);
              widget.parent.rebuildDragDown();
            },
          ),
          Divider(),
          changeSubVisibilityWidget,
          ampSwitchWithText(
            Language.current.parseSubjects,
            Prefs.parseSubjects,
            (v) {
              setState(() => Prefs.parseSubjects = v);
              widget.parent.rebuildDragDown();
            },
          ),
          Divider(),
          Row(
            children: [
              ampBigButton(
                Language.current.changeLogin,
                Icons.vpn_key,
                Icons.vpn_key_outlined,
                () => credentialDialog(),
              ),
              ampBigButton(
                Language.current.wpemailDomain,
                Icons.cloud,
                Icons.cloud_outlined,
                () => wpemailDomainPopup(),
              ),
              ampBigButton(
                Language.current.settingsAppInfo,
                Icons.info,
                Icons.info_outline,
                () async => showAboutDialog(
                  context: context,
                  applicationName: appTitle,
                  applicationVersion: await appVersion,
                  applicationIcon:
                      SvgPicture.asset('assets/logo.svg', height: 40),
                  children: [Text(Language.current.appInfo)],
                ),
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceAround,
          ),
          DevOptions(this),
        ],
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
