import 'package:Amplissimus/animations.dart';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/screens/dev_options.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/timetable/timetables.dart';
import 'package:Amplissimus/uilib.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/widgets.dart';
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
  TTColumn ttColumn;
  int currentDropdownHour = CustomValues.ttHours[5];
  TTLesson selectedTTLesson;
  int curTTColumnIndex;

  void updateTTColumn(int newLength, TTDay day) {
    int index = TTDay.values.indexOf(currentDropdownDay);
    for (var i = 0; i < newLength; i++) {
      if (i + 1 > CustomValues.ttColumns[index].lessons.length) {
        CustomValues.ttColumns[index].lessons.add(TTLesson('', '', '', false));
      }
    }
  }

  @override
  void initState() {
    if (CustomValues.ttColumns.isEmpty) CustomValues.generateNewTTColumns();
    curTTColumnIndex = TTDay.values.indexOf(currentDropdownDay);
    ttColumn = CustomValues.ttColumns[curTTColumnIndex];
    currentDropdownHour = ttColumn.lessons.length;
    super.initState();
  }

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
                      setState(() {
                        currentDropdownDay = value;
                        ttColumn = CustomValues.ttColumns[
                            TTDay.values.indexOf(currentDropdownDay)];
                      });
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
                      setState(() {
                        currentDropdownHour = value;
                        updateTTColumn(value, currentDropdownDay);
                      });
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
                itemCount: ttColumn.lessons.length + 1,
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
                      selectedTTLesson = ttColumn.lessons[index];
                      final subjectInputFormKey = GlobalKey<FormFieldState>();
                      final notesInputFormKey = GlobalKey<FormFieldState>();
                      final teacherInputFormKey = GlobalKey<FormFieldState>();
                      final subjectInputFormController =
                          TextEditingController(text: selectedTTLesson.subject);
                      final notesInputFormController =
                          TextEditingController(text: selectedTTLesson.notes);
                      final teacherInputFormController =
                          TextEditingController(text: selectedTTLesson.teacher);
                      showAmpTextDialog(
                        title: CustomValues.lang.editHour,
                        children: (context) => [
                          ampFormField(
                            controller: subjectInputFormController,
                            key: subjectInputFormKey,
                            validator: Widgets.textFieldValidator,
                            labelText: CustomValues.lang.subject,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          ampFormField(
                            controller: notesInputFormController,
                            key: notesInputFormKey,
                            validator: Widgets.textFieldValidator,
                            labelText: CustomValues.lang.notes,
                          ),
                          Padding(padding: EdgeInsets.all(6)),
                          ampFormField(
                            controller: teacherInputFormController,
                            key: teacherInputFormKey,
                            validator: Widgets.textFieldValidator,
                            labelText: CustomValues.lang.teacherInput,
                          ),
                        ],
                        actions: (context) => ampDialogButtonsSaveAndCancel(
                          onCancel: () => Navigator.pop(context),
                          onSave: () {
                            selectedTTLesson.subject =
                                subjectInputFormController.text.trim();
                            selectedTTLesson.notes =
                                notesInputFormController.text.trim();
                            setState(() {});
                            Navigator.pop(context);
                          },
                        ),
                        context: context,
                      );
                    },
                    title: Text(
                      ttColumn.lessons[index].subject.trim().isEmpty
                          ? CustomValues.lang.subject
                          : ttColumn.lessons[index].subject.trim(),
                      style: TextStyle(
                          color: AmpColors.colorForeground, fontSize: 22),
                    ),
                    subtitle: Text(
                      ttColumn.lessons[index].notes.trim().isEmpty
                          ? CustomValues.lang.notes
                          : ttColumn.lessons[index].notes.trim(),
                      style: TextStyle(
                          color: AmpColors.lightForeground, fontSize: 16),
                    ),
                    trailing: Text(
                      ttColumn.lessons[index].teacher.trim().isEmpty
                          ? CustomValues.lang.teacher
                          : ttColumn.lessons[index].teacher.trim(),
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
