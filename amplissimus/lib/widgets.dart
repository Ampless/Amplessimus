import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Widgets {
  static Widget toggleDarkModeWidget(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.lightbulbOn : MdiIcons.lightbulbOnOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(
            isDarkMode ? 'Licht an' : 'Licht aus',
            style: textStyle,
          )
        ],
      ),
    );
  }

  static Widget entryCredentialsWidget(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.key : MdiIcons.keyOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(
            'Login-Daten',
            style: textStyle,
          )
        ],
      ),
    );
  }

  static void showInputEntryCredentials(BuildContext context) {
    final usernameInputFormKey = GlobalKey<FormFieldState>();
    final passwordInputFormKey = GlobalKey<FormFieldState>();
    final usernameInputFormController = TextEditingController(text: Prefs.username);
    final passwordInputFormController = TextEditingController(text: Prefs.password);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AmpColors.colorBackground,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style: TextStyle(color: AmpColors.colorForeground),
                controller: usernameInputFormController,
                key: usernameInputFormKey,
                validator: textFieldValidator,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelStyle: TextStyle(color: AmpColors.colorForeground),
                  labelText: 'Benutzername',
                  fillColor: AmpColors.colorForeground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                    BorderSide(color: AmpColors.colorForeground)
                  )
                ),
              ),
              Padding(padding: EdgeInsets.all(6)),
              TextFormField(
                style: TextStyle(color: AmpColors.colorForeground),
                controller: passwordInputFormController,
                key: passwordInputFormKey,
                validator: textFieldValidator,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: AmpColors.colorForeground),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'Passwort',
                  fillColor: AmpColors.colorForeground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AmpColors.colorForeground),
                  )
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () => {Navigator.of(context).pop()},
              child: Text('Abbrechen'),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                bool condA = passwordInputFormKey.currentState.validate();
                bool condB = usernameInputFormKey.currentState.validate();
                if (!condA || !condB) return;
                Prefs.saveCredentials(usernameInputFormController.text.toString().trim(), 
                  passwordInputFormController.text.toString().trim());
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  static String textFieldValidator(String value) {
    if (value.trim().isEmpty) return 'Feld ist leer!';
    return null;
  }
}
