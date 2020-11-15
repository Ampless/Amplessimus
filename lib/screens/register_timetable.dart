import 'package:dsbuntis/dsbuntis.dart';
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/timetables.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:flutter/material.dart';

class RegisterTimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ampMatApp(RegisterTimetableScreenPage());
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
  Day dropdownDay = Day.Monday;
  int dropdownLesson = 0;

  TTColumn get column => ttColumns[Day.values.indexOf(dropdownDay)];
  List<TTLesson> get lessons => column.lessons;

  @override
  void initState() {
    if (ttColumns.isEmpty)
      for (final day in ttWeek) ttColumns.add(TTColumn([], day));
    dropdownLesson = lessons.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ampPageBase(
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ampAppBar(Language.current.setupTimetableTitle),
        body: Container(
          margin: EdgeInsets.only(left: 12, right: 12),
          color: Colors.transparent,
          child: ampColumn(
            [
              Center(
                child: ampRow(
                  [
                    ampDropdownButton(
                      value: dropdownDay,
                      itemToDropdownChild: (i) =>
                          ampText(Language.current.dayToString(i)),
                      items: ttWeek,
                      onChanged: (value) {
                        setState(() {
                          dropdownDay = value;
                          dropdownLesson = lessons.length;
                        });
                      },
                    ),
                    ampPadding(10),
                    ampDropdownButton(
                      value: dropdownLesson,
                      items: ttLessons,
                      onChanged: (value) {
                        setState(() {
                          dropdownLesson = value;
                          if (lessons.length <= value) {
                            for (var i = 0; i < value; i++)
                              if (i + 1 > lessons.length)
                                lessons.add(TTLesson.empty);
                          } else {
                            for (var i = lessons.length; i > value; i--)
                              lessons.removeAt(i - 1);
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
                itemCount: lessons.length + 1,
                itemBuilder: (context, index) {
                  if (index == dropdownLesson) return ampSizedDivider(60);
                  var lesson = lessons[index];
                  var lessonIsFree = false;
                  String title;
                  String trailing;
                  if (lessons[index].isFree) {
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
                      lesson = lessons[index];
                      lessonIsFree = lesson.isFree;
                      final subjectInputFormKey = GlobalKey<FormFieldState>();
                      final notesInputFormKey = GlobalKey<FormFieldState>();
                      final teacherInputFormKey = GlobalKey<FormFieldState>();
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
                                  setSwitchState(() => lessonIsFree = value);
                                },
                              );
                            },
                          ),
                        ],
                        actions: (context) => ampDialogButtonsSaveAndCancel(
                          context,
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
                      lessons[index].subject.trim().isEmpty &&
                              !lessons[index].isFree
                          ? Language.current.subject
                          : title,
                      size: 22,
                    ),
                    subtitle: ampText(
                      lessons[index].notes.trim().isEmpty
                          ? Language.current.notes
                          : lessons[index].notes.trim(),
                      size: 16,
                    ),
                    trailing: ampText(
                      lessons[index].teacher.trim().isEmpty &&
                              !lessons[index].isFree
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
            ampChangeScreen(AmpApp(1), context);
          },
          label: Language.current.save,
          icon: Icons.save,
        ),
      ),
    );
  }
}
