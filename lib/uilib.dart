import 'langs/language.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'main.dart';
import 'logging.dart';

Future<Null> ampDialog(
  BuildContext context, {
  String? title,
  required List<Widget> Function(BuildContext, StateSetter) children,
  required List<Widget> Function(BuildContext) actions,
  required Widget Function(List<Widget>) widgetBuilder,
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

TextButton ampDialogButton(String text, Function() onPressed) =>
    TextButton(onPressed: onPressed, child: Text(text));

DropdownButton<T> ampDropdownButton<T>({
  required T value,
  required List<T> items,
  required void Function(T?) onChanged,
  Widget Function(T)? itemToDropdownChild,
}) {
  itemToDropdownChild ??= ampText;
  return DropdownButton<T>(
    value: value,
    items: items
        .map((e) => DropdownMenuItem(value: e, child: itemToDropdownChild!(e)))
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
    {required Function() save}) {
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
      child: InkWell(
        onTap: onTap,
        child: ampColumn(
          [
            ampIcon(iconDefault, iconOutlined, 50),
            ampPadding(4),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

ElevatedButton ampRaisedButton(String text, void Function() onPressed) =>
    ElevatedButton(onPressed: onPressed, child: Text(text));

Padding ampPadding(double value, [Widget? child]) =>
    Padding(padding: EdgeInsets.all(value), child: child);

Text ampText<T>(
  T text, {
  double? size,
  TextAlign? align,
  FontWeight? weight,
  Color? color,
  String Function(T)? toString,
  List<String>? font,
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

Icon ampIcon(IconData dataDefault, IconData dataOutlined, [double? size]) =>
    Icon(prefs.highContrast ? dataOutlined : dataDefault, size: size);

IconButton ampHidePwdBtn(bool hidden, Function() setHidden) => IconButton(
      onPressed: setHidden,
      icon: hidden
          ? ampIcon(Icons.visibility_off, Icons.visibility_off_outlined)
          : ampIcon(Icons.visibility, Icons.visibility_outlined),
    );

SnackBar ampSnackBar(
  String content, [
  String? label,
  Function()? f,
]) =>
    SnackBar(
      content: Text(content),
      action: label != null && f != null
          ? SnackBarAction(label: label, onPressed: f)
          : null,
    );

FloatingActionButton ampFab({
  required String label,
  required IconData iconDefault,
  required IconData iconOutlined,
  required void Function() onPressed,
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
      margin: EdgeInsets.all(4),
      elevation: 0,
      color: Color(prefs.isDarkMode ? 0xff101010 : 0xffefefef),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: ampColumn(children),
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

TabBar ampTabBar(TabController? controller, List<Tab> tabs) => TabBar(
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
  final String Function() label;
  final void Function(AmpFormField)? onChanged;

  static String _noLabel() => '';

  AmpFormField(
    Object initialValue, {
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.label = _noLabel,
    this.onChanged,
  }) : controller = TextEditingController(text: initialValue.toString());

  Widget flutter({
    Widget? suffixIcon,
    bool obscureText = false,
  }) {
    return ampColumn(
      [
        ampPadding(
          2,
          TextFormField(
            onChanged: (_) {
              (onChanged ?? (_) {})(this);
            },
            obscureText: obscureText,
            controller: controller,
            key: key,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            decoration: InputDecoration(
              suffixIcon: suffixIcon,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1.0,
                  color: prefs.isDarkMode ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                  color: prefs.isDarkMode ? Colors.white : Colors.black,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: label(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: prefs.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String get text => controller.text;

  static AmpFormField username([Function()? rebuild]) => AmpFormField(
        prefs.username,
        label: () => Language.current.username,
        keyboardType: TextInputType.number,
        autofillHints: [AutofillHints.username],
        onChanged: (field) {
          prefs.username = field.text.trim();
          if (rebuild != null) rebuild();
        },
      );

  static AmpFormField password([Function()? rebuild]) => AmpFormField(
        prefs.password,
        label: () => Language.current.password,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.password],
        onChanged: (field) {
          prefs.password = field.text.trim();
          if (rebuild != null) rebuild();
        },
      );
}
