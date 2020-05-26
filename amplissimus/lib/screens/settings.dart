import 'package:amplissimus/animations.dart';
import 'package:amplissimus/main.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:amplissimus/widgets.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
        home: SettingsPage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () {
        Animations.changeScreenNoAnimation(new MyApp(), context);
        return new Future(() => false);
      },
    );
  }
}
class SettingsPage extends StatefulWidget {
  SettingsPage({this.title, this.textStyle});
  TextStyle textStyle;
  final String title;
  @override
  State<StatefulWidget> createState() {return SettingsPageState();}
}
class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmpColors.blankBlack,
      body: Container(
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            Card(
              shape: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
              color: AmpColors.colorBackground,
              child: InkWell(
                customBorder: RoundedRectangleBorder(borderRadius: const BorderRadius.all(Radius.circular(32.0),),),
                onTap: () {
                  
                },
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(24)),
                      Icon(MdiIcons.lightbulbOn, size: 50, color: AmpColors.colorForeground,),
                      Divider(height: 20,),
                      Text('Toogle Dark Mode', style: widget.textStyle,)
                    ],
                  ),
                ),
              ),
            ),
          ],
          ),
      ),
      bottomNavigationBar: Widgets.bottomNavMenu(index: 1, onTapFunction: onNavBarTap),
    );
  }

  void onNavBarTap(int index) {
    if(index == 1) return;
    Animations.changeScreenNoAnimation(new MyApp(), context);
  }

}