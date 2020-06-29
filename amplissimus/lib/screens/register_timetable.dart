import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/screens/dev_options.dart';
import 'package:Amplissimus/values.dart';
import 'package:flutter/material.dart';

class RegisterTimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) =>
          ScrollConfiguration(behavior: MyBehavior(), child: child),
      title: AmpStrings.appTitle,
      theme: ThemeData(
        canvasColor: AmpColors.materialColorBackground,
        primarySwatch: AmpColors.materialColorForeground,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: RegisterTimetableScreenPage(),
    );
  }
}

class RegisterTimetableScreenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegisterTimetableScreenPageState();
}

class RegisterTimetableScreenPageState
    extends State<RegisterTimetableScreenPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          backgroundColor: AmpColors.colorBackground,
          splashColor: AmpColors.colorForeground,
          onPressed: () {
            dsbUpdateWidget(() {});
            Animations.changeScreenEaseOutBackReplace(
                MyApp(initialIndex: 1), context);
          },
          label: Text(
            'zurück',
            style: TextStyle(color: AmpColors.colorForeground),
          ),
          icon: Icon(
            Icons.arrow_back,
            color: AmpColors.colorForeground,
          ),
        ),
      ),
    );
  }
}
