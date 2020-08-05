import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';

bool _loggingEnabled = true;
void ampDisableLogging() => _loggingEnabled = false;

String _logBuffer = '';
void ampClearLog() => _logBuffer = '';

Widget get ampLogWidget => ampText(_logBuffer, toString: (b) {
      var t = '';
      for (var s in b) t += s + '\n';
      return t;
    });

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
  if (_loggingEnabled) {
    var msg = '$h:$m:$s.$ms [$level][$ctx] $message';
    _logBuffer += msg + '\n';
    print(msg);
  }
}

void ampErr({@required String ctx, @required Object message}) =>
    _log('Error', ctx, message);
void ampWarn({@required String ctx, @required Object message}) =>
    _log('Warn', ctx, message);
void ampInfo({@required String ctx, @required Object message}) =>
    _log('Info', ctx, message);
