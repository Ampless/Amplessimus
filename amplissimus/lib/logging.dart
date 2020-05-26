
import 'package:flutter/material.dart';

void ampLog({@required String ctx, @required Object message}) {
  var now = DateTime.now();
  var hour = now.hour;
  var minute = now.minute;
  var second = now.second;
  print('[$hour:$minute:$second - $ctx] $message');
}
