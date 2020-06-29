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

Future<Null> ampTextDialog(
    {@required String title,
    @required List<Widget> Function(BuildContext) children,
    @required List<Widget> Function(BuildContext) actions,
    @required BuildContext context}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: Text(title, style: AmpColors.textStyleForeground),
        backgroundColor: AmpColors.colorBackground,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: children(context),
        ),
        actions: actions(context),
      );
    },
  );
}

Widget ampFormField(
    {@required TextEditingController controller,
    @required Key key,
    @required String Function(String) validator,
    TextInputType keyboardType = TextInputType.visiblePassword,
    String labelText = ''}) {
  return TextFormField(
    style: AmpColors.textStyleForeground,
    keyboardAppearance: AmpColors.brightness,
    controller: controller,
    key: key,
    validator: validator,
    keyboardType: keyboardType,
    decoration: InputDecoration(
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
      height: underlineDisabled ? 2 : 0,
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

Widget ampSettingsWidget(
    {@required void Function() onTap, @required Widget child}) {
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
      child: child,
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
