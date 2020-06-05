import 'package:amplissimus/prefs.dart' as Prefs;
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
          title: Text('DSB-Mobile Daten', style: TextStyle(color: AmpColors.colorForeground),),
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
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
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
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
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
                Prefs.username = usernameInputFormController.text.trim();
                Prefs.password = passwordInputFormController.text.trim();
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  static Widget setCurrentClassWidget(bool isDarkMode, TextStyle textStyle) {
    
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.school : MdiIcons.schoolOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text('Klasse auswählen',style: textStyle,)
        ],
      ),
    );
  }
  
  static void showInputSelectCurrentClass(BuildContext context) {
    final gradeInputFormKey = GlobalKey<FormFieldState>();
    final charInputFormKey = GlobalKey<FormFieldState>();
    final gradeInputFormController = TextEditingController(text: Prefs.grade);
    final charInputFormController = TextEditingController(text: Prefs.char.toUpperCase());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Klasse auswählen', style: TextStyle(color: AmpColors.colorForeground),),
          backgroundColor: AmpColors.colorBackground,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  style: TextStyle(color: AmpColors.colorForeground),
                  controller: gradeInputFormController,
                  key: gradeInputFormKey,
                  validator: gradeFieldValidator,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: AmpColors.colorForeground),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Stufe',
                    fillColor: AmpColors.colorForeground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AmpColors.colorForeground),
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(6)),
              Flexible(
                child: TextFormField(
                  style: TextStyle(color: AmpColors.colorForeground),
                  controller: charInputFormController,
                  key: charInputFormKey,
                  validator: letterFieldValidator,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: AmpColors.colorForeground),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: AmpColors.colorForeground, width: 2.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    labelText: 'Buchstabe',
                    fillColor: AmpColors.colorForeground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AmpColors.colorForeground),
                    ),
                  ),
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
                bool condA = gradeInputFormKey.currentState.validate();
                bool condB = charInputFormKey.currentState.validate();
                if(!condA || !condB) return;
                Prefs.grade = gradeInputFormController.text.trim();
                Prefs.char = charInputFormController.text.trim();
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  static String gradeFieldValidator(String value) {
    List<String> grades = ['5','6','7','8','9','10','11','12','13'];
    if(value.trim().isEmpty) return 'Feld ist leer!';
    if(!grades.contains(value.trim())) return 'Keine Zahl von 5 bis 13!';
    return null;
  }

  static String letterFieldValidator(String value) {
    List<String> letters = ['a','b','c','d','e','f','g','h','i','q'];
    if(value.trim().isEmpty) return 'Feld ist leer!';
    if(!letters.contains(value.trim().toLowerCase())) return 'Ungültige Eingabe!';
    return null;
  }

  static String textFieldValidator(String value) {
    if (value.trim().isEmpty) return 'Feld ist leer!';
    return null;
  }

  static Widget developerOptionsWidget(TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(MdiIcons.codeBrackets, size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text('Entwickleroptionen',style: textStyle,),
        ],
      ),
    );
  }
}
