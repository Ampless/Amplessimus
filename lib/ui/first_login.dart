import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../main.dart';
import '../uilib.dart';
import '../appinfo.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';
import 'package:schttp/schttp.dart';

import 'home_page.dart';

class FirstLogin extends StatefulWidget {
  FirstLogin();
  @override
  _FirstLoginState createState() => _FirstLoginState();
}

class _FirstLoginState extends State<FirstLogin> {
  bool _loading = false;
  String _error = '';
  bool _hide = true;
  final _usernameFormField = AmpFormField.username();
  final _passwordFormField = AmpFormField.password();

  @override
  Widget build(BuildContext context) {
    if (prefs.classLetter.isEmpty) prefs.classLetter = dsb.letters.first;
    if (prefs.classGrade.isEmpty) prefs.classGrade = dsb.grades.first;
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: ListView(
            children: [
              ampTitle(appTitle),
              ampPadding(
                10,
                ampColumn([
                  AutofillGroup(
                    child: ampColumn([
                      _usernameFormField.flutter(),
                      _passwordFormField.flutter(
                        suffixIcon: ampHidePwdBtn(
                            _hide, () => setState(() => _hide = !_hide)),
                        obscureText: _hide,
                      ),
                    ]),
                  ),
                  Divider(),
                  ampWidgetWithText(
                    Language.current.changeLanguage,
                    ampDropdownButton<Language>(
                      value: Language.current,
                      itemToDropdownChild: (i) => ampText(i.name),
                      items: Language.all,
                      onChanged: (v) => setState(() {
                        if (v == null) return;
                        Language.current = v;
                      }),
                    ),
                  ),
                  Divider(),
                  ampWidgetWithText(
                    Language.current.selectClass,
                    ampRow(
                      [
                        ampDropdownButton<String>(
                          value: prefs.classGrade,
                          items: dsb.grades,
                          onChanged: (v) {
                            setState(prefs.setClassGrade(v));
                          },
                        ),
                        ampPadding(8),
                        ampDropdownButton<String>(
                          value: prefs.classLetter,
                          items: dsb.letters,
                          onChanged: (v) => setState(() {
                            if (v == null) return;
                            prefs.classLetter = v;
                          }),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  ampErrorText(_error),
                ]),
              )
            ],
          ),
        ),
        bottomSheet: _loading
            ? LinearProgressIndicator(semanticsLabel: 'Loading')
            : ampNull,
        floatingActionButton: ampFab(
          onPressed: () async {
            setState(() => _loading = true);
            try {
              final token = await getAuthToken(
                prefs.username,
                prefs.password,
                http,
              );
              if (token == null) throw Language.current.dsbError;

              await dsb.updateWidget();

              setState(() {
                _loading = false;
                _error = '';
              });

              prefs.firstLogin = false;
              return ampChangeScreen(AmpHomePage(0), context);
            } catch (e) {
              setState(() {
                _loading = false;
                _error = e.toString();
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

//TODO: move these somewhere else
//TODO: get caching back
//TODO: remove one
final cachedHttp = ScHttpClient();
final http = ScHttpClient();
