import 'dart:convert';

import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/dsbutil.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/validators.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// ignore: must_be_immutable
class FirstLoginScreen extends StatelessWidget {
  FirstLoginScreen(
      {bool testing = false,
      Future<String> Function(
              Uri url, Object body, String id, Map<String, String> headers,
              {String Function(String) getCache,
              void Function(String, String, Duration) setCache})
          httpPostReplacement,
      Future<String> Function(Uri url,
              {String Function(String) getCache,
              void Function(String, String, Duration) setCache})
          httpGetReplacement}) {
    FirstLoginValues.testing = testing;
    if (testing) {
      FirstLoginValues.httpPostFunc = httpPostReplacement;
      FirstLoginValues.httpGetFunc = httpGetReplacement;
    }
  }
  FirstLoginScreenPage _page;
  FirstLoginScreenPage get page => _page;
  @override
  Widget build(BuildContext context) {
    AmpColors.isDarkMode = true;
    return WillPopScope(
        child: ampMatApp(
          title: AmpStrings.appTitle,
          home: _page = FirstLoginScreenPage(),
        ),
        onWillPop: () async {
          if (FirstLoginValues.tabController.index <= 0)
            return false;
          else
            FirstLoginValues.tabController
                .animateTo(FirstLoginValues.tabController.index - 1);
          return false;
        });
  }
}

// ignore: must_be_immutable
class FirstLoginScreenPage extends StatefulWidget {
  FirstLoginScreenPage();
  FirstLoginScreenPageState _state;
  FirstLoginScreenPageState get state => _state;
  @override
  State<StatefulWidget> createState() => _state = FirstLoginScreenPageState();
}

class FirstLoginScreenPageState extends State<FirstLoginScreenPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool credentialsAreLoading = false;
  bool dsbWidgetIsLoading = false;
  bool isError = false;
  String textString = '';
  String animString = 'intro';
  String gradeDropDownValue = Prefs.grade.trim().toLowerCase();
  String letterDropDownValue = Prefs.char.trim().toLowerCase();
  bool passwordHidden = true;
  Widget _saveButton, _doneButton;
  FloatingActionButton get saveButton => _saveButton;
  FloatingActionButton get doneButton => _doneButton;

  @override
  void initState() {
    FirstLoginValues.tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Prefs.char.trim().isEmpty)
      letterDropDownValue = FirstLoginValues.letters[0];
    if (Prefs.grade.trim().isEmpty)
      gradeDropDownValue = FirstLoginValues.grades[0];
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: FirstLoginValues.tabController,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 150),
            color: AmpColors.colorBackground,
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: Colors.transparent,
              appBar: ampAppBar(CustomValues.lang.changeLoginPopup),
              body: Center(
                heightFactor: 1,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ampText(CustomValues.lang.selectClass, size: 20),
                        ampRow([
                          ampDropdownButton(
                            value: FirstLoginValues.grades[0],
                            items: FirstLoginValues.grades
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: ampText(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                gradeDropDownValue = value;
                                Prefs.grade = value;
                              });
                            },
                          ),
                          ampPadding(10),
                          ampDropdownButton(
                            value: FirstLoginValues.letters[0],
                            items: FirstLoginValues.letters
                                .map<DropdownMenuItem<String>>((value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: ampText(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                letterDropDownValue = value;
                                Prefs.char = value;
                              });
                            },
                          ),
                        ]),
                        ampSizedDivider(20),
                        ampPadding(4),
                        ampFormField(
                          controller:
                              FirstLoginValues.usernameInputFormController,
                          key: FirstLoginValues.usernameInputFormKey,
                          validator: textFieldValidator,
                          labelText: CustomValues.lang.username,
                          keyboardType: TextInputType.visiblePassword,
                          autofillHints: [AutofillHints.username],
                        ),
                        ampPadding(6),
                        ampFormField(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                passwordHidden = !passwordHidden;
                              });
                            },
                            icon: passwordHidden
                                ? ampIcon(Icons.visibility)
                                : ampIcon(Icons.visibility_off),
                          ),
                          controller:
                              FirstLoginValues.passwordInputFormController,
                          key: FirstLoginValues.passwordInputFormKey,
                          validator: textFieldValidator,
                          labelText: CustomValues.lang.password,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: passwordHidden,
                          autofillHints: [AutofillHints.password],
                        ),
                        ampSizedDivider(20),
                        ampPadding(4),
                        ampText(CustomValues.lang.changeLanguage, size: 20),
                        ampDropdownButton(
                          value: CustomValues.lang,
                          items: Language.all
                              .map<DropdownMenuItem<Language>>((value) {
                            return DropdownMenuItem<Language>(
                                value: value, child: ampText(value.name));
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => CustomValues.lang = value),
                        ),
                        ampSizedDivider(5),
                        ampText(
                          textString,
                          color: Colors.red,
                          weight: FontWeight.bold,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottomSheet: ampLinearProgressIndicator(credentialsAreLoading),
              floatingActionButton: _saveButton = ampFab(
                onPressed: () async {
                  var condA = FirstLoginValues.passwordInputFormKey.currentState
                      .validate();
                  var condB = FirstLoginValues.usernameInputFormKey.currentState
                      .validate();
                  if (!condA || !condB) return;
                  setState(() => credentialsAreLoading = true);
                  try {
                    Prefs.username = FirstLoginValues
                        .usernameInputFormController.text
                        .trim();
                    Prefs.password = FirstLoginValues
                        .passwordInputFormController.text
                        .trim();
                    await Prefs.waitForMutex();
                    Map<String, dynamic> map = jsonDecode(await dsbGetData(
                      Prefs.username,
                      Prefs.password,
                      lang: CustomValues.lang,
                      httpPost: FirstLoginValues.httpPostFunc,
                    ));
                    for (var v in map.values) {
                      if (v.toString().trim() == 'Login fehlgeschlagen')
                        throw CustomValues.lang.catchDsbGetData(v);
                    }
                    setState(() {
                      isError = false;
                      credentialsAreLoading = false;
                      textString = '';
                    });
                    FocusScope.of(context).unfocus();
                    FirstLoginValues.tabController.animateTo(1);
                  } catch (e) {
                    setState(() {
                      credentialsAreLoading = false;
                      textString = errorString(e);
                      isError = true;
                    });
                  }
                },
                label: CustomValues.lang.save,
                icon: Icons.save,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                  child: FlareActor(
                    'assets/anims/get_ready.json',
                    animation: animString,
                    callback: (name) {
                      setState(() => animString =
                          name.trim().toLowerCase() == 'idle'
                              ? 'idle2'
                              : 'idle');
                    },
                  ),
                  color: Colors.black),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: ampAppBar(AmpStrings.appTitle, fontSize: 24),
                floatingActionButton: _doneButton = ampFab(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    Prefs.firstLogin = false;
                    setState(() => dsbWidgetIsLoading = false);
                    await dsbUpdateWidget();
                    await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AmpApp(initialIndex: 0),
                      ),
                    );
                  },
                  label: CustomValues.lang.firstStartupDone,
                  icon: MdiIcons.arrowRight,
                ),
                bottomSheet: ampLinearProgressIndicator(dsbWidgetIsLoading),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FirstLoginValues {
  static final usernameInputFormKey = GlobalKey<FormFieldState>();
  static final passwordInputFormKey = GlobalKey<FormFieldState>();
  static final usernameInputFormController =
      TextEditingController(text: Prefs.username);
  static final passwordInputFormController =
      TextEditingController(text: Prefs.password);
  static TabController tabController;
  static bool testing = false;
  static Future<String> Function(
          Uri url, Object body, String id, Map<String, String> headers,
          {String Function(String) getCache,
          void Function(String, String, Duration) setCache}) httpPostFunc =
      httpPost;
  static Future<String> Function(Uri url,
      {String Function(String) getCache,
      void Function(String, String, Duration) setCache}) httpGetFunc = httpGet;
  static List<Widget> settingsButtons;

  static final List<String> grades = [
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
    '13'
  ];
  static final List<String> letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'q'];
}
