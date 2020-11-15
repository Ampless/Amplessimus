import 'dart:async';

import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:Amplessimus/values.dart';
import 'package:dsbuntis/dsbuntis.dart';
import 'package:flutter/material.dart';

class Timeout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    try {
      ampInfo('Timeout', 'Building Main Page');
      return ampMatApp(TimeoutPage());
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
    Timer.periodic(Duration(seconds: 2), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AmpColors.colorBackground,
        body: Column(children: [
          ampText(
            'Amplessimus did not initialize.\n'
            'Please contact ampless@chrissx.de with a screenshot/video of this page.',
            size: 24,
          ),
          ampLogWidget,
        ]),
      ),
    );
  }
}
