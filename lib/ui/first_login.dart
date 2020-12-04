import 'package:Amplessimus/colors.dart' as AmpColors;
import 'package:Amplessimus/dsbapi.dart';
import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/main.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:schttp/schttp.dart';

class FirstLogin extends StatefulWidget {
  FirstLogin();
  @override
  State<StatefulWidget> createState() => FirstLoginState();
}

class FirstLoginState extends State<FirstLogin>
    with SingleTickerProviderStateMixin {
  bool _loading = false;
  String _error = '';
  String _gradeDropDownValue = Prefs.grade;
  String _letterDropDownValue = Prefs.char;
  bool _passwordHidden = true;
  final _usernameFormField = AmpFormField(Prefs.username);
  final _passwordFormField = AmpFormField(Prefs.password);

  @override
  Widget build(BuildContext context) {
    if (Prefs.char.isEmpty) _letterDropDownValue = dsbLetters.first;
    if (Prefs.grade.isEmpty) _gradeDropDownValue = dsbGrades.first;
    return Scaffold(
      body: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        color: AmpColors.colorBackground,
        child: Scaffold(
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
                    _usernameFormField.formField(
                      labelText: Language.current.username,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: [AutofillHints.username],
                    ),
                    ampPadding(6),
                    _passwordFormField.formField(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _passwordHidden = !_passwordHidden);
                        },
                        icon: _passwordHidden
                            ? ampIcon(Icons.visibility_outlined)
                            : ampIcon(Icons.visibility_off_outlined),
                      ),
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
                final username = _usernameFormField.text.trim();
                final password = _passwordFormField.text.trim();
                Prefs.username = username;
                Prefs.password = password;
                final error = await checkCredentials(
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
                ampChangeScreen(AmpHomePage(0), context);
              } catch (e) {
                setState(() {
                  _loading = false;
                  _error = errorString(e);
                });
              }
            },
            label: Language.current.save,
            icon: Icons.save_outlined,
          ),
        ),
      ),
    );
  }
}

final _http = ScHttpClient(Prefs.getCache, Prefs.setCache);
final _uncachedHttp = ScHttpClient();

Future<String> Function(Uri, Object, String, Map<String, String>,
    {Duration ttl}) httpPostFunc = _uncachedHttp.post;
Future<String> Function(Uri, {Duration ttl}) httpGetFunc = _http.get;

Future<String> Function(Uri, {Duration ttl}) uncachedHttpGetFunc =
    _uncachedHttp.get;
