import 'dart:async';

import '../logging.dart';
import '../uilib.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatefulWidget {
  ErrorScreen({Key key}) : super(key: key);
  @override
  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  _ErrorScreenState() {
    Timer.periodic(Duration(seconds: 2), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          ampErrorText(
            'Amplessimus did not initialize correctly.\n'
            'Please contact ampless@chrissx.de with a screenshot/video of this page.',
          ),
          ampLogWidget,
        ]),
      ),
    );
  }
}
