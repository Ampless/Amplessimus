import '../dsbapi.dart';
import '../langs/language.dart';
import '../uilib.dart';
import '../prefs.dart' as Prefs;
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:schttp/schttp.dart';

import 'home_page.dart';

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
    return ampPageBase(
      Scaffold(
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
                  ampErrorText(_error),
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
              final user = _usernameFormField.text.trim();
              final pass = _passwordFormField.text.trim();
              Prefs.username = user;
              Prefs.password = pass;
              final error = await checkCredentials(user, pass, http.post);
              if (error != null) throw Language.current.dsbError(error);

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
                _error = e;
              });
            }
          },
          label: Language.current.save,
          icon: Icons.save_outlined,
        ),
      ),
    );
  }
}

final cachedHttpGet = ScHttpClient(Prefs.getCache, Prefs.setCache).get;
final http = ScHttpClient();
