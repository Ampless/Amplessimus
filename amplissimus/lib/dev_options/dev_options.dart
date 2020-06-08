import 'package:amplissimus/animations.dart';
import 'package:amplissimus/dsbapi.dart';
import 'package:amplissimus/main.dart';
import 'package:amplissimus/prefs.dart' as Prefs;
import 'package:amplissimus/values.dart';
import 'package:amplissimus/widgets.dart';
import 'package:flutter/material.dart';

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
          primarySwatch: AmpColors.primaryBlack,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: DevOptionsScreenPage(title: AmpStrings.appTitle, textStyle: TextStyle(color: AmpColors.colorForeground),),
      ), 
      onWillPop: () async {
        await dsbUpdateWidget((){});
        Animations.changeScreenEaseOutBackReplace(new MyApp(initialIndex: 1,), context);
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
  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(controller: tabController, children: [
      MyApp(initialIndex: 1,),
      Scaffold(
        backgroundColor: AmpColors.colorBackground,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Entwickleroptionen', style: TextStyle(fontSize: 20, color: AmpColors.colorForeground),),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
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
              Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble(),),
              ListTile(
                title: Text('Listenelementabstand', style: widget.textStyle,),
                trailing: Text('${Prefs.subListItemSpace}', style: widget.textStyle,),
                onTap: () {
                  showInputSubListItemSpacingDialog(context);
                },
              ),
              Divider(color: AmpColors.colorForeground, height: Prefs.subListItemSpace.toDouble(),),
              Divider(color: AmpColors.colorBackground, height: 10),
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
            tabController.animateTo(0);
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