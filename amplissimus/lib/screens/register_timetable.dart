import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/screens/dev_options.dart';
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:Amplissimus/uilib.dart';
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
  TTDay currentDropdownDay = TTDay.Monday;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      color: AmpColors.colorBackground,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Container(
            decoration: BoxDecoration(border: Border.all()),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ampDropdownButton(
                    value: currentDropdownDay,
                    items: TTDay.values
                        .map<DropdownMenuItem<TTDay>>((TTDay value) {
                      return DropdownMenuItem<TTDay>(
                          value: value,
                          child: Text(CustomValues.lang.ttDayToString(value)));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => currentDropdownDay = value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Row(children: [], mainAxisSize: MainAxisSize.min),
              ),
            ],
          ),
        ),
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
