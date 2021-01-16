import 'package:amplessimus/main.dart';

import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../logging.dart';
import 'dev_options.dart';
import '../uilib.dart';
import 'package:flutter/material.dart';
import '../appinfo.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'home_page.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;
  Settings(this.parent);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _usernameFormField = AmpFormField.username();
  late AmpFormField _passwordFormField;
  var _hide = true;
  late AmpFormField _wpeFormField;

  _SettingsState() {
    _passwordFormField =
        AmpFormField.password(() => widget.parent.rebuildDragDown());
    _wpeFormField = AmpFormField(
      prefs.wpeDomain,
      labelText: Language.current.wpemailDomain,
      keyboardType: TextInputType.url,
      onChanged: (field) {
        prefs.wpeDomain = field.text.trim();
        widget.parent.rebuildDragDown();
      },
    );
    ampInfo('Settings', 'Init done.');
  }

  Widget get changeSubVisibilityWidget => Stack(
        children: [
          ListTile(
            title: ampText(Language.current.allClasses),
            trailing: ampRow(
              [
                ampDropdownButton<String>(
                  value: prefs.classGrade,
                  items: dsb.grades,
                  onChanged: (v) {
                    setState(prefs.setClassGrade(v));
                    dsb.updateWidget(true);
                  },
                ),
                ampPadding(8),
                ampDropdownButton<String>(
                  value: prefs.classLetter,
                  items: dsb.letters,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => prefs.classLetter = v);
                    dsb.updateWidget(true);
                  },
                ),
              ],
            ),
          ),
          Center(
            child: ampSwitch(
              prefs.oneClassOnly,
              (value) {
                setState(() => prefs.oneClassOnly = value);
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
            prefs.isDarkMode,
            (v) async {
              prefs.toggleDarkModePressed();
              setState(() {
                prefs.useSystemTheme = false;
                prefs.isDarkMode = v;
              });
              await dsb.updateWidget();
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
            prefs.useSystemTheme,
            (v) {
              prefs.useSystemTheme = v;
              widget.parent.checkBrightness();
            },
          ),
          ampSwitchWithText(
            Language.current.highContrastMode,
            prefs.highContrast,
            (v) async {
              ampInfo('Settings', 'switching design mode');
              setState(() => prefs.highContrast = v);
              await dsb.updateWidget(true);
              widget.parent.rebuild();
            },
          ),
          Divider(),
          ampWidgetWithText(
            Language.current.changeLanguage,
            ampDropdownButton<Language>(
              value: Language.current,
              itemToDropdownChild: (i) => ampText(i.name),
              items: Language.all,
              onChanged: (v) {
                if (v == null) return;
                setState(() => Language.current = v);
                widget.parent.rebuildDragDown();
              },
            ),
          ),
          ampSwitchWithText(
            Language.current.useForDsb,
            prefs.dsbUseLanguage,
            (v) {
              setState(() => prefs.dsbUseLanguage = v);
              widget.parent.rebuildDragDown();
            },
          ),
          Divider(),
          changeSubVisibilityWidget,
          ampSwitchWithText(
            Language.current.parseSubjects,
            prefs.parseSubjects,
            (v) {
              setState(() => prefs.parseSubjects = v);
              widget.parent.rebuildDragDown();
            },
          ),
          Divider(),
          AutofillGroup(
            child: ampColumn([
              _usernameFormField.flutter(),
              _passwordFormField.flutter(
                suffixIcon:
                    ampHidePwdBtn(_hide, () => setState(() => _hide = !_hide)),
                obscureText: _hide,
              )
            ]),
          ),
          Divider(),
          _wpeFormField.flutter(),
          Divider(),
          Row(
            children: [
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
          DevOptions(),
        ],
        scrollDirection: Axis.vertical,
      ),
    );
  }
}
