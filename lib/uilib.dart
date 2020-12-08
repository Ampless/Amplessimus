import 'langs/language.dart';
// ignore: library_prefixes
import 'prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Null> ampDialog({
  String title,
  @required List<Widget> Function(BuildContext, StateSetter) children,
  @required List<Widget> Function(BuildContext) actions,
  @required BuildContext context,
  @required Widget Function(List<Widget>) widgetBuilder,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => AlertDialog(
      title: title != null ? ampText(title) : null,
      backgroundColor: Prefs.colorBackground,
      content: StatefulBuilder(
        builder: (alertContext, setAlState) => widgetBuilder(
          children(alertContext, setAlState),
        ),
      ),
      actions: actions(context),
    ),
  );
}

Widget ampLinearProgressIndicator([bool loading = true]) {
  return !loading
      ? ampNull
      : LinearProgressIndicator(
          backgroundColor: Prefs.colorBackground,
          valueColor: AlwaysStoppedAnimation<Color>(Prefs.colorForeground),
          semanticsLabel: 'Loading (accessibility is being...worked on)',
        );
}

final ampNull = Container(width: 0, height: 0);

Column ampColumn(List<Widget> children) => Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

Row ampRow(List<Widget> children) => Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

Tab ampTab(IconData iconDefault, IconData iconOutlined, String text) =>
    Tab(icon: Icon(Prefs.altTheme ? iconOutlined : iconDefault), text: text);

FlatButton ampDialogButton(String text, Function() onPressed) {
  return FlatButton(
    textColor: Prefs.colorForeground,
    onPressed: onPressed,
    child: ampText(text),
  );
}

DropdownButton ampDropdownButton({
  @required dynamic value,
  @required List<dynamic> items,
  @required void Function(dynamic) onChanged,
  Widget Function(dynamic) itemToDropdownChild = ampText,
}) {
  return DropdownButton(
    underline: Container(height: 2, color: Prefs.colorForeground),
    dropdownColor: Prefs.lightBackground,
    focusColor: Prefs.colorBackground,
    style: Prefs.textStyleForeground,
    value: value,
    items: items
        .map((e) => DropdownMenuItem(child: itemToDropdownChild(e), value: e))
        .toList(),
    onChanged: onChanged,
  );
}

Switch ampSwitch(bool value, Function(bool) onChanged) {
  return Switch(
    activeColor: Prefs.colorForeground,
    inactiveTrackColor: Prefs.lightBackground,
    activeTrackColor: Prefs.lightForeground,
    inactiveThumbColor: Prefs.colorForeground,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    value: value,
    onChanged: onChanged,
  );
}

ListTile ampSwitchWithText(String text, bool value, Function(bool) onChanged) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

ListTile ampWidgetWithText(String text, Widget w) =>
    ListTile(title: ampText(text), trailing: w);

Divider ampSizedDivider(double size) =>
    Divider(color: Prefs.colorForeground, height: size);

Divider get ampDivider => ampSizedDivider(0);

List<Widget> ampDialogButtonsSaveAndCancel(BuildContext context,
    {@required Function() save}) {
  return [
    ampDialogButton(Language.current.cancel, Navigator.of(context).pop),
    ampDialogButton(Language.current.save, save),
  ];
}

Widget ampBigButton(
  String text,
  IconData iconDefault,
  IconData iconOutlined,
  void Function() onTap,
) =>
    Card(
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: ampColumn(
          [
            ampPadding(8),
            ampIcon(iconDefault, iconOutlined, size: 50),
            ampPadding(8),
            ampText(text, textAlign: TextAlign.center),
            ampPadding(8),
          ],
        ),
      ),
    );

RaisedButton ampRaisedButton(String text, void Function() onPressed) {
  return RaisedButton(
    color: Prefs.lightBackground,
    splashColor: Prefs.lightForeground,
    child: ampText(text),
    onPressed: onPressed,
  );
}

Padding ampPadding(double value) => Padding(padding: EdgeInsets.all(value));

Text ampText(
  dynamic text, {
  double size,
  TextAlign textAlign,
  FontWeight weight,
  Color color,
  String Function(dynamic) toString,
  List<String> font,
}) {
  toString ??= (o) => o.toString();
  color ??= Prefs.colorForeground;
  font ??= [];
  final style = TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFamily: font.isNotEmpty ? font.first : null,
    fontFamilyFallback: font,
  );
  return Text(
    toString(text),
    style: style,
    textAlign: textAlign,
  );
}

Text ampSubtitle(String s) => ampText(s, size: 16, weight: FontWeight.w600);

Icon ampIcon(IconData dataDefault, IconData dataOutlined, {double size}) =>
    Icon(
      Prefs.altTheme ? dataOutlined : dataDefault,
      color: Prefs.colorForeground,
      size: size,
    );

AppBar ampAppBar(String text) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: ampText(text, size: 36, weight: FontWeight.bold),
    centerTitle: false,
  );
}

SnackBar ampSnackBar(
  String content, [
  String label,
  Function() action,
]) =>
    SnackBar(
      backgroundColor: Prefs.colorBackground,
      content: ampText(content),
      action: label != null ? ampSnackBarAction(label, action) : null,
    );

SnackBarAction ampSnackBarAction(String label, Function() onPressed) =>
    SnackBarAction(
      textColor: Prefs.lightForeground,
      label: label,
      onPressed: onPressed,
    );

FloatingActionButton ampFab({
  @required String label,
  @required IconData iconDefault,
  @required IconData iconOutlined,
  @required void Function() onPressed,
}) {
  return FloatingActionButton.extended(
    elevation: 0,
    onPressed: onPressed,
    highlightElevation: 0,
    backgroundColor: Prefs.colorBackground,
    focusColor: Colors.transparent,
    splashColor: Prefs.colorForeground,
    label: ampText(label),
    icon: ampIcon(iconDefault, iconOutlined),
  );
}

Future ampChangeScreen(
  Widget w,
  BuildContext context, [
  Future Function(BuildContext, Route) push = Navigator.pushReplacement,
]) =>
    push(context, MaterialPageRoute(builder: (_) => w));

Widget ampList(List<Widget> children) {
  if (!Prefs.altTheme) {
    return Card(
      elevation: 0,
      color: Prefs.lightBackground,
      child: ampColumn(children),
    );
  } else {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Prefs.colorForeground),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ampColumn(children),
    );
  }
}

ListTile ampLessonTile({
  @required String subject,
  @required String lesson,
  @required String orgTeacher,
  @required String subtitle,
  @required String affClass,
}) =>
    ListTile(
      title: ampText(
        orgTeacher == null ? '$subject' : '$subject ($orgTeacher)',
        size: 18,
      ),
      leading: ampText(lesson, weight: FontWeight.bold, size: 34),
      subtitle: ampText(subtitle, size: 16),
      trailing: ampText(affClass, weight: FontWeight.bold, size: 20),
    );

Widget ampPageBase(Widget child) => AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: Prefs.colorBackground,
      child: SafeArea(child: child),
    );

TabBar ampTabBar(TabController controller, List<Tab> tabs) => TabBar(
      controller: controller,
      indicatorColor: Prefs.colorForeground,
      labelColor: Prefs.colorForeground,
      tabs: tabs,
    );

Future<Null> ampOpenUrl(String url) => canLaunch(url).then((value) {
      if (value) launch(url);
    });

Text ampErrorText(dynamic e) => ampText(errorString(e),
    color: Colors.red, weight: FontWeight.bold, size: 20);

class AmpFormField {
  final key = GlobalKey<FormFieldState>();
  final TextEditingController controller;
  final List<String> autofillHints;
  final TextInputType keyboardType;
  final String Function(String) validator;
  final String labelText;

  AmpFormField(
    Object initialValue, {
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.validator,
    this.labelText = '',
  }) : controller = TextEditingController(text: initialValue.toString());

  Widget flutter({
    Widget suffixIcon,
    bool obscureText = false,
  }) {
    suffixIcon ??= ampNull;
    return ampColumn(
      [
        ampPadding(3),
        TextFormField(
          obscureText: obscureText,
          style: Prefs.textStyleForeground,
          keyboardAppearance: Prefs.brightness,
          controller: controller,
          key: key,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Prefs.colorForeground, width: 1.0),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Prefs.colorForeground, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: Prefs.textStyleForeground,
            labelText: labelText,
            fillColor: Prefs.colorForeground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Prefs.colorForeground),
            ),
          ),
        ),
        ampPadding(3),
      ],
    );
  }

  bool Function() get validate => key.currentState.validate;
  String get text => controller.text;

  static AmpFormField get username => AmpFormField(
        Prefs.username,
        labelText: Language.current.username,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.username],
      );

  static AmpFormField get password => AmpFormField(
        Prefs.password,
        labelText: Language.current.password,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.password],
      );
}
