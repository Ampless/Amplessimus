import 'package:Amplessimus/animations.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/timetable/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/validators.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterTimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AmpColors.isDarkMode = true;
    return WillPopScope(
      child: ampMatApp(
        title: AmpStrings.appTitle,
        home: RegisterTimetableScreenPage(),
      ),
      onWillPop: () async {
        if (RegisterTimetableValues.tabController.index <= 0)
          return false;
        else
          RegisterTimetableValues.tabController
              .animateTo(RegisterTimetableValues.tabController.index - 1);
        return false;
      },
    );
  }
}

class RegisterTimetableScreenPage extends StatefulWidget {
  RegisterTimetableScreenPage();
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
    var index = TTDay.values.indexOf(currentDropdownDay);
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
    CustomValues.ttColumns = ttLoadFromPrefs();
    if (CustomValues.ttColumns.isEmpty) CustomValues.generateNewTTColumns();
    curTTColumnIndex = TTDay.values.indexOf(currentDropdownDay);
    ttColumn = CustomValues.ttColumns[curTTColumnIndex];
    currentDropdownHour = ttColumn.lessons.length;
    RegisterTimetableValues.tabController =
        TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: RegisterTimetableValues.tabController,
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AmpColors.colorBackground,
              title: Container(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ampDropdownButton(
                        value: currentDropdownDay,
                        items:
                            ttWeek.map<DropdownMenuItem<TTDay>>((TTDay value) {
                          return DropdownMenuItem<TTDay>(
                            value: value,
                            child:
                                ampText(CustomValues.lang.ttDayToString(value)),
                          );
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
                      ampPadding(10),
                      ampDropdownButton(
                        value: currentDropdownHour,
                        items: CustomValues.ttHours
                            .map<DropdownMenuItem<int>>((int value) {
                          return DropdownMenuItem<int>(
                              value: value, child: ampText(value.toString()));
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
                        leading: ampText(
                          (index + 1),
                          weight: FontWeight.bold,
                          size: 30,
                        ),
                        onTap: () {
                          selectedTTLesson = ttColumn.lessons[index];
                          tempCurrentTTLessonIsFree = selectedTTLesson.isFree;
                          final subjectInputFormKey =
                              GlobalKey<FormFieldState>();
                          final notesInputFormKey = GlobalKey<FormFieldState>();
                          final teacherInputFormKey =
                              GlobalKey<FormFieldState>();
                          final subjectInputFormController =
                              TextEditingController(
                                  text: selectedTTLesson.subject);
                          final notesInputFormController =
                              TextEditingController(
                                  text: selectedTTLesson.notes);
                          final teacherInputFormController =
                              TextEditingController(
                                  text: selectedTTLesson.teacher);
                          ampDialog(
                            title: CustomValues.lang.editHour,
                            children: (context, setAlState) => [
                              ampPadding(3),
                              ampFormField(
                                controller: subjectInputFormController,
                                key: subjectInputFormKey,
                                validator: textFieldValidator,
                                labelText: CustomValues.lang.subject,
                              ),
                              ampPadding(6),
                              ampFormField(
                                controller: notesInputFormController,
                                key: notesInputFormKey,
                                validator: textFieldValidator,
                                labelText: CustomValues.lang.notes,
                              ),
                              ampPadding(6),
                              ampFormField(
                                controller: teacherInputFormController,
                                key: teacherInputFormKey,
                                validator: textFieldValidator,
                                labelText: CustomValues.lang.teacherInput,
                              ),
                              StatefulBuilder(
                                builder: (context, setSwitchState) {
                                  return ampSwitchWithText(
                                    text: CustomValues.lang.freeLesson,
                                    value: tempCurrentTTLessonIsFree,
                                    onChanged: (value) {
                                      setSwitchState(() =>
                                          tempCurrentTTLessonIsFree = value);
                                    },
                                  );
                                },
                              ),
                            ],
                            actions: (context) => ampDialogButtonsSaveAndCancel(
                              onCancel: () => Navigator.pop(context),
                              onSave: () {
                                setState(() {
                                  selectedTTLesson.subject =
                                      subjectInputFormController.text.trim();
                                  selectedTTLesson.notes =
                                      notesInputFormController.text.trim();
                                  selectedTTLesson.teacher =
                                      teacherInputFormController.text.trim();
                                  selectedTTLesson.isFree =
                                      tempCurrentTTLessonIsFree;
                                });
                                Navigator.pop(context);
                                ttSaveToPrefs(CustomValues.ttColumns);
                              },
                            ),
                            context: context,
                            rowOrColumn: ampColumn,
                          );
                        },
                        title: ampText(
                          ttColumn.lessons[index].subject.trim().isEmpty &&
                                  !ttColumn.lessons[index].isFree
                              ? CustomValues.lang.subject
                              : titleString.trim(),
                          size: 22,
                        ),
                        subtitle: ampText(
                          ttColumn.lessons[index].notes.trim().isEmpty
                              ? CustomValues.lang.notes
                              : ttColumn.lessons[index].notes.trim(),
                          size: 16,
                        ),
                        trailing: ampText(
                          ttColumn.lessons[index].teacher.trim().isEmpty &&
                                  !ttColumn.lessons[index].isFree
                              ? CustomValues.lang.teacher
                              : trailingString.trim(),
                          size: 16,
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => ampDivider,
                  )),
                ],
              ),
            ),
            floatingActionButton: ampFab(
              onPressed: () async {
                await dsbUpdateWidget();
                ttSaveToPrefs(CustomValues.ttColumns);
                Animations.changeScreenEaseOutBackReplace(
                  AmpApp(initialIndex: 1),
                  context,
                );
              },
              label: CustomValues.lang.save,
              icon: Icons.save,
            ),
          ),
          Scaffold(
            floatingActionButton: ampFab(
              onPressed: () {
                RegisterTimetableValues.tabController.animateTo(0);
                ttSaveToPrefs(CustomValues.ttColumns);
              },
              label: CustomValues.lang.firstStartupDone,
              icon: MdiIcons.arrowRight,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterTimetableValues {
  static TabController tabController;
}
