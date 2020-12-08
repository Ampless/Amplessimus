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
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<Null> credentialDialog() {
    final usernameFormField = AmpFormField.username;
    final passwordFormField = AmpFormField.password;
    var passwordHidden = true;
    return ampDialog(
      context: context,
      title: Language.current.changeLoginPopup,
      children: (context, setAlState) => [
        ampPadding(2),
        usernameFormField.flutter(),
        ampPadding(6),
        passwordFormField.flutter(
          suffixIcon: IconButton(
            onPressed: () => setAlState(() => passwordHidden = !passwordHidden),
            icon: passwordHidden
                ? ampIcon(Icons.visibility, Icons.visibility_outlined)
                : ampIcon(Icons.visibility_off, Icons.visibility_off_outlined),
          ),
          obscureText: passwordHidden,
        )
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
                  onChanged: (value) => setState(() {
                    Prefs.classGrade = value;
                    try {
                      if (int.parse(value) > 10) {
                        Prefs.classLetter = '';
                      }
                      // ignore: empty_catches
                    } catch (e) {}
                  }),
                ),
                ampPadding(8),
                ampDropdownButton(
                  value: Prefs.classLetter,
                  items: dsbLetters,
                  onChanged: (value) =>
                      setState(() => Prefs.classLetter = value),
                ),
              ],
            ),
          ),
          Center(
            child: ampSwitch(
              Prefs.oneClassOnly,
              (value) {
                setState(() => Prefs.oneClassOnly = value);
                dsbUpdateWidget(
                    callback: widget.parent.rebuild, useJsonCache: true);
              },
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return ampPageBase(
      ListView(
        children: [
          ampAppBar(Language.current.settings),
          ampSwitchWithText(
            Language.current.darkMode,
            Prefs.isDarkMode,
            (v) async {
              Prefs.toggleDarkModePressed();
              Prefs.useSystemTheme = false;
              Prefs.isDarkMode = v;
              await dsbUpdateWidget();
              Future.delayed(
                Duration(milliseconds: 150),
                widget.parent.rebuild,
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
            Language.current.alternativeAppearance,
            Prefs.altTheme,
            (v) async {
              ampInfo('Settings', 'switching design mode');
              Prefs.altTheme = v;
              await dsbUpdateWidget();
              widget.parent.rebuild();
              scaffoldMessanger.showSnackBar(ampSnackBar(
                Language.current.changedAppearance,
                Language.current.show,
                () => widget.parent.tabController.index = 0,
              ));
            },
          ),
          ampDivider,
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
          ampDivider,
          changeSubVisibilityWidget,
          ampSwitchWithText(
            Language.current.parseSubjects,
            Prefs.parseSubjects,
            (v) {
              setState(() => Prefs.parseSubjects = v);
              widget.parent.rebuildDragDown();
            },
          ),
          ampDivider,
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
                () => showAboutDialog(
                  context: context,
                  applicationName: appTitle,
                  applicationVersion: appVersion,
                  applicationIcon:
                      SvgPicture.asset('assets/logo.svg', height: 40),
                  children: [Text(Language.current.appInfo)],
                  //TODO: flame flutter people for not letting me set the
                  //background color
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
