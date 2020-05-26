import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';

class Widgets {
  static Widget bottomNavMenu({@required int index, @required Function onTapFunction}) {
    return BottomNavigationBar(
      backgroundColor: AmpColors.colorBackground,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text('Start'),
          
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          title: Text('Einstellungen'),
        ),
      ],
      currentIndex: index,
      unselectedItemColor: AmpColors.blankGrey,
      selectedItemColor: AmpColors.colorForeground,
      onTap: onTapFunction,
    );
  }

}