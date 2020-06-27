import 'package:Amplissimus/values.dart';
import 'package:flutter/material.dart';

Future<Null> ampDialog({@required String title,
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
        content: StatefulBuilder(builder: (BuildContext alertContext, StateSetter setAlState) =>
          Theme(
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

Widget ampDialogButton({String text, Function onPressed}) {
  return FlatButton(
    textColor: AmpColors.colorForeground,
    onPressed: onPressed,
    child: Text(text),
  );
}
