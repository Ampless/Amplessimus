import 'package:flutter/material.dart';

void _log(String level, String ctx, Object message) {
  DateTime time = DateTime.now();
  String s = time.second.toString(),
         m = time.minute.toString(),
         h = time.hour.toString(),
         ms = time.millisecond.toString();
  if(s.length == 1) s = '0' + s;
  if(m.length == 1) m = '0' + s;
  if(h.length == 1) h = '0' + h;
  if(ms.length == 1) ms = '0' + ms;
  if(ms.length == 2) ms = '0' + ms;
  print('$h:$m:$s.$ms [$level][$ctx] $message');
}

void ampErr({@required String ctx, @required Object message}) => _log('Error', ctx, message);
void ampWarn({@required String ctx, @required Object message}) => _log('Warn', ctx, message);
void ampInfo({@required String ctx, @required Object message}) => _log('Info', ctx, message);
