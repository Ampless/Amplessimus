import 'package:Amplessimus/day.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';
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
        if (RegisterTimetableScreenPageState.tabController.index > 0)
          RegisterTimetableScreenPageState.tabController.animateTo(0);
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

final ttLessons = <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
var ttColumns = <TTColumn>[];

class RegisterTimetableScreenPageState
    extends State<RegisterTimetableScreenPage>
    with SingleTickerProviderStateMixin {
  Day currentDropdownDay = Day.Monday;
  TTColumn get ttColumn => ttColumns[Day.values.indexOf(currentDropdownDay)];
  int currentDropdownHour = 0;
  TTLesson selectedTTLesson;
  int curTTColumnIndex;
  bool tempCurrentTTLessonIsFree = false;
  static TabController tabController;

  void updateTTColumn(int newLength, Day day) {
    if (ttColumn.lessons.length <= newLength) {
      for (var i = 0; i < newLength; i++) {
        if (i + 1 > ttColumn.lessons.length) {
          ttColumn.lessons.add(TTLesson('', '', '', false));
        }
      }
    } else {
      for (var i = ttColumn.lessons.length; i > newLength; --i) {
        ttColumn.lessons.removeAt(i - 1);
      }
    }
  }

  @override
  void initState() {
    ttColumns = ttLoadFromPrefs();
    if (ttColumns.isEmpty)
      for (var day in ttWeek) ttColumns.add(TTColumn(<TTLesson>[], day));
    currentDropdownHour = ttColumn.lessons.length;
    tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ampAppBar(Language.current.setupTimetableTitle),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
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
                              currentDropdownHour = ttColumn.lessons.length;
                            });
                          },
                        ),
                        ampPadding(10),
                        ampDropdownButton(
                          value: currentDropdownHour,
                          items: ttLessons,
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
                        return ampSizedDivider(65);
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
                                ttSaveToPrefs(ttColumns);
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
                ttSaveToPrefs(ttColumns);
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
                tabController.animateTo(0);
                ttSaveToPrefs(ttColumns);
              },
              label: Language.current.done,
              icon: MdiIcons.arrowRight,
            ),
          ),
        ],
      ),
    );
  }
}

class RegisterTimetableValues {}
