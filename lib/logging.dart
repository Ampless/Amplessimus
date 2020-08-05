import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';

bool _loggingEnabled = true;
void ampDisableLogging() => _loggingEnabled = false;

void ampClearLog() => Prefs.log = '';

Widget get ampLogWidget =>
    ampText(Prefs.log, font: ['Ubuntu Mono', 'SF Mono', 'Consolas', 'Courier']);

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
    Prefs.log += msg + '\n';
    print(msg);
  }
}

void ampErr({@required String ctx, @required Object message}) =>
    _log('Error', ctx, message);
void ampWarn({@required String ctx, @required Object message}) =>
    _log('Warn', ctx, message);
void ampInfo({@required String ctx, @required Object message}) =>
    _log('Info', ctx, message);
