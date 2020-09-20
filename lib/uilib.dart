import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';

Future<Null> ampDialog({
  @required String title,
  @required List<Widget> Function(BuildContext, StateSetter) children,
  @required List<Widget> Function(BuildContext) actions,
  @required BuildContext context,
  @required Widget Function(List<Widget>) widgetBuilder,
}) =>
    showDialog(
      context: context,
      barrierDismissible: true,
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

TextFormField ampFormField({
  @required TextEditingController controller,
  @required Key key,
  String Function(String) validator,
  TextInputType keyboardType = TextInputType.text,
  String labelText = '',
  bool obscureText = false,
  List<String> autofillHints,
  Widget suffixIcon,
}) {
  autofillHints ??= [];
  suffixIcon ??= ampNull;
  return TextFormField(
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
        borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
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
  );
}

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
  Widget Function(dynamic) itemToDropdownChild = ampText,
  @required void Function(dynamic) onChanged,
}) {
  return DropdownButton(
    underline: Container(height: 2, color: AmpColors.colorForeground),
    dropdownColor: AmpColors.colorBackground,
    focusColor: AmpColors.colorBackground,
    style: AmpColors.textStyleForeground,
    value: value,
    items: items
        .map((e) => DropdownMenuItem(child: itemToDropdownChild(e), value: e))
        .toList(),
    onChanged: onChanged,
  );
}

Switch ampSwitch({@required bool value, @required Function(bool) onChanged}) {
  return Switch(
    activeColor: AmpColors.colorForeground,
    value: value,
    onChanged: onChanged,
  );
}

ListTile ampSwitchWithText(
    {@required String text,
    @required bool value,
    @required Function(bool) onChanged}) {
  return ListTile(
    title: ampText(text),
    trailing: ampSwitch(value: value, onChanged: onChanged),
  );
}

Divider ampSizedDivider(double size) =>
    Divider(color: AmpColors.colorForeground, height: size);

Divider get ampDivider => ampSizedDivider(Prefs.subListItemSpace);

List<Widget> ampDialogButtonsSaveAndCancel(
    {@required BuildContext context, @required Function() save}) {
  return [
    ampDialogButton(Language.current.cancel, Navigator.of(context).pop),
    ampDialogButton(Language.current.save, save),
  ];
}

Widget ampBigAmpButton(
    {@required void Function() onTap,
    @required IconData icon,
    @required String text,
    bool visible = true}) {
  return visible
      ? Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(32.0))),
          color: Colors.transparent,
          child: InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            customBorder: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(32.0))),
            onTap: onTap,
            child: ampColumn(
              [
                ampPadding(18),
                ampIcon(icon, size: 50),
                ampPadding(8),
                ampText(text, textAlign: TextAlign.center),
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
  var style = TextStyle(
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

Icon ampIcon(IconData data, {double size, Color color}) {
  color ??= AmpColors.colorForeground;
  return Icon(data, color: color, size: size);
}

AppBar ampAppBar(String text) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: ampText(text, size: 36, weight: FontWeight.bold),
    centerTitle: false,
  );
}

class _AmpBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(context, child, axisDirection) => child;
}

WillPopScope ampMatApp(Widget home) {
  return WillPopScope(
    child: MaterialApp(
      builder: (context, child) =>
          ScrollConfiguration(behavior: _AmpBehavior(), child: child),
      title: AmpStrings.appTitle,
      home: home,
      debugShowCheckedModeBanner: false,
    ),
    onWillPop: () async => Prefs.closeAppOnBackPress,
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
      textColor: AmpColors.colorForeground,
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

void ampChangeScreen(
  Widget w,
  BuildContext context, [
  Function(BuildContext, Route) push = Navigator.pushReplacement,
]) =>
    push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(microseconds: 1),
        transitionsBuilder: (context, animatn, secondaryAnimation, child) =>
            ScaleTransition(
          scale: CurvedAnimation(parent: animatn, curve: Curves.ease),
          alignment: Alignment.center,
          child: child,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => w,
      ),
    );

Widget ampList(List<Widget> children, [int themeId]) {
  themeId ??= Prefs.currentThemeId;
  switch (themeId) {
    case 0:
      return Card(
        elevation: 0,
        color: AmpColors.lightBackground,
        child: ampColumn(children),
      );
    case 1:
      return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AmpColors.colorForeground),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ampColumn(children),
      );
    default:
      return ampList(children, 0);
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
  @required String subtitle,
  @required String trailing,
}) =>
    ListTile(
      title: ampText(subject, size: 20),
      leading: ampText(lesson.toString(), weight: FontWeight.bold, size: 32),
      subtitle: ampText(subtitle, size: 16),
      trailing: ampText(trailing, size: 16),
    );

Widget ampPageBase(Widget child) => AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: AmpColors.colorBackground,
      child: SafeArea(child: child),
    );
