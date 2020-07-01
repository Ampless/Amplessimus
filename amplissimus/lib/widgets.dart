import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Widgets {

  //this is currently unused, possible lists:
  //['5','6','7','8','9','10','11','12','13','']
  //['a','b','c','d','e','f','g','h','i','q','']
  static String Function(String) listValidator(List<String> list) {
    return (value) => list.contains(value.trim().toLowerCase())
        ? null
        : CustomValues.lang.widgetValidatorInvalid;
  }

  static String textFieldValidator(String value) {
    return value.trim().isEmpty
        ? CustomValues.lang.widgetValidatorFieldEmpty
        : null;
  }

  static String numberValidator(String value) {
    value = value.trim();
    if (value.isEmpty) return CustomValues.lang.widgetValidatorFieldEmpty;
    final n = num.tryParse(value);
    if (n == null || n < 0) return CustomValues.lang.widgetValidatorInvalid;
    return null;
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
}
