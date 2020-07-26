import 'dart:async';

import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';

class AmpLoadingAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AmpLoadingAnimationState();
  }
}

class _AmpLoadingAnimationState extends State<AmpLoadingAnimation> {
  Timer timer;
  double frame = 0;
  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 20),
        () => setState(() => {frame++, frame %= 50}));
    var rotorblyat = Container(
      padding: EdgeInsets.fromLTRB(210, 0, 20, 200),
      child: Image.asset('assets/images/lilrotorblyat.png'),
    );
    var rotorblyat2 = Container(
      padding: EdgeInsets.fromLTRB(20, 0, 210, 200),
      child: Image.asset('assets/images/lilrotorblyat2.png'),
    );
    var rotorblyat3 = Container(
      padding: EdgeInsets.fromLTRB(100, 410, 110, 180),
      child: Image.asset('assets/images/lilrotorblyat3.png'),
    );
    var bg = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(130),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          bg,
          Center(child: rotorblyat),
          Center(child: rotorblyat2),
          Center(child: rotorblyat3),
        ],
      ),
    );
  }
}
