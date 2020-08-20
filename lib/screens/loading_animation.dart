import 'dart:async';
import 'dart:math';
import 'dart:ui';

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
    var f = min(window.physicalSize.width, window.physicalSize.height) /
        window.devicePixelRatio;
    //ampInfo('Loading', 'f = $f');
    Timer(Duration(milliseconds: 20),
        () => setState(() => {frame++, frame %= 50}));
    var rotorblyat = Container(
      padding: EdgeInsets.fromLTRB(0.575 * f, 0.01 * f, 0.075 * f, 0.29 * f),
      child: Image.asset('assets/images/logo.png'),
    );
    var rotorblyat2 = Container(
      padding: EdgeInsets.fromLTRB(0.08 * f, 0 * f, 0.57 * f, 0.3 * f),
      child: Image.asset('assets/images/logo.png'),
    );
    var rotorblyat3 = Container(
      padding: EdgeInsets.fromLTRB(0.26 * f, 1.035 * f, 0.285 * f, 0.46 * f),
      child: Image.asset('assets/images/logo.png'),
    );
    var bg = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: EdgeInsets.all(0.04 * f),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(0.33 * f),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          padding: EdgeInsets.all(0.05 * f),
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
          Center(child: bg),
          Center(child: rotorblyat),
          Center(child: rotorblyat2),
          Center(child: rotorblyat3),
        ],
      ),
    );
  }
}
