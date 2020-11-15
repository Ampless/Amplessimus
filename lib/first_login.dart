import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:schttp/schttp.dart';

class FirstLoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ampMatApp(FirstLoginScreenPage());
}

class FirstLoginScreenPage extends StatefulWidget {
  FirstLoginScreenPage();
  @override
  State<StatefulWidget> createState() => FirstLoginScreenPageState();
}

class FirstLoginScreenPageState extends State<FirstLoginScreenPage>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  String _error = '';
  String _gradeDropDownValue = Prefs.grade;
  String _letterDropDownValue = Prefs.char;
  bool _passwordHidden = true;
  final _usernameInputFormController =
      TextEditingController(text: Prefs.username);
  final _passwordInputFormController =
      TextEditingController(text: Prefs.password);
  static final usernameInputFormKey = GlobalKey<FormFieldState>();
  static final passwordInputFormKey = GlobalKey<FormFieldState>();

  @override
  Widget build(BuildContext context) {
    if (Prefs.char.isEmpty) _letterDropDownValue = dsbLetters.first;
    if (Prefs.grade.isEmpty) _gradeDropDownValue = dsbGrades.first;
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
          key: _scaffoldKey,
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
                        value: _gradeDropDownValue,
                        items: dsbGrades,
                        onChanged: (value) {
                          setState(() {
                            _gradeDropDownValue = value;
                            Prefs.grade = value;
                            try {
                              if (int.parse(value) > 10)
                                _letterDropDownValue = Prefs.char = '';
                              // ignore: empty_catches
                            } catch (e) {}
                          });
                        },
                      ),
                      ampPadding(10),
                      ampDropdownButton(
                        value: _letterDropDownValue,
                        items: dsbLetters,
                        onChanged: (value) {
                          setState(() {
                            _letterDropDownValue = value;
                            Prefs.char = value;
                          });
                        },
                      ),
                    ]),
                    ampSizedDivider(20),
                    ampPadding(4),
                    ampFormField(
                      controller: _usernameInputFormController,
                      key: usernameInputFormKey,
                      labelText: Language.current.username,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: [AutofillHints.username],
                    ),
                    ampPadding(6),
                    ampFormField(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _passwordHidden = !_passwordHidden);
                        },
                        icon: _passwordHidden
                            ? ampIcon(Icons.visibility)
                            : ampIcon(Icons.visibility_off),
                      ),
                      controller: _passwordInputFormController,
                      key: passwordInputFormKey,
                      labelText: Language.current.password,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: _passwordHidden,
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
                      _error,
                      color: Colors.red,
                      weight: FontWeight.bold,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomSheet: ampLinearProgressIndicator(_loading),
          floatingActionButton: ampFab(
            onPressed: () async {
              setState(() => _loading = true);
              try {
                final username = _usernameInputFormController.text.trim();
                final password = _passwordInputFormController.text.trim();
                Prefs.username = username;
                Prefs.password = password;
                final error = await dsbCheckCredentials(
                  username,
                  password,
                  httpPostFunc,
                );
                if (error != null)
                  throw Language.current.catchDsbGetData(error);

                await dsbUpdateWidget();

                setState(() {
                  _loading = false;
                  _error = '';
                });

                Prefs.firstLogin = false;
                ampChangeScreen(AmpApp(), context);
              } catch (e) {
                setState(() {
                  _loading = false;
                  _error = errorString(e);
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

bool testing = false;

final http = ScHttpClient(Prefs.getCache, Prefs.setCache);
Future<String> Function(Uri, Object, String, Map<String, String>) httpPostFunc =
    http.post;
Future<String> Function(Uri) httpGetFunc = http.get;

final uncachedHttp = ScHttpClient();
Future<String> Function(Uri, Object, String, Map<String, String>)
    uncachedHttpPostFunc = uncachedHttp.post;
Future<String> Function(Uri) uncachedHttpGetFunc = uncachedHttp.get;
