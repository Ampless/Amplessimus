import 'langs/language.dart';
import 'prefs.dart' as prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

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
      title: title != null ? Text(title) : null,
      content: StatefulBuilder(
        builder: (alertContext, setAlState) => widgetBuilder(
          children(alertContext, setAlState),
        ),
      ),
      actions: actions(context),
    ),
  );
}

final ampNull = Container(width: 0, height: 0);

Column ampColumn(List<Widget> children) =>
    Column(mainAxisSize: MainAxisSize.min, children: children);

Row ampRow(List<Widget> children) =>
    Row(mainAxisSize: MainAxisSize.min, children: children);

Tab ampTab(IconData iconDefault, IconData iconOutlined, String text) =>
    Tab(icon: ampIcon(iconDefault, iconOutlined), text: text);

FlatButton ampDialogButton(String text, Function() onPressed) =>
    FlatButton(onPressed: onPressed, child: Text(text));

DropdownButton ampDropdownButton<T>({
  @required T value,
  @required List<T> items,
  @required void Function(T) onChanged,
  Widget Function(T) itemToDropdownChild,
}) {
  itemToDropdownChild ??= ampText;
  return DropdownButton(
    value: value,
    items: items
        .map((e) => DropdownMenuItem(child: itemToDropdownChild(e), value: e))
        .toList(),
    onChanged: onChanged,
  );
}

Switch ampSwitch(bool value, Function(bool) onChanged) =>
    Switch(value: value, onChanged: onChanged);

ListTile ampSwitchWithText(String text, bool value, Function(bool) onChanged) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

ListTile ampWidgetWithText(String text, Widget w) =>
    ListTile(title: Text(text), trailing: w);

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
        onTap: onTap,
        child: ampColumn(
          [
            ampIcon(iconDefault, iconOutlined, size: 50),
            ampPadding(4),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

RaisedButton ampRaisedButton(String text, void Function() onPressed) =>
    RaisedButton(child: Text(text), onPressed: onPressed);

Padding ampPadding(double value, [Widget child]) => Padding(
      padding: EdgeInsets.all(value),
      child: child,
    );

Text ampText<T>(
  T text, {
  double size,
  TextAlign align,
  FontWeight weight,
  Color color,
  String Function(T) toString,
  List<String> font,
}) {
  toString ??= (o) => o.toString();
  font ??= [];
  final style = TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFamily: font.isNotEmpty ? font.first : null,
    fontFamilyFallback: font,
  );
  return Text(toString(text), style: style, textAlign: align);
}

Widget ampTitle(String text) =>
    ampPadding(16, ampText(text, size: 36, weight: FontWeight.bold));

Icon ampIcon(IconData dataDefault, IconData dataOutlined, {double size}) =>
    Icon(prefs.highContrast ? dataOutlined : dataDefault, size: size);

IconButton ampHidePwdBtn(bool hidden, Function() setHidden) => IconButton(
      onPressed: setHidden,
      icon: hidden
          ? ampIcon(Icons.visibility_off, Icons.visibility_off_outlined)
          : ampIcon(Icons.visibility, Icons.visibility_outlined),
    );

SnackBar ampSnackBar(
  String content, [
  String label,
  Function() f,
]) =>
    SnackBar(
      content: Text(content),
      action: label != null ? SnackBarAction(label: label, onPressed: f) : null,
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
    label: Text(label),
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
  if (!prefs.highContrast) {
    return Card(
      elevation: 0,
      child: ampColumn(children),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      margin: EdgeInsets.all(4),
    );
  } else {
    return Container(
      margin: EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: prefs.isDarkMode ? Colors.white : Colors.black,
        ),
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
      //somehow this improved/"fixed" the spacing, idk how
      horizontalTitleGap: 4,
      title: ampText(
        orgTeacher == null || orgTeacher.isEmpty
            ? subject
            : '$subject ($orgTeacher)',
        size: 18,
      ),
      leading: ampText(lesson, weight: FontWeight.bold, size: 36),
      subtitle: ampText(subtitle, size: 16),
      trailing: ampText(affClass, weight: FontWeight.bold, size: 20),
    );

TabBar ampTabBar(TabController controller, List<Tab> tabs) => TabBar(
      controller: controller,
      tabs: tabs,
      indicatorColor: prefs.themeData.accentColor,
      labelColor: prefs.themeData.colorScheme.onSurface,
      unselectedLabelColor: prefs.themeData.unselectedWidgetColor,
    );

Future<Null> ampOpenUrl(String url) => url_launcher.canLaunch(url).then((b) {
      if (b) url_launcher.launch(url);
    });

Widget ampErrorText(dynamic e) => ampPadding(
    8,
    ampText(
      errorString(e),
      color: Colors.red,
      weight: FontWeight.bold,
      size: 20,
    ));

class AmpFormField {
  final key = GlobalKey<FormFieldState>();
  final TextEditingController controller;
  final List<String> autofillHints;
  final TextInputType keyboardType;
  final String labelText;

  AmpFormField(
    Object initialValue, {
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.labelText = '',
  }) : controller = TextEditingController(text: initialValue.toString());

  Widget flutter({
    Widget suffixIcon,
    bool obscureText = false,
  }) {
    suffixIcon ??= ampNull;
    return ampColumn(
      [
        ampPadding(
          2,
          TextFormField(
            obscureText: obscureText,
            controller: controller,
            key: key,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1.0),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2.0),
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: labelText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get text => controller.text;

  static AmpFormField get username => AmpFormField(
        prefs.username,
        labelText: Language.current.username,
        keyboardType: TextInputType.number,
        autofillHints: [AutofillHints.username],
      );

  static AmpFormField get password => AmpFormField(
        prefs.password,
        labelText: Language.current.password,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.password],
      );
}
