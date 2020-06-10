import 'package:Amplissimus/logging.dart';
import 'package:flutter/material.dart';

class Animations {
  static void changeScreenNoAnimation(Object object, BuildContext context) {
    ampInfo(ctx: 'ScreenSwitch', message: 'Switching screen without animation within 1ms');
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.ease);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return object;
        },
      )
    );
  }

  static void changeScreenNoAnimationReplace(Object object, BuildContext context) {
    ampInfo(ctx: 'ScreenSwitch', message: 'Switching screen without animation within 1ms');
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 1),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.ease);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return object;
        },
      )
    );
  }

  static void changeScreenEaseOutBack(Object object, BuildContext context) {
    ampInfo(ctx: 'ScreenSwitch', message: 'Switching screen with EaseOutBack animation within 200ms');
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.easeInOutBack);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return object;
        },
      )
    );
  }

  static void changeScreenEaseOutBackReplace(Object object, BuildContext context) {
    ampInfo(ctx: 'ScreenSwitch', message: 'Switching screen with EaseOutBack animation within 200ms');
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          animation = CurvedAnimation(parent: animation, curve: Curves.easeInOutBack);
          return ScaleTransition(
            scale: animation,
            alignment: Alignment.center,
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) {
          return object;
        },
      )
    );
  }
}