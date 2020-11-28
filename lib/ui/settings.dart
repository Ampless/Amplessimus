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
  Future<Null> selectClassDialog() {
    var letter = Prefs.char;
    var grade = Prefs.grade;
    if (letter.isEmpty || !dsbLetters.contains(letter)) letter = dsbLetters[0];
    if (grade.isEmpty || !dsbGrades.contains(grade)) grade = dsbGrades[0];
    return ampDialog(
      context: context,
      title: Language.current.selectClass,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: grade,
          items: dsbGrades,
          onChanged: (value) => setAlState(() {
            grade = value;
            try {
              if (int.parse(value) > 10) letter = '';
              // ignore: empty_catches
            } catch (e) {}
          }),
        ),
        ampPadding(10),
        ampDropdownButton(
          value: letter,
          items: dsbLetters,
          onChanged: (value) => setAlState(() => letter = value),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Prefs.grade = grade;
          Prefs.char = letter;
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampRow,
    );
  }

  Future<Null> changeLanguageDialog() {
    var lang = Language.current;
    var use = Prefs.dsbUseLanguage;
    return ampDialog(
      context: context,
      title: Language.current.changeLanguage,
      children: (alertContext, setAlState) => [
        ampDropdownButton(
          value: lang,
          itemToDropdownChild: (i) => ampText(i.name),
          items: Language.all,
          onChanged: (value) => setAlState(() => lang = value),
        ),
        ampSizedDivider(5),
        ampSwitchWithText(
          Language.current.useForDsb,
          use,
          (v) => setAlState(() => use = v),
        ),
      ],
      actions: (context) => ampDialogButtonsSaveAndCancel(
        context,
        save: () async {
          Language.current = lang;
          Prefs.dsbUseLanguage = use;
          unawaited(widget.parent.rebuildDragDown());
          Navigator.pop(context);
        },
      ),
      widgetBuilder: ampColumn,
    );
  }

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
    final buttons = <Widget>[
      ampBigButton(
        onTap: () {
          Prefs.toggleDarkModePressed();
          Prefs.useSystemTheme = false;
          AmpColors.switchMode();
          dsbUpdateWidget();
          Future.delayed(
            Duration(milliseconds: 150),
            () => setState(() {}),
          );
        },
        icon: AmpColors.isDarkMode
            ? MdiIcons.lightbulbOn
            : MdiIcons.lightbulbOnOutline,
        text: AmpColors.isDarkMode
            ? Language.current.lightsOn
            : Language.current.lightsOff,
      ),
      ampBigButton(
        onTap: () async {
          ampInfo('Settings', 'switching design mode');
          Prefs.currentThemeId = (Prefs.currentThemeId + 1) % 2;
          await dsbUpdateWidget();
          setState(() {});
          scaffoldMessanger.showSnackBar(ampSnackBar(
            Language.current.changedAppearance,
            Language.current.show,
            () => setState(() => widget.parent.tabController.index = 0),
          ));
        },
        icon: AmpColors.isDarkMode
            ? MdiIcons.clipboardList
            : MdiIcons.clipboardListOutline,
        text: Language.current.changeAppearance,
      ),
      ampBigButton(
        onTap: () async {
          Prefs.useSystemTheme = !Prefs.useSystemTheme;
          widget.parent.checkBrightness();
        },
        icon: MdiIcons.brightness6,
        text: Prefs.useSystemTheme
            ? Language.current.lightsNoSystem
            : Language.current.lightsUseSystem,
      ),
      ampBigButton(
        onTap: () => changeLanguageDialog(),
        icon: MdiIcons.translate,
        text: Language.current.changeLanguage,
      ),
      ampBigButton(
        onTap: () => credentialDialog(),
        icon: AmpColors.isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
        text: Language.current.changeLogin,
      ),
      ampBigButton(
        onTap: () => selectClassDialog(),
        icon: AmpColors.isDarkMode ? MdiIcons.school : MdiIcons.schoolOutline,
        text: Language.current.selectClass,
      ),
      ampBigButton(
        onTap: () => showAboutDialog(
          context: context,
          applicationName: AmpStrings.appTitle,
          applicationVersion: AmpStrings.version,
          applicationIcon: SvgPicture.asset('assets/logo.svg', height: 40),
          children: [Text(Language.current.appInfo)],
          //TODO: flame flutter people for not letting me set the
          //background color
        ),
        icon: AmpColors.isDarkMode
            ? MdiIcons.folderInformation
            : MdiIcons.folderInformationOutline,
        text: Language.current.settingsAppInfo,
      ),
    ];

    if (Prefs.devOptionsEnabled)
      buttons.add(ampBigButton(
        onTap: () => ampChangeScreen(DevOptions(), widget.parent.context),
        icon: MdiIcons.codeBrackets,
        text: 'Entwickleroptionen',
      ));

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: Colors.transparent,
      child: Scaffold(
        appBar: ampAppBar(Language.current.settings),
        backgroundColor: Colors.transparent,
        body: GridView.count(
          crossAxisCount: 2,
          children: buttons,
        ),
      ),
    );
  }
}
