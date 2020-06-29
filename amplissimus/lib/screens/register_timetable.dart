import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/screens/dev_options.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
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
  int currentDropdownHour = CustomValues.ttHours[5];

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
                  Padding(padding: EdgeInsets.all(10)),
                  ampDropdownButton(
                    value: currentDropdownHour,
                    items: CustomValues.ttHours
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                          value: value, child: Text(value.toString()));
                    }).toList(),
                    onChanged: (value) {
                      setState(() => currentDropdownHour = value);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(left: 12, right: 12),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: AmpColors.colorForeground,
                height: 2,
                thickness: 1,
              ),
              Center(
                child: Row(children: [], mainAxisSize: MainAxisSize.min),
              ),
              Flexible(
                  child: ListView.separated(
                itemCount: currentDropdownHour + 1,
                itemBuilder: (context, index) {
                  if (index == currentDropdownHour)
                    return Divider(
                      color: AmpColors.colorBackground,
                      height: 65,
                    );
                  return ListTile(
                    leading: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AmpColors.colorForeground,
                          fontSize: 30),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: AmpColors.colorBackground,
                            title: Text(
                              CustomValues.lang.editHour,
                              style:
                                  TextStyle(color: AmpColors.colorForeground),
                            ),
                          );
                        },
                      );
                    },
                    title: Text(
                      CustomValues.lang.subject,
                      style: TextStyle(
                          color: AmpColors.colorForeground, fontSize: 22),
                    ),
                    subtitle: Text(
                      CustomValues.lang.notes,
                      style: TextStyle(
                          color: AmpColors.lightForeground, fontSize: 16),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                      color: AmpColors.colorForeground,
                      height: Prefs.subListItemSpace);
                },
              )),
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
