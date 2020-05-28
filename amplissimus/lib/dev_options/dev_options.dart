import 'package:amplissimus/animations.dart';
import 'package:amplissimus/main.dart';
import 'package:amplissimus/prefs.dart';
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AmpStrings.appTitle,
      theme: ThemeData(
        primarySwatch: AmpColors.primaryBlack,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: DevOptionsScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
    );
  }
}
class DevOptionsScreenPage extends StatefulWidget {
  DevOptionsScreenPage({this.title, this.textStyle});
  String title;
  TextStyle textStyle;
  @override
  State<StatefulWidget> createState() {return DevOptionsScreenPageState();}
}
class DevOptionsScreenPageState extends State<DevOptionsScreenPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AmpColors.colorBackground,
      appBar: AppBar(
        centerTitle: true,
        title: Text(AmpStrings.appTitle, style: widget.textStyle,),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            RaisedButton.icon(
              color: Colors.red,
              icon: Icon(Icons.delete, color: AmpColors.blankWhite,),
              label: Text('App-Daten löschen', style: TextStyle(color: AmpColors.blankWhite),),
              onPressed: () {
                showDialog(context: context, barrierDismissible: true, builder: (context) {
                  return AlertDialog(
                    title: Text('App-Daten löschen', style: widget.textStyle),
                    content: Text('Löschen der App-Daten bestätigen?'),
                    backgroundColor: AmpColors.colorBackground,
                    actions: <Widget>[
                      FlatButton(
                        textColor: AmpColors.colorForeground,
                        onPressed: () {
                          Navigator.of(context).pop();
                        }, 
                        child: Text('Abbrechen')
                      ),
                      FlatButton(
                        textColor: AmpColors.colorForeground,
                        onPressed: () {
                          Prefs.clear();
                          Navigator.of(context).pop();
                          Animations.changeScreenEaseOutBack(MyApp(initialIndex: 0,), context);
                        }, 
                        child: Text('Bestätigen')
                      ),
                    ],
                  );
                },);
              }
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AmpColors.colorBackground,
        splashColor: AmpColors.colorForeground,
        onPressed: () {
          Animations.changeScreenEaseOutBack(MyApp(initialIndex: 1,), context);
        }, 
        label: Text('zurück', style: TextStyle(color: AmpColors.colorForeground),),
        icon: Icon(Icons.arrow_back, color: AmpColors.colorForeground,),
      ),
    );
  }

}