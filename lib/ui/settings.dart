import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/ui/dev_options.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/colors.dart' as AmpColors;
import 'package:Amplessimus/stringsisabadname.dart' as AmpStrings;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pedantic/pedantic.dart';

class Settings extends StatefulWidget {
  final AmpHomePageState parent;
  Settings(this.parent);

  @override
  State<StatefulWidget> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<Null> credentialDialog() {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController =
        TextEditingController(text: Prefs.username);
    final passwordInputFormController =
        TextEditingController(text: Prefs.password);
    var passwordHidden = true;
    return ampDialog(
      context: context,
      title: Language.current.changeLoginPopup,
      children: (context, setAlState) => [
        ampPadding(2),
        ampFormField(
          controller: usernameInputFormController,
          key: usernameInputFormKey,
          labelText: Language.current.username,
          keyboardType: TextInputType.visiblePassword,
          autofillHints: [AutofillHints.username],
        ),
        ampPadding(6),
        ampFormField(
          suffixIcon: IconButton(
            onPressed: () => setAlState(() => passwordHidden = !passwordHidden),
            icon: passwordHidden
                ? ampIcon(Icons.visibility)
                : ampIcon(Icons.visibility_off),
          ),
          controller: passwordInputFormController,
          key: passwordInputFormKey,
          labelText: Language.current.password,
          keyboardType: TextInputType.visiblePassword,
          obscureText: passwordHidden,
          autofillHints: [AutofillHints.password],
        )
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.username = usernameInputFormController.text.trim();
          Prefs.password = passwordInputFormController.text.trim();
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Prefs.devOptionsEnabled)
      ampBigButton(
        onTap: () => ampChangeScreen(DevOptions(), widget.parent.context),
        icon: MdiIcons.codeBrackets,
        text: 'Entwickleroptionen',
      );

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: Colors.transparent,
      child: Scaffold(
        appBar: ampAppBar(Language.current.settings),
        backgroundColor: Colors.transparent,
        body: ampColumn(
          [
            ampSwitchWithText(
              //TODO: translate
              'Dark Mode',
              AmpColors.isDarkMode,
              (v) async {
                Prefs.toggleDarkModePressed();
                Prefs.useSystemTheme = false;
                AmpColors.isDarkMode = v;
                await dsbUpdateWidget();
                Future.delayed(
                  Duration(milliseconds: 150),
                  () => setState(() {}),
                );
              },
            ),
            ampSwitchWithText(
              //TODO: see above
              'Lights use system?',
              Prefs.useSystemTheme,
              (v) {
                Prefs.useSystemTheme = v;
                widget.parent.checkBrightness();
              },
            ),
            ampSwitchWithText(
              //TODO: see above
              'Alternative appearance',
              Prefs.altTheme,
              (v) async {
                ampInfo('Settings', 'switching design mode');
                Prefs.altTheme = v;
                await dsbUpdateWidget();
                setState(() {});
                scaffoldMessanger.showSnackBar(ampSnackBar(
                  Language.current.changedAppearance,
                  Language.current.show,
                  () => setState(() => widget.parent.tabController.index = 0),
                ));
              },
            ),
            ampDivider,
            ampDropdownButton(
              value: Language.current,
              itemToDropdownChild: (i) => ampText(i.name),
              items: Language.all,
              onChanged: (v) {
                setState(() => Language.current = v);
                widget.parent.rebuildDragDown();
              },
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
            ListTile(
              leading: ampText('Class'),
              trailing: ampRow(
                [
                  ampDropdownButton(
                    value: Prefs.grade,
                    items: dsbGrades,
                    onChanged: (value) => setState(() {
                      Prefs.grade = value;
                      try {
                        if (int.parse(value) > 10) Prefs.char = '';
                        // ignore: empty_catches
                      } catch (e) {}
                    }),
                  ),
                  ampPadding(10),
                  ampDropdownButton(
                    value: Prefs.char,
                    items: dsbLetters,
                    onChanged: (value) => setState(() => Prefs.char = value),
                  ),
                ],
              ),
            ),
            ampDivider,
            ListTile(
              leading: ampBigButton(
                onTap: () => credentialDialog(),
                icon: AmpColors.isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
                text: Language.current.changeLogin,
              ),
              trailing: ampBigButton(
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: AmpStrings.appTitle,
                  applicationVersion: AmpStrings.version,
                  applicationIcon:
                      SvgPicture.asset('assets/logo.svg', height: 40),
                  children: [Text(Language.current.appInfo)],
                  //TODO: flame flutter people for not letting me set the
                  //background color
                ),
                icon: AmpColors.isDarkMode
                    ? MdiIcons.folderInformation
                    : MdiIcons.folderInformationOutline,
                text: Language.current.settingsAppInfo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
