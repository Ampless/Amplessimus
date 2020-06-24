import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';

void ampLogDebugInit() async {
  _logFileMutex.acquire();
  _logFile = await File('amp.log').open(mode: FileMode.append);
  _logFileMutex.release();
}

RandomAccessFile _logFile;
int _newline = '\n'.codeUnitAt(0);
Mutex _logFileMutex = Mutex();

void _log(String level, String ctx, Object message) {
  DateTime time = DateTime.now();
  String s = time.second.toString(),
         m = time.minute.toString(),
         h = time.hour.toString(),
         ms = time.millisecond.toString();
  if(s.length == 1) s = '0' + s;
  if(m.length == 1) m = '0' + m;
  if(h.length == 1) h = '0' + h;
  if(ms.length == 1) ms = '0' + ms;
  if(ms.length == 2) ms = '0' + ms;
  String msg = '$h:$m:$s.$ms [$level][$ctx] $message';
  print(msg);
  if(_logFile != null) {
    _logFileMutex.acquire();
    _logFile.writeString(msg);
    _logFile.writeByte(_newline);
    _logFileMutex.release();
  }
}

void ampErr({@required String ctx, @required Object message}) => _log('Error', ctx, message);
void ampWarn({@required String ctx, @required Object message}) => _log('Warn', ctx, message);
void ampInfo({@required String ctx, @required Object message}) => _log('Info', ctx, message);
