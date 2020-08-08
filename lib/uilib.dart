import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';

Future<Null> ampDialog({
  @required String title,
  @required List<Widget> Function(BuildContext, StateSetter) children,
  @required List<Widget> Function(BuildContext) actions,
  @required BuildContext context,
  @required Widget Function(List<Widget>) widgetBuilder,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: ampText(title),
        backgroundColor: AmpColors.colorBackground,
        content: StatefulBuilder(
          builder: (alertContext, setAlState) => widgetBuilder(
            children(alertContext, setAlState),
          ),
        ),
        actions: actions(context),
      );
    },
  );
}

Widget ampLinearProgressIndicator({
  bool loading = true,
  Color backgroundColor,
  Color foregroundColor,
}) {
  backgroundColor ??= AmpColors.colorBackground;
  foregroundColor ??= AmpColors.colorForeground;
  return !loading
      ? ampNull
      : LinearProgressIndicator(
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
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

FlatButton ampDialogButton(
    {@required String text, @required Function() onPressed}) {
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
    underline: Container(
      height: 2,
      color: AmpColors.colorForeground,
    ),
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
    ampDialogButton(
      onPressed: Navigator.of(context).pop,
      text: CustomValues.lang.cancel,
    ),
    ampDialogButton(
      onPressed: save,
      text: CustomValues.lang.save,
    ),
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
  var style = TextStyle(
    fontSize: size,
    fontWeight: weight,
    color: color,
    fontFamily: font != null && font.isNotEmpty ? font.first : null,
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
    title: ampText(text, size: 25),
    centerTitle: true,
  );
}

ThemeData get ampThemeData => ThemeData(
      brightness: AmpColors.brightness,
      canvasColor: AmpColors.materialColorBackground,
      primarySwatch: AmpColors.materialColorForeground,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

class _AmpBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
          BuildContext context, Widget child, AxisDirection axisDirection) =>
      child;
}

MaterialApp ampMatApp({@required String title, @required Widget home}) {
  return MaterialApp(
    builder: (context, child) =>
        ScrollConfiguration(behavior: _AmpBehavior(), child: child),
    title: title,
    theme: ampThemeData,
    home: home,
    debugShowCheckedModeBanner: false,
  );
}

SnackBar ampSnackBar(String content) => SnackBar(
      backgroundColor: AmpColors.colorBackground,
      content: ampText(content),
    );

FloatingActionButton ampFab({
  @required String label,
  @required IconData icon,
  @required void Function() onPressed,
  Color backgroundColor,
}) {
  backgroundColor ??= AmpColors.colorBackground;
  return FloatingActionButton.extended(
    elevation: 0,
    onPressed: onPressed,
    highlightElevation: 0,
    backgroundColor: backgroundColor,
    focusColor: Colors.transparent,
    splashColor: AmpColors.colorForeground,
    label: ampText(label),
    icon: ampIcon(icon),
  );
}

void ampEaseOutBack(
  Widget w,
  BuildContext context, {
  Function(BuildContext, Route) push = Navigator.push,
}) =>
    push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 200),
        transitionsBuilder: (context, animatn, secondaryAnimation, child) =>
            ScaleTransition(
          scale: CurvedAnimation(parent: animatn, curve: Curves.easeInOutBack),
          alignment: Alignment.center,
          child: child,
        ),
        pageBuilder: (context, animation, secondaryAnimation) => w,
      ),
    );
