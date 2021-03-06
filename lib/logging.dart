import 'uilib.dart';
import 'package:flutter/material.dart';

bool _loggingDisabled = false;
void ampDisableLogging() => _loggingDisabled = true;

String _log = '';
void ampClearLog() => _log = '';

Widget get ampLogWidget => ampText(_log,
    font: ['Ubuntu Mono', 'SF Mono', 'Menlo', 'Consolas', 'Courier']);

void ampLog(String lvl, dynamic ctx, Object msg) {
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
  for (final c in ctx) {
    context += '[$c]';
  }
  ampRawLog('$h:$m:$s.$ms $context $msg');
}

void ampRawLog(Object msg) {
  if (_loggingDisabled) return;
  _log += '$msg\n';
  print(msg);
}

String errorString(dynamic e) {
  if (e is Error) return '$e\n${e.stackTrace}';
  return e.toString();
}

void ampErr(Object ctx, Object msg) => ampLog('Error', ctx, errorString(msg));
void ampWarn(Object ctx, Object msg) => ampLog('Warning', ctx, msg);
void ampInfo(Object ctx, Object msg) => ampLog('Info', ctx, msg);
