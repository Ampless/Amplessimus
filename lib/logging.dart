import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';

bool _loggingDisabled = false;
void ampDisableLogging() => _loggingDisabled = true;

void ampClearLog() => Prefs.log = '';

Widget get ampLogWidget =>
    ampText(Prefs.log, font: ['Ubuntu Mono', 'SF Mono', 'Consolas', 'Courier']);

void ampLog(String lvl, dynamic ctx, Object message) {
  if (_loggingDisabled) return;
  final now = DateTime.now();
  var s = now.second.toString(),
      m = now.minute.toString(),
      h = now.hour.toString(),
      ms = now.millisecond.toString();
  if (s.length == 1) s = '0' + s;
  if (m.length == 1) m = '0' + m;
  if (h.length == 1) h = '0' + h;
  if (ms.length == 1) ms = '0' + ms;
  if (ms.length == 2) ms = '0' + ms;
  if (!(ctx is List)) ctx = [ctx];
  ctx.insert(0, lvl);
  var context = '';
  var aftercontext = '';
  for (var c in ctx) {
    context += '[$c]';
    aftercontext = ' ';
  }
  ampRawLog('$h:$m:$s.$ms $context$aftercontext$message');
}

void ampRawLog(Object msg) {
  if (_loggingDisabled) return;
  Prefs.log += msg.toString();
  Prefs.log += '\n';
  print(msg);
}

void ampErr(Object ctx, Object msg) => ampLog('Error', ctx, msg);
void ampWarn(Object ctx, Object msg) => ampLog('Warning', ctx, msg);
void ampInfo(Object ctx, Object msg) => ampLog('Info', ctx, msg);
