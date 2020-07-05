import 'package:flutter/material.dart';

void _log(String level, String ctx, Object message) {
  var now = DateTime.now(),
      s = now.second.toString(),
      m = now.minute.toString(),
      h = now.hour.toString(),
      ms = now.millisecond.toString();
  if (s.length == 1) s = '0' + s;
  if (m.length == 1) m = '0' + m;
  if (h.length == 1) h = '0' + h;
  if (ms.length == 1) ms = '0' + ms;
  if (ms.length == 2) ms = '0' + ms;
  var msg = '$h:$m:$s.$ms [$level][$ctx] $message';
  print(msg);
}

void ampErr({@required String ctx, @required Object message}) =>
    _log('Error', ctx, message);
void ampWarn({@required String ctx, @required Object message}) =>
    _log('Warn', ctx, message);
void ampInfo({@required String ctx, @required Object message}) =>
    _log('Info', ctx, message);
