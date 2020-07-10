import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/dsbutil.dart';
import 'package:Amplissimus/langs/language.dart';
import 'package:Amplissimus/main.dart';
import 'package:Amplissimus/uilib.dart';
import 'package:Amplissimus/values.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:Amplissimus/validators.dart';
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
    FirstLoginValues.httpPostReplacement = httpPostReplacement;
    FirstLoginValues.httpGetReplacement = httpGetReplacement;
  }
  FirstLoginScreenPage _page;
  FirstLoginScreenPage get page => _page;
  @override
  Widget build(BuildContext context) {
    AmpColors.isDarkMode = true;
    return WillPopScope(
        child: MaterialApp(
          builder: (context, child) {
            return ScrollConfiguration(behavior: MyBehavior(), child: child);
          },
          title: AmpStrings.appTitle,
          theme: ThemeData(
            canvasColor: AmpColors.materialColorBackground,
            primarySwatch: AmpColors.materialColorBackground,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: _page = FirstLoginScreenPage(
            title: AmpStrings.appTitle,
          ),
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
  FirstLoginScreenPage({this.title});
  final String title;
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
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: ampText(CustomValues.lang.changeLoginPopup, size: 25),
                centerTitle: true,
              ),
              body: Center(
                heightFactor: 1,
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ampText(CustomValues.lang.selectClass, size: 20),
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        ampDropdownButton(
                          value: FirstLoginValues.grades[0],
                          items: FirstLoginValues.grades
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: ampText(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              gradeDropDownValue = value;
                              if (gradeDropDownValue == CustomValues.lang.empty)
                                Prefs.grade = '';
                              else
                                Prefs.grade = value;
                            });
                          },
                        ),
                        ampPadding(10),
                        ampDropdownButton(
                          value: FirstLoginValues.letters[0],
                          items: FirstLoginValues.letters
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: ampText(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              letterDropDownValue = value;
                              if (letterDropDownValue ==
                                  CustomValues.lang.empty)
                                Prefs.char = '';
                              else
                                Prefs.char = value;
                            });
                          },
                        ),
                      ]),
                      Divider(color: AmpColors.colorForeground, height: 20),
                      Padding(padding: EdgeInsets.all(4)),
                      ampFormField(
                        controller:
                            FirstLoginValues.usernameInputFormController,
                        key: FirstLoginValues.usernameInputFormKey,
                        validator: textFieldValidator,
                        labelText: CustomValues.lang.username,
                        keyboardType: TextInputType.visiblePassword,
                        autofillHints: [AutofillHints.username],
                      ),
                      Padding(padding: EdgeInsets.all(6)),
                      ampFormField(
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => passwordHidden = !passwordHidden),
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
                      ampPadding(10),
                      Divider(color: Colors.transparent, height: 30),
                      AnimatedDefaultTextStyle(
                        child: ampText(textString),
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: isError ? 20 : 0,
                        ),
                        duration: Duration(milliseconds: 350),
                      ),
                    ],
                  ),
                ),
              ),
              bottomSheet: credentialsAreLoading
                  ? LinearProgressIndicator(
                      backgroundColor: AmpColors.colorBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AmpColors.colorForeground),
                    )
                  : Container(),
              floatingActionButton: _saveButton = FloatingActionButton.extended(
                elevation: 0,
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
                    await dsbGetData(
                        FirstLoginValues.usernameInputFormController.text
                            .trim(),
                        FirstLoginValues.passwordInputFormController.text
                            .trim(),
                        lang: CustomValues.lang,
                        httpPost: FirstLoginValues.testing
                            ? FirstLoginValues.httpPostReplacement
                            : httpPost);
                    isError = true;
                    setState(
                        () => {credentialsAreLoading = false, textString = ''});
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
                highlightElevation: 0,
                backgroundColor: AmpColors.colorBackground,
                splashColor: AmpColors.colorForeground,
                label: ampText(CustomValues.lang.save),
                icon: ampIcon(Icons.save),
              ),
            ),
          ),
          Stack(children: [
            Container(
                child: FlareActor(
                  'assets/anims/get_ready.flr',
                  animation: animString,
                  callback: (name) {
                    setState(() => animString =
                        name.trim().toLowerCase() == 'idle' ? 'idle2' : 'idle');
                  },
                ),
                color: Colors.black),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: ampText(AmpStrings.appTitle, size: 24),
                centerTitle: true,
              ),
              floatingActionButton: _doneButton = FloatingActionButton.extended(
                elevation: 0,
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  Prefs.firstLogin = false;
                  setState(() => dsbWidgetIsLoading = false);
                  await dsbUpdateWidget(
                      callback: () => setState(() {}),
                      httpPost: FirstLoginValues.testing
                          ? FirstLoginValues.httpPostReplacement
                          : httpPost,
                      httpGet: FirstLoginValues.testing
                          ? FirstLoginValues.httpGetReplacement
                          : httpGet);
                  await Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyApp(initialIndex: 0)));
                },
                backgroundColor: AmpColors.colorBackground,
                splashColor: AmpColors.colorForeground,
                label: ampText(CustomValues.lang.firstStartupDone),
                icon: ampIcon(MdiIcons.arrowRight),
              ),
              bottomSheet: dsbWidgetIsLoading
                  ? LinearProgressIndicator(
                      backgroundColor: AmpColors.colorBackground,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AmpColors.colorForeground),
                    )
                  : Container(height: 0),
            ),
          ]),
        ]));
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
      void Function(String, String, Duration) setCache}) httpPostReplacement;
  static Future<String> Function(Uri url,
      {String Function(String) getCache,
      void Function(String, String, Duration) setCache}) httpGetReplacement;
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
