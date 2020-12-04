import 'dart:async';

import 'package:Amplessimus/logging.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';

class ErrorScreenPage extends StatefulWidget {
  ErrorScreenPage({Key key}) : super(key: key);
  @override
  ErrorScreenPageState createState() => ErrorScreenPageState();
}

class ErrorScreenPageState extends State<ErrorScreenPage> {
  ErrorScreenPageState() {
    Timer.periodic(Duration(seconds: 2), (_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          ampErrorText(
            'Amplessimus did not initialize.\n'
            'Please contact ampless@chrissx.de with a screenshot/video of this page.',
          ),
          ampLogWidget,
        ]),
      ),
    );
  }
}
