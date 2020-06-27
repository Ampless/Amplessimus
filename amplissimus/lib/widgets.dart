import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
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
            isDarkMode ? CustomValues.lang.lightsOn : CustomValues.lang.lightsOff,
            style: textStyle,
          )
        ],
      ),
    );
  }

  static Widget toggleDesignModeWidget(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.clipboardList : MdiIcons.clipboardListOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(CustomValues.lang.changeAppearance, style: textStyle,)
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
            CustomValues.lang.changeLogin,
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
          Text(CustomValues.lang.selectClass, style: textStyle,)
        ],
      ),
    );
  }

  static Widget appInfoWidget(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(isDarkMode ? MdiIcons.folderInformation : MdiIcons.folderInformationOutline,
              size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(CustomValues.lang.settingsAppInfo, style: textStyle,)
        ],
      ),
    );
  }

  static Widget lockOnSystemTheme(bool isDarkMode, TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(MdiIcons.brightness6, size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(Prefs.useSystemTheme ? CustomValues.lang.lightsNoSystem : CustomValues.lang.lightsUseSystem, style: textStyle, textAlign: TextAlign.center)
        ],
      ),
    );
  }

  static Widget setLanguageWidget(TextStyle textStyle) {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(24)),
          Icon(MdiIcons.translate, size: 50, color: AmpColors.colorForeground),
          Padding(padding: EdgeInsets.all(10)),
          Text(CustomValues.lang.changeLanguage, style: textStyle)
        ],
      ),
    );
  }

  static String gradeFieldValidator(String value) {
    List<String> grades = ['5','6','7','8','9','10','11','12','13',''];
    if(!grades.contains(value.trim().toLowerCase())) return CustomValues.lang.widgetValidatorInvalid;
    return null;
  }

  static String letterFieldValidator(String value) {
    List<String> letters = ['a','b','c','d','e','f','g','h','i','q',''];
    if(!letters.contains(value.trim().toLowerCase())) return CustomValues.lang.widgetValidatorInvalid;
    return null;
  }

  static String textFieldValidator(String value) {
    return value.trim().isEmpty ? CustomValues.lang.widgetValidatorFieldEmpty : null;
  }

  static Widget developerOptionsWidget(TextStyle textStyle) {
    if(!Prefs.devOptionsEnabled) return Container();
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
    value = value.trim();
    if (value.isEmpty) return CustomValues.lang.widgetValidatorFieldEmpty;
    final n = num.tryParse(value);
    if (n == null || n < 0) return CustomValues.lang.widgetValidatorInvalid;
    return null;
  }
  
}
