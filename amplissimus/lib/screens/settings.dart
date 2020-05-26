import 'package:amplissimus/animations.dart';
import 'package:amplissimus/main.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:amplissimus/widgets.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () {
        Animations.changeScreenNoAnimation(new MyApp(), context);
        return new Future(() => false);
      },
    );
  }
}
class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {return SettingsPageState();}
}
class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmpColors.blankBlack,
      body: Center(),
      bottomNavigationBar: Widgets.bottomNavMenu(index: 1, onTapFunction: onNavBarTap),
    );
  }

  void onNavBarTap(int index) {
    if(index == 1) return;
    Animations.changeScreenNoAnimation(new MyApp(), context);
  }

}