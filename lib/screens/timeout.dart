import 'dart:async';

import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

class Timeout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('Timeout', 'Building Main Page');
      return ampMatApp(
        TimeoutPage(),
        pop: () async => Prefs.closeAppOnBackPress,
      );
    } catch (e) {
      ampErr('Timeout', errorString(e));
      return ampText(errorString(e));
    }
  }
}

class TimeoutPage extends StatefulWidget {
  TimeoutPage({Key key}) : super(key: key);
  @override
  TimeoutPageState createState() => TimeoutPageState();
}

class TimeoutPageState extends State<TimeoutPage> {
  TimeoutPageState() {
    Timer.periodic(Duration(seconds: 5), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(children: [
          Text(
            'Amplessimus did not initialize correctly within 30 seconds.\n'
            'Please contact ampless@chrissx.de with a screenshot/video of this page.',
            style: TextStyle(color: Colors.red),
          ),
          ampLogWidget,
        ]),
      ),
    );
  }
}
