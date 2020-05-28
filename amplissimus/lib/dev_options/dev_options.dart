import 'package:amplissimus/animations.dart';
import 'package:amplissimus/main.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Animations.changeScreenEaseOutBack(MyApp(initialIndex: 1,), context);
        }, 
        label: Text('zurück'),
        icon: Icon(Icons.arrow_back),
      ),
    );
  }

}