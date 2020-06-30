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
  bool tempCurrentTTLessonIsFree = false;

  void updateTTColumn(int newLength, TTDay day) {
    int index = TTDay.values.indexOf(currentDropdownDay);
    if (ttColumn.lessons.length <= newLength) {
      for (var i = 0; i < newLength; i++) {
        if (i + 1 > CustomValues.ttColumns[index].lessons.length) {
          CustomValues.ttColumns[index].lessons
              .add(TTLesson('', '', '', false));
        }
      }
    } else {
      for (var i = ttColumn.lessons.length; i > newLength; --i) {
        CustomValues.ttColumns[index].lessons.removeAt(i - 1);
      }
    }
  }

  @override
  void initState() {
    CustomValues.ttColumns = timetableFromPrefs();
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
                        currentDropdownHour = ttColumn.lessons.length;
                      });
                    },
                    underlineDisabled: true,
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
                    underlineDisabled: true,
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
                  String titleString;
                  String trailingString;
                  if (ttColumn.lessons[index].isFree) {
                    titleString = CustomValues.lang.freeLesson;
                    trailingString = '';
                  } else {
                    titleString = ttColumn.lessons[index].subject;
                    trailingString = ttColumn.lessons[index].teacher;
                  }
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
                      tempCurrentTTLessonIsFree = selectedTTLesson.isFree;
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
                          Padding(padding: EdgeInsets.all(3)),
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
                          StatefulBuilder(
                            builder: (context, setSwitchState) {
                              return ampSwitchWithText(
                                text: CustomValues.lang.freeLesson,
                                value: tempCurrentTTLessonIsFree,
                                onChanged: (value) {
                                  setSwitchState(
                                      () => tempCurrentTTLessonIsFree = value);
                                },
                              );
                            },
                          ),
                        ],
                        actions: (context) => ampDialogButtonsSaveAndCancel(
                          onCancel: () => Navigator.pop(context),
                          onSave: () {
                            selectedTTLesson.subject =
                                subjectInputFormController.text.trim();
                            selectedTTLesson.notes =
                                notesInputFormController.text.trim();
                            selectedTTLesson.teacher =
                                teacherInputFormController.text.trim();
                            selectedTTLesson.isFree = tempCurrentTTLessonIsFree;
                            setState(() {});
                            Navigator.pop(context);
                            saveTimetableToPrefs(CustomValues.ttColumns);
                          },
                        ),
                        context: context,
                      );
                    },
                    title: Text(
                      ttColumn.lessons[index].subject.trim().isEmpty &&
                              !ttColumn.lessons[index].isFree
                          ? CustomValues.lang.subject
                          : titleString.trim(),
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
                      ttColumn.lessons[index].teacher.trim().isEmpty &&
                              !ttColumn.lessons[index].isFree
                          ? CustomValues.lang.teacher
                          : trailingString.trim(),
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
            saveTimetableToPrefs(CustomValues.ttColumns);
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
