import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

  static Widget setCurrentClassWidget(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.school : MdiIcons.schoolOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text('Klasse auswählen', style: textStyle,)
        ],
      ),
    );
  }

  static String gradeFieldValidator(String value) {
    List<String> grades = ['5','6','7','8','9','10','11','12','13', ''];
    if(!grades.contains(value.trim())) return 'Keine Zahl von 5 bis 13!';
    return null;
  }

  static String letterFieldValidator(String value) {
    List<String> letters = ['a','b','c','d','e','f','g','h','i','q', ''];
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

  static Widget loadingWidget(int id) {
    switch (id) {
      case 0:
        return SpinKitFoldingCube(
          size: 100,
          duration: Duration(milliseconds: 350),
          color: AmpColors.colorForeground,
        );
        break;
      case 1:
        return SpinKitWave(
          size: 100,
          duration: Duration(milliseconds: 1050),
          color: AmpColors.colorForeground,
        );
        break;
      case 2:
        return SpinKitCubeGrid(
          size: 100,
          duration: Duration(milliseconds: 350),
          color: AmpColors.colorForeground,
        );
        break;
      default:
        return SpinKitFoldingCube(
          size: 100,
          duration: Duration(milliseconds: 350),
          color: AmpColors.colorForeground,
        );
        break;
    }
    
  }

  static String numberValidator(String value) {
    if (value.trim().isEmpty) return 'Feld ist leer!';
    final n = num.tryParse(value);
    if (n == null) return '"$value" ist keine Zahl!';
    if (n < 0) return '"$value" ist keine positive Zahl!';
    return null;
  }
  
}
