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
    return ampMatApp(
      RegisterTimetableScreenPage(),
      pop: () async {
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
  static TabController tabController;

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
                              if (ttColumn.lessons.length <= value) {
                                for (var i = 0; i < value; i++)
                                  if (i + 1 > ttColumn.lessons.length)
                                    ttColumn.lessons.add(TTLesson.empty);
                              } else {
                                for (var i = ttColumn.lessons.length;
                                    i > value;
                                    --i) ttColumn.lessons.removeAt(i - 1);
                              }
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
                      var lesson = ttColumn.lessons[index];
                      var lessonIsFree = false;
                      String title;
                      String trailing;
                      if (ttColumn.lessons[index].isFree) {
                        title = Language.current.freeLesson;
                        trailing = '';
                      } else {
                        title = lesson.subject.trim();
                        trailing = lesson.teacher.trim();
                      }
                      return ListTile(
                        leading: ampText(
                          (index + 1).toString(),
                          weight: FontWeight.bold,
                          size: 30,
                        ),
                        onTap: () {
                          lesson = ttColumn.lessons[index];
                          lessonIsFree = lesson.isFree;
                          final subjectInputFormKey =
                              GlobalKey<FormFieldState>();
                          final notesInputFormKey = GlobalKey<FormFieldState>();
                          final teacherInputFormKey =
                              GlobalKey<FormFieldState>();
                          final subjectInputFormController =
                              TextEditingController(text: lesson.subject);
                          final notesInputFormController =
                              TextEditingController(text: lesson.notes);
                          final teacherInputFormController =
                              TextEditingController(text: lesson.teacher);
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
                                    value: lessonIsFree,
                                    onChanged: (value) {
                                      setSwitchState(
                                          () => lessonIsFree = value);
                                    },
                                  );
                                },
                              ),
                            ],
                            actions: (context) => ampDialogButtonsSaveAndCancel(
                              context: context,
                              save: () {
                                setState(() {
                                  lesson.subject =
                                      subjectInputFormController.text.trim();
                                  lesson.notes =
                                      notesInputFormController.text.trim();
                                  lesson.teacher =
                                      teacherInputFormController.text.trim();
                                  lesson.isFree = lessonIsFree;
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
                              : title,
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
                              : trailing,
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
