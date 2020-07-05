import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/values.dart';
import 'package:flutter/material.dart';

Future<Null> ampSelectionDialog(
    {@required String title,
    @required List<Widget> Function(BuildContext, StateSetter) inputChildren,
    @required List<Widget> Function(BuildContext) actions,
    @required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: TextStyle(color: AmpColors.colorForeground)),
        backgroundColor: AmpColors.colorBackground,
        content: StatefulBuilder(
          builder: (BuildContext alertContext, StateSetter setAlState) => Theme(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: inputChildren(alertContext, setAlState),
            ),
            data: ThemeData(canvasColor: AmpColors.materialColorBackground),
          ),
        ),
        actions: actions(context),
      );
    },
  );
}

Future<Null> showAmpTextDialog(
    {@required String title,
    @required List<Widget> Function(BuildContext) children,
    @required List<Widget> Function(BuildContext) actions,
    @required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return MaterialApp(
        home: AlertDialog(
          title: Text(title, style: AmpColors.textStyleForeground),
          backgroundColor: AmpColors.colorBackground,
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children(context),
            ),
          ),
          actions: actions(context),
        ),
        builder: (context, child) =>
            ScrollConfiguration(behavior: MyBehavior(), child: child),
      );
    },
  );
}

Widget ampFormField(
    {@required TextEditingController controller,
    @required Key key,
    @required String Function(String) validator,
    TextInputType keyboardType = TextInputType.text,
    String labelText = '',
    bool obscureText = false,
    List<String> autofillHints,
    Widget suffixIcon}) {
  suffixIcon ??= Container(
      height: 0,
      width: 0,
    );
  autofillHints ??= [];
  return TextFormField(
    obscureText: obscureText,
    style: AmpColors.textStyleForeground,
    keyboardAppearance: AmpColors.brightness,
    controller: controller,
    key: key,
    validator: validator,
    keyboardType: keyboardType,
    autofillHints: autofillHints,
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
        labelStyle: TextStyle(color: AmpColors.colorForeground),
        labelText: labelText,
        fillColor: AmpColors.colorForeground,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AmpColors.colorForeground))),
  );
}

Widget ampDialogButton(
    {@required String text, @required Function() onPressed}) {
  return FlatButton(
    textColor: AmpColors.colorForeground,
    onPressed: onPressed,
    child: Text(text),
  );
}

Widget ampDropdownButton(
    {@required dynamic value,
    @required List<DropdownMenuItem<dynamic>> items,
    @required void Function(dynamic) onChanged,
    bool underlineDisabled = false}) {
  return DropdownButton(
    underline: Container(
      height: underlineDisabled ? 0 : 2,
      color: AmpColors.colorForeground,
    ),
    style: AmpColors.textStyleForeground,
    value: value,
    items: items,
    onChanged: onChanged,
  );
}

Widget ampSwitchWithText(
    {@required String text,
    @required bool value,
    @required Function(bool) onChanged}) {
  return ListTile(
    title: Text(text, style: AmpColors.textStyleForeground),
    trailing: Switch(
      activeColor: AmpColors.colorForeground,
      value: value,
      onChanged: onChanged,
    ),
  );
}

List<Widget> ampDialogButtonsSaveAndCancel(
    {@required Function() onCancel, @required Function() onSave}) {
  return [
    ampDialogButton(
      onPressed: onCancel,
      text: CustomValues.lang.cancel,
    ),
    ampDialogButton(
      onPressed: onSave,
      text: CustomValues.lang.save,
    ),
  ];
}

Widget ampBigAmpButton(
    {@required void Function() onTap,
    @required IconData icon,
    @required String text,
    bool visible = true}) {
  return Card(
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
      child: Center(
        child: Column(
          children: <Widget>[
            Padding(padding: EdgeInsets.all(24)),
            Icon(icon,
                size: 50,
                color: visible
                    ? AmpColors.colorForeground
                    : AmpColors.colorBackground),
            Padding(padding: EdgeInsets.all(10)),
            Text(text,
                style: visible
                    ? AmpColors.textStyleForeground
                    : AmpColors.textStyleBackground,
                textAlign: TextAlign.center)
          ],
        ),
      ),
    ),
  );
}

Widget ampAppBar(String text, {double fontSize = 25}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.transparent,
    title: Text(text,
        style: TextStyle(fontSize: fontSize, color: AmpColors.colorForeground)),
    centerTitle: true,
  );
}
