import '../dsbapi.dart';
import '../langs/language.dart';
import '../uilib.dart';
import '../prefs.dart' as Prefs;
import '../appinfo.dart';
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
  bool _hide = true;
  final _usernameFormField = AmpFormField.username;
  final _passwordFormField = AmpFormField.password;

  @override
  Widget build(BuildContext context) {
    if (Prefs.classLetter.isEmpty) Prefs.classLetter = dsbLetters.first;
    if (Prefs.classGrade.isEmpty) Prefs.classGrade = dsbGrades.first;
    return ampPageBase(
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: ampAppBar(appTitle),
        body: Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: ListView(
            children: [
              ampSubtitle(Language.current.changeLoginPopup),
              _usernameFormField.flutter(),
              _passwordFormField.flutter(
                suffixIcon:
                    ampHidePwdBtn(_hide, () => setState(() => _hide = !_hide)),
                obscureText: _hide,
              ),
              ampPadding(4),
              ampDivider,
              ampPadding(4),
              ampWidgetWithText(
                Language.current.changeLanguage,
                ampDropdownButton(
                  value: Language.current,
                  itemToDropdownChild: (i) => ampText(i.name),
                  items: Language.all,
                  onChanged: (v) => setState(() => Language.current = v),
                ),
              ),
              ampPadding(4),
              ampDivider,
              ampPadding(4),
              ampWidgetWithText(
                Language.current.selectClass,
                ampRow(
                  [
                    ampDropdownButton(
                      value: Prefs.classGrade,
                      items: dsbGrades,
                      onChanged: (value) {
                        setState(() {
                          Prefs.classGrade = value;
                          try {
                            if (int.parse(value) > 10) {
                              Prefs.classLetter = '';
                            }
                            // ignore: empty_catches
                          } catch (e) {}
                        });
                      },
                    ),
                    ampPadding(10),
                    ampDropdownButton(
                      value: Prefs.classLetter,
                      items: dsbLetters,
                      onChanged: (v) => setState(() => Prefs.classLetter = v),
                    ),
                  ],
                ),
              ),
              ampPadding(4),
              ampDivider,
              ampPadding(4),
              ampErrorText(_error),
            ],
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
              return ampChangeScreen(AmpHomePage(0), context);
            } catch (e) {
              setState(() {
                _loading = false;
                _error = e;
              });
            }
          },
          label: Language.current.save,
          iconDefault: Icons.save,
          iconOutlined: Icons.save_outlined,
        ),
      ),
    );
  }
}

final cachedHttpGet = ScHttpClient(Prefs.getCache, Prefs.setCache).get;
final http = ScHttpClient();
