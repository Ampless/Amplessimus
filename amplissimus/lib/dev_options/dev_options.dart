import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logging.dart';

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class DevOptionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(behavior: MyBehavior(), child: child);
        },
        title: AmpStrings.appTitle,
        theme: ThemeData(
          canvasColor: Prefs.designMode ? AmpColors.primaryBlack : AmpColors.primaryWhite,
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DevOptionsScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () async {
        await dsbUpdateWidget((){});
        DevOptionsValues.tabController.animateTo(0);
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
class DevOptionsScreenPageState extends State<DevOptionsScreenPage> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    DevOptionsValues.tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: DevOptionsValues.tabController, children: [
      MyApp(initialIndex: 2,),
      Scaffold(
        backgroundColor: AmpColors.colorBackground,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Entwickleroptionen', style: TextStyle(fontSize: 20, color: AmpColors.colorForeground),),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          color: AmpColors.colorBackground,
          margin: EdgeInsets.all(16),
          child: Center(
            child: ListView(
              children: <Widget>[
                Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble()+2,),
                ListTile(
                  title: Text('Entwickleroptionen aktiviert', style: widget.textStyle,),
                  trailing: Switch(
                    activeColor: AmpColors.colorForeground,
                    value: Prefs.devOptionsEnabled, 
                    onChanged: (value) => setState(() => Prefs.devOptionsEnabled = value),
                  ),
                ),
                Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble(),),
                ListTile(
                  title: Text('Hilfe für Langeweile aktiviert', style: widget.textStyle,),
                  trailing: Switch(
                    activeColor: AmpColors.colorForeground,
                    value: Prefs.counterEnabled, 
                    onChanged: (value) => setState(() => Prefs.counterEnabled = value),
                  ),
                ),
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
                ListTile(
                  title: Text('JSON Cache benutzen', style: widget.textStyle,),
                  trailing: Switch(
                    activeColor: AmpColors.colorForeground,
                    value: Prefs.useJsonCache, 
                    onChanged: (value) {
                      Prefs.useJsonCache = value;
                      dsbUpdateWidget(() => setState(() {}), cacheJsonPlans: value);
                    },
                  ),
                ),
                Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble(),),
                ListTile(
                  title: Text('Listenelementabstand', style: widget.textStyle,),
                  trailing: Text('${Prefs.subListItemSpace}', style: widget.textStyle,),
                  onTap: () => showInputSubListItemSpacingDialog(context),
                ),
                Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble(),),
                Divider(color: Colors.transparent, height: 10),
                RaisedButton(
                  child: Text('Print Cache'),
                  onPressed: Prefs.listCache
                ),
                RaisedButton(
                  child: Text('Cache leeren'),
                  onPressed: () {
                    Prefs.clearCache();
                  }
                ),
                RaisedButton(
                  child: Text('JSON importieren'),
                  onPressed: () async {
                    Prefs.dsbJsonCache = '['
                      '{"title":"Montag","date":"15.6.2020 Montag","subs": []},'
                      '{"title":"Dienstag","date":"16.6.2020 Dienstag","subs": ['
                      '{"class":"5cd","lessons":[3],"teacher":"Häußler","subject":"Spo","notes": "Mitbetreuung"},'
                      '{"class":"7b","lessons": [5],"teacher":"Rosemann","subject":"E","notes":""},'
                      '{"class":"7b","lessons": [6],"teacher":"---","subject":"E","notes":""},'
                      '{"class":"11q","lessons": [1],"teacher":"Wolf","subject":"1sk1","notes":""}'
                      ']}'
                    ']';
                    dsbUpdateWidget(() => setState(() {}), cacheJsonPlans: Prefs.useJsonCache);
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
                              SystemNavigator.pop();
                            }, 
                            child: Text('Bestätigen'),
                          ),
                        ],
                      );
                    });
                  }
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: AmpColors.colorBackground,
          splashColor: AmpColors.colorForeground,
          onPressed: () {
            DevOptionsValues.tabController.animateTo(0);
            dsbUpdateWidget(() => setState(() {}), cacheJsonPlans: Prefs.useJsonCache);
          }, 
          label: Text('zurück', style: TextStyle(color: AmpColors.colorForeground),),
          icon: Icon(Icons.arrow_back, color: AmpColors.colorForeground,),
        ),
      )
    ]);
  }
  void showInputSubListItemSpacingDialog(BuildContext context) {
    final subListSpacingInputFormKey = GlobalKey<FormFieldState>();
    final subListSpacingInputFormController = TextEditingController(text: Prefs.subListItemSpace.toString());
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Listenelementabstand', style: TextStyle(color: AmpColors.colorForeground),),
          backgroundColor: AmpColors.colorBackground,
          content: TextFormField(
            style: TextStyle(color: AmpColors.colorForeground),
            controller: subListSpacingInputFormController,
            key: subListSpacingInputFormKey,
            validator: Widgets.numberValidator,
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
              labelText: 'Listenelementabstand',
              fillColor: AmpColors.colorForeground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AmpColors.colorForeground)
              )
            ),
          ),
          actions: <Widget>[
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Abbrechen'),
            ),
            FlatButton(
              textColor: AmpColors.colorForeground,
              onPressed: () {
                if(!subListSpacingInputFormKey.currentState.validate()) return;
                Prefs.subListItemSpace = int.tryParse(subListSpacingInputFormController.text.trim());
                setState(() => Prefs.subListItemSpace);
                Navigator.of(context).pop();
              },
              child: Text('Speichern'),
            ),
          ],
        );
      },
    );
  }
}

class DevOptionsValues {
  static TabController tabController;
}