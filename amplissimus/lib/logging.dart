
import 'package:flutter/material.dart';

void ampLog({@required String ctx, @required Object message}) {
  var now = DateTime.now();
  print('[${now.hour}:${now.minute}:${now.second}][$ctx] $message');
}

void ampErr({@required String ctx, @required Object message}) {
  ampLog(ctx: 'Error][' + ctx, message: message);
}

void ampWarn({@required String ctx, @required Object message}) {
  ampLog(ctx: 'Warning][' + ctx, message: message);
}

void ampInfo({@required String ctx, @required Object message}) {
  ampLog(ctx: 'Info][' + ctx, message: message);
}
