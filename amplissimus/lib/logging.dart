import 'package:flutter/material.dart';

String formatTime(DateTime time) {
  String s = time.second.toString(),
         m = time.minute.toString(),
         h = time.hour.toString();
  if(s.length == 1) s = '0' + s;
  if(m.length == 1) m = '0' + s;
  if(h.length == 1) h = '0' + h;
  return '$h:$m:$s';
}

void ampErr({@required String ctx, @required Object message}) {
  print('[${formatTime(DateTime.now())}][Error][$ctx] $message');
}

void ampWarn({@required String ctx, @required Object message}) {
  print('[${formatTime(DateTime.now())}][Warning][$ctx] $message');
}

void ampInfo({@required String ctx, @required Object message}) {
  print('[${formatTime(DateTime.now())}][Info][$ctx] $message');
}
