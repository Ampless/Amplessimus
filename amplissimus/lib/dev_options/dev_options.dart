import 'package:amplissimus/animations.dart';
import 'package:amplissimus/main.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:flutter/material.dart';

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        title: AmpStrings.appTitle,
        theme: ThemeData(
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DevOptionsScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () {
        Animations.changeScreenEaseOutBackReplace(MyApp(initialIndex: 1,), context);
        return new Future(() => false);
      }
    );
  }
}
class DevOptionsScreenPage extends StatefulWidget {
  DevOptionsScreenPage({this.title, this.textStyle});
  final String title;
  final TextStyle textStyle;
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
            ListTile(
              title: Text('App schließt bei zurück-Taste', style: widget.textStyle,),
              trailing: Switch(
                activeColor: AmpColors.colorForeground,
                value: Prefs.closeAppOnBackPress, 
                onChanged: (value) => setState(() => Prefs.closeAppOnBackPress = value),
              ),
            ),
            ListTile(
              title: Text('Dauerhafter Ladebalken', style: widget.textStyle,),
              trailing: Switch(
                activeColor: AmpColors.colorForeground,
                value: Prefs.loadingBarEnabled, 
                onChanged: (value) => setState(() => Prefs.loadingBarEnabled = value),
              ),
            ),
            RaisedButton(
              child: Text('App-Informationen'),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Amplissimus',
                  applicationVersion: '1.0.0',
                  applicationIcon: Image.asset('assets/images/logo.png', height: 40,),
                  children: [
                    Text('Amplissimus is an App for easily viewing substitution plans using DSB Mobile.')
                  ]
                );
              }
            ),
            RaisedButton.icon(
              color: Colors.red,
              icon: Icon(Icons.delete, color: AmpColors.blankWhite,),
              label: Text('App-Daten löschen', style: TextStyle(color: AmpColors.blankWhite),),
              onPressed: () {
                showDialog(context: context, barrierDismissible: true, builder: (context) {
                  return AlertDialog(
                    title: Text('App-Daten löschen', style: widget.textStyle),
                    content: Text('Löschen der App-Daten bestätigen?', style: TextStyle(color: AmpColors.colorForeground),),
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
                        child: Text('Bestätigen'),
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