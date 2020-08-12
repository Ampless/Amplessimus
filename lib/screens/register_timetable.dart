import 'package:Amplessimus/day.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterTimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  Day currentDropdownDay = Day.Monday;
  TTColumn ttColumn;
  int currentDropdownHour = StaticState.ttHours[5];
  TTLesson selectedTTLesson;
  int curTTColumnIndex;
  bool tempCurrentTTLessonIsFree = false;

  void updateTTColumn(int newLength, Day day) {
    var index = Day.values.indexOf(currentDropdownDay);
    if (ttColumn.lessons.length <= newLength) {
      for (var i = 0; i < newLength; i++) {
        if (i + 1 > StaticState.ttColumns[index].lessons.length) {
          StaticState.ttColumns[index].lessons.add(TTLesson('', '', '', false));
        }
      }
    } else {
      for (var i = ttColumn.lessons.length; i > newLength; --i) {
        StaticState.ttColumns[index].lessons.removeAt(i - 1);
      }
    }
  }

  @override
  void initState() {
    StaticState.ttColumns = ttLoadFromPrefs();
    if (StaticState.ttColumns.isEmpty)
      for (var day in ttWeek)
        StaticState.ttColumns.add(TTColumn(<TTLesson>[], day));
    curTTColumnIndex = Day.values.indexOf(currentDropdownDay);
    ttColumn = StaticState.ttColumns[curTTColumnIndex];
    currentDropdownHour = ttColumn.lessons.length;
    RegisterTimetableValues.tabController =
        TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ampAppBar(Language.current.setupTimetableTitle),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: RegisterTimetableValues.tabController,
        children: <Widget>[
          Scaffold(
            body: Container(
              margin: EdgeInsets.only(left: 12, right: 12),
              color: Colors.transparent,
              child: ampColumn(
                [
                  Center(
                    child: ampRow(
                      [
                        ampDropdownButton(
                          value: currentDropdownDay,
                          itemToDropdownChild: (i) =>
                              ampText(Language.current.dayToString(i)),
                          items: ttWeek,
                          onChanged: (value) {
                            setState(() {
                              currentDropdownDay = value;
                              ttColumn = StaticState.ttColumns[
                                  Day.values.indexOf(currentDropdownDay)];
                              currentDropdownHour = ttColumn.lessons.length;
                            });
                          },
                        ),
                        ampPadding(10),
                        ampDropdownButton(
                          value: currentDropdownHour,
                          items: StaticState.ttHours,
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
                        titleString = Language.current.freeLesson;
                        trailingString = '';
                      } else {
                        titleString = ttColumn.lessons[index].subject;
                        trailingString = ttColumn.lessons[index].teacher;
                      }
                      return ListTile(
                        leading: ampText(
                          (index + 1).toString(),
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
                            title: Language.current.editHour,
                            children: (context, setAlState) => [
                              ampPadding(3),
                              ampFormField(
                                controller: subjectInputFormController,
                                key: subjectInputFormKey,
                                labelText: Language.current.subject,
                              ),
                              ampPadding(6),
                              ampFormField(
                                controller: notesInputFormController,
                                key: notesInputFormKey,
                                labelText: Language.current.notes,
                              ),
                              ampPadding(6),
                              ampFormField(
                                controller: teacherInputFormController,
                                key: teacherInputFormKey,
                                labelText: Language.current.teacher,
                              ),
                              StatefulBuilder(
                                builder: (context, setSwitchState) {
                                  return ampSwitchWithText(
                                    text: Language.current.freeLesson,
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
                              context: context,
                              save: () {
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
                                ttSaveToPrefs(StaticState.ttColumns);
                              },
                            ),
                            context: context,
                            widgetBuilder: ampColumn,
                          );
                        },
                        title: ampText(
                          ttColumn.lessons[index].subject.trim().isEmpty &&
                                  !ttColumn.lessons[index].isFree
                              ? Language.current.subject
                              : titleString.trim(),
                          size: 22,
                        ),
                        subtitle: ampText(
                          ttColumn.lessons[index].notes.trim().isEmpty
                              ? Language.current.notes
                              : ttColumn.lessons[index].notes.trim(),
                          size: 16,
                        ),
                        trailing: ampText(
                          ttColumn.lessons[index].teacher.trim().isEmpty &&
                                  !ttColumn.lessons[index].isFree
                              ? Language.current.teacher
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
                ttSaveToPrefs(StaticState.ttColumns);
                ampEaseOutBack(
                  AmpApp(1),
                  context,
                  push: Navigator.pushReplacement,
                );
              },
              label: Language.current.save,
              icon: Icons.save,
            ),
          ),
          Scaffold(
            floatingActionButton: ampFab(
              onPressed: () {
                RegisterTimetableValues.tabController.animateTo(0);
                ttSaveToPrefs(StaticState.ttColumns);
              },
              label: Language.current.firstStartupDone,
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
