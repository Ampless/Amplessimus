import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'langs/language.dart';
import 'main.dart';

Future<Null> ampDialog(
  BuildContext context, {
  String? title,
  required List<Widget> Function(BuildContext, StateSetter) children,
  required List<Widget> Function(BuildContext) actions,
  required Widget Function(List<Widget>) widgetBuilder,
  bool barrierDismissible = true,
}) {
  return showCupertinoDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => CupertinoAlertDialog(
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

material.Tab ampTab(IconData iconDefault, IconData iconOutlined, String text) =>
    material.Tab(icon: ampIcon(iconDefault, iconOutlined), text: text);

CupertinoButton ampButton(String text, Function() onPressed) =>
    CupertinoButton(onPressed: onPressed, child: Text(text));

material.DropdownButton<T> ampDropdownButton<T>({
  required T value,
  required List<T> items,
  required void Function(T?) onChanged,
  Widget Function(T)? itemToDropdownChild,
}) {
  itemToDropdownChild ??= ampText;
  return material.DropdownButton<T>(
    value: value,
    items: items
        .map((e) =>
            material.DropdownMenuItem(child: itemToDropdownChild!(e), value: e))
        .toList(),
    onChanged: onChanged,
  );
}

material.Switch ampSwitch(bool value, Function(bool) onChanged) =>
    material.Switch(value: value, onChanged: onChanged);

Widget ampSwitchWithText(String text, bool value, Function(bool) onChanged) =>
    ampWidgetWithText(text, ampSwitch(value, onChanged));

Widget ampWidgetWithText(String text, Widget w) =>
    material.ListTile(title: Text(text), trailing: w);

List<Widget> ampButtonsSaveAndCancel(BuildContext context,
    {required Function() save}) {
  return [
    ampButton(Language.current.cancel, Navigator.of(context).pop),
    ampButton(Language.current.save, save),
  ];
}

List<Widget> ampButtonOk(
  BuildContext context,
) =>
    [ampButton('OK', Navigator.of(context).pop)];

Widget ampBigButton(
  String text,
  IconData iconDefault,
  IconData iconOutlined,
  void Function() onTap,
) =>
    material.Card(
      elevation: 0,
      child: material.InkWell(
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

CupertinoButton ampHidePwdBtn(bool hidden, Function() setHidden) =>
    CupertinoButton(
      onPressed: setHidden,
      child: hidden
          ? ampIcon(material.Icons.visibility_off,
              material.Icons.visibility_off_outlined)
          : ampIcon(
              material.Icons.visibility, material.Icons.visibility_outlined),
    );

CupertinoButton ampFab({
  required String label,
  required void Function() onPressed,
}) {
  return CupertinoButton.filled(
    onPressed: onPressed,
    child: Text(label),
  );
}

Future ampChangeScreen(
  Widget w,
  BuildContext context, [
  Future Function(BuildContext, Route) push = Navigator.pushReplacement,
]) =>
    push(context, CupertinoPageRoute(builder: (_) => w));

Widget ampList(List<Widget> children) {
  if (!prefs.highContrast) {
    return material.Card(
      margin: EdgeInsets.all(4),
      child: ampColumn(children),
      elevation: 0,
      color: Color(prefs.isDarkMode ? 0xff101010 : 0xffefefef),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  } else {
    return Container(
      margin: EdgeInsets.all(4),
      child: ampColumn(children),
      decoration: BoxDecoration(
        border: Border.all(
          color:
              prefs.isDarkMode ? CupertinoColors.white : CupertinoColors.black,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

material.TabBar ampTabBar(
        material.TabController? controller, List<material.Tab> tabs) =>
    material.TabBar(
      controller: controller,
      tabs: tabs,
    );

Future<Null> ampOpenUrl(String url) => url_launcher.canLaunch(url).then((b) {
      if (b) url_launcher.launch(url);
    });

Widget ampErrorText(dynamic e) => ampPadding(
    8,
    ampText(
      errorString(e),
      color: CupertinoColors.systemRed,
      weight: FontWeight.bold,
      size: 20,
    ));

class AmpFormField {
  final key = GlobalKey<FormFieldState>();
  final TextEditingController controller;
  final List<String> autofillHints;
  final TextInputType keyboardType;
  final String labelText;
  final void Function(AmpFormField)? onChanged;

  AmpFormField(
    Object initialValue, {
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.labelText = '',
    this.onChanged,
  }) : controller = TextEditingController(text: initialValue.toString());

  Widget flutter({
    Widget? suffix,
    bool obscureText = false,
  }) {
    return ampColumn(
      [
        ampPadding(
          2,
          CupertinoTextField(
            onChanged: (_) {
              (onChanged ?? (_) {})(this);
            },
            obscuringCharacter: 'x',
            obscureText: obscureText,
            controller: controller,
            key: key,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            suffix: suffix,
            placeholder: labelText,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: prefs.isDarkMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
                //radius: BorderRadius.circular(10),
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
        labelText: Language.current.username,
        keyboardType: TextInputType.number,
        autofillHints: [AutofillHints.username],
        onChanged: (field) {
          prefs.username = field.text.trim();
          if (rebuild != null) rebuild();
        },
      );

  static AmpFormField password([Function()? rebuild]) => AmpFormField(
        prefs.password,
        labelText: Language.current.password,
        keyboardType: TextInputType.visiblePassword,
        autofillHints: [AutofillHints.password],
        onChanged: (field) {
          prefs.password = field.text.trim();
          if (rebuild != null) rebuild();
        },
      );
}
