import '../dsbapi.dart' as dsb;
import '../langs/language.dart';
import '../main.dart';
import '../uilib.dart';
import '../appinfo.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
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
      child: material.Scaffold(
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
                        suffix: ampHidePwdBtn(
                            _hide, () => setState(() => _hide = !_hide)),
                        obscureText: _hide,
                      ),
                    ]),
                  ),
                  material.Divider(),
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
                  material.Divider(),
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
                  material.Divider(),
                  ampErrorText(_error),
                ]),
              )
            ],
          ),
        ),
        bottomSheet: _loading
            ? material.LinearProgressIndicator(semanticsLabel: 'Loading')
            : ampNull,
        floatingActionButton: ampFab(
          onPressed: () async {
            setState(() => _loading = true);
            try {
              final error = await checkCredentials(
                prefs.username,
                prefs.password,
                http,
              );
              if (error != null) throw Language.current.dsbError(error);

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
        ),
      ),
    );
  }
}

final cachedHttp = ScHttpClient(prefs.getCache, prefs.setCache);
final http = ScHttpClient();
