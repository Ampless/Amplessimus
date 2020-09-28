import 'dart:convert';

import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/dsbutil.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

class FirstLoginScreen extends StatelessWidget {
  FirstLoginScreen({
    bool testing = false,
    Future<String> Function(
            Uri url, Object body, String id, Map<String, String> headers)
        httpPostFunc = httpPost,
    Future<String> Function(Uri url) httpGetFunc = httpGet,
  }) {
    FirstLoginValues.testing = testing;
    FirstLoginValues.httpPostFunc = httpPostFunc;
    FirstLoginValues.httpGetFunc = httpGetFunc;
  }
  @override
  Widget build(BuildContext context) {
    return ampMatApp(FirstLoginScreenPage());
  }
}

class FirstLoginScreenPage extends StatefulWidget {
  FirstLoginScreenPage();
  @override
  State<StatefulWidget> createState() => FirstLoginScreenPageState();
}

final usernameInputFormKey = GlobalKey<FormFieldState>();
final passwordInputFormKey = GlobalKey<FormFieldState>();

class FirstLoginScreenPageState extends State<FirstLoginScreenPage>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool isError = false;
  String textString = '';
  String animString = 'intro';
  String gradeDropDownValue = Prefs.grade;
  String letterDropDownValue = Prefs.char;
  bool passwordHidden = true;
  final usernameInputFormController =
      TextEditingController(text: Prefs.username);
  final passwordInputFormController =
      TextEditingController(text: Prefs.password);

  @override
  Widget build(BuildContext context) {
    if (Prefs.char.isEmpty) letterDropDownValue = dsbLetters.first;
    if (Prefs.grade.isEmpty) gradeDropDownValue = dsbGrades.first;
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: ampAppBar(Language.current.changeLoginPopup),
          body: Center(
            heightFactor: 1,
            child: Container(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ampText(Language.current.selectClass, size: 20),
                    ampRow([
                      ampDropdownButton(
                        value: gradeDropDownValue,
                        items: dsbGrades,
                        onChanged: (value) {
                          setState(() {
                            gradeDropDownValue = value;
                            Prefs.grade = value;
                          });
                        },
                      ),
                      ampPadding(10),
                      ampDropdownButton(
                        value: letterDropDownValue,
                        items: dsbLetters,
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
                      controller: usernameInputFormController,
                      key: usernameInputFormKey,
                      labelText: Language.current.username,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: [AutofillHints.username],
                    ),
                    ampPadding(6),
                    ampFormField(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => passwordHidden = !passwordHidden);
                        },
                        icon: passwordHidden
                            ? ampIcon(Icons.visibility)
                            : ampIcon(Icons.visibility_off),
                      ),
                      controller: passwordInputFormController,
                      key: passwordInputFormKey,
                      labelText: Language.current.password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: passwordHidden,
                      autofillHints: [AutofillHints.password],
                    ),
                    ampSizedDivider(20),
                    ampPadding(4),
                    ampText(Language.current.changeLanguage, size: 20),
                    ampDropdownButton(
                      value: Language.current,
                      itemToDropdownChild: (i) => ampText(i.name),
                      items: Language.all,
                      onChanged: (v) => setState(() => Language.current = v),
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
          bottomSheet: ampLinearProgressIndicator(loading),
          floatingActionButton: ampFab(
            onPressed: () async {
              setState(() => loading = true);
              try {
                var username = usernameInputFormController.text.trim();
                var password = passwordInputFormController.text.trim();
                Prefs.username = username;
                Prefs.password = password;
                //TODO: put this code into dsbuntis
                Map<String, dynamic> map = jsonDecode(await dsbGetData(
                  username,
                  password,
                  FirstLoginValues.httpPostFunc,
                ));
                if (map['Resultcode'] != 0)
                  throw Language.current
                      .catchDsbGetData(map['ResultStatusInfo']);

                await dsbUpdateWidget();

                setState(() {
                  isError = false;
                  loading = false;
                  textString = '';
                });

                Prefs.firstLogin = false;
                FocusScope.of(context).unfocus();
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => AmpApp()),
                );
              } catch (e) {
                setState(() {
                  loading = false;
                  textString = errorString(e);
                  isError = true;
                });
              }
            },
            label: Language.current.save,
            icon: Icons.save,
          ),
        ),
      ),
    );
  }
}

class FirstLoginValues {
  static bool testing = false;
  static Future<String> Function(Uri, Object, String, Map<String, String>)
      httpPostFunc = httpPost;
  static Future<String> Function(Uri) httpGetFunc = httpGet;
}
