import 'colors.dart' as AmpColors;
import 'langs/language.dart';
import 'prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<Null> ampDialog({
  @required String title,
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
      title: ampText(title),
      backgroundColor: AmpColors.colorBackground,
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
          backgroundColor: AmpColors.colorBackground,
          valueColor: AlwaysStoppedAnimation<Color>(AmpColors.colorForeground),
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

Tab ampTab(IconData icon, String text) => Tab(icon: Icon(icon), text: text);

FlatButton ampDialogButton(String text, Function() onPressed) {
  return FlatButton(
    textColor: AmpColors.colorForeground,
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
    underline: Container(height: 2, color: AmpColors.colorForeground),
    dropdownColor: AmpColors.lightBackground,
    focusColor: AmpColors.colorBackground,
    style: AmpColors.textStyleForeground,
    value: value,
    items: items
        .map((e) => DropdownMenuItem(child: itemToDropdownChild(e), value: e))
        .toList(),
    onChanged: onChanged,
  );
}

Switch ampSwitch(bool value, Function(bool) onChanged) {
  return Switch(
    activeColor: AmpColors.colorForeground,
    inactiveTrackColor: AmpColors.lightBackground,
    activeTrackColor: AmpColors.lightForeground,
    inactiveThumbColor: AmpColors.colorForeground,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    value: value,
    onChanged: onChanged,
  );
}

ListTile ampSwitchWithText(String text, bool value, Function(bool) onChanged) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

ListTile ampWidgetWithText(String text, Widget w) =>
    ListTile(leading: ampText(text), trailing: w);

Divider ampSizedDivider(double size) =>
    Divider(color: AmpColors.colorForeground, height: size);

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
  IconData icon,
  void Function() onTap, {
  bool visible = true,
}) {
  return visible
      ? Card(
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
                ampIcon(icon, size: 50),
                ampPadding(8),
                ampText(text, textAlign: TextAlign.center),
                ampPadding(8),
              ],
            ),
          ),
        )
      : ampNull;
}

RaisedButton ampRaisedButton(String text, void Function() onPressed) {
  return RaisedButton(
    color: AmpColors.lightBackground,
    splashColor: AmpColors.lightForeground,
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
  color ??= AmpColors.colorForeground;
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

Icon ampIcon(IconData data, {double size}) =>
    Icon(data, color: AmpColors.colorForeground, size: size);

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
      backgroundColor: AmpColors.colorBackground,
      content: ampText(content),
      action: label != null ? ampSnackBarAction(label, action) : null,
    );

SnackBarAction ampSnackBarAction(String label, Function() onPressed) =>
    SnackBarAction(
      textColor: AmpColors.lightForeground,
      label: label,
      onPressed: onPressed,
    );

FloatingActionButton ampFab({
  @required String label,
  @required IconData icon,
  @required void Function() onPressed,
}) {
  return FloatingActionButton.extended(
    elevation: 0,
    onPressed: onPressed,
    highlightElevation: 0,
    backgroundColor: AmpColors.colorBackground,
    focusColor: Colors.transparent,
    splashColor: AmpColors.colorForeground,
    label: ampText(label),
    icon: ampIcon(icon),
  );
}

Future ampChangeScreen(
  Widget w,
  BuildContext context, [
  Future Function(BuildContext, Route) push = Navigator.pushReplacement,
]) =>
    push(context, MaterialPageRoute(builder: (_) => w));

Widget ampList(List<Widget> children, [bool altTheme]) {
  altTheme ??= Prefs.altTheme;
  if (!altTheme) {
    return Card(
      elevation: 0,
      color: AmpColors.lightBackground,
      child: ampColumn(children),
    );
  } else {
    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: AmpColors.colorForeground),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ampColumn(children),
    );
  }
}

ListTile ampListTile(
  String title, {
  String subtitle,
  String leading,
  String trailing,
  Function() onTap,
}) =>
    ListTile(
      title: title == null ? null : ampText(title),
      subtitle: subtitle == null ? null : ampText(subtitle),
      leading: leading == null ? null : ampText(leading),
      trailing: trailing == null ? null : ampText(trailing),
      onTap: onTap,
    );

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
      color: AmpColors.colorBackground,
      child: SafeArea(child: child),
    );

TabBar ampTabBar(TabController controller, List<Tab> tabs) => TabBar(
      controller: controller,
      indicatorColor: AmpColors.colorForeground,
      labelColor: AmpColors.colorForeground,
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
          style: AmpColors.textStyleForeground,
          keyboardAppearance: AmpColors.brightness,
          controller: controller,
          key: key,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            suffixIcon: suffixIcon,
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AmpColors.colorForeground, width: 1.0),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: AmpColors.colorForeground, width: 2.0),
              borderRadius: BorderRadius.circular(10),
            ),
            labelStyle: AmpColors.textStyleForeground,
            labelText: labelText,
            fillColor: AmpColors.colorForeground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AmpColors.colorForeground),
            ),
          ),
        ),
        ampPadding(3),
      ],
    );
  }

  bool Function() get validate => key.currentState.validate;
  String get text => controller.text;
}
