// this code is based on the pub packages 'uuid', 'html_unescape' and 'connectivity'

import 'dart:math';
import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/dsbhtmlcodes.dart' as htmlcodes;
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

String _x(int i) {
  return i < 16 ? '0' + i.toRadixString(16) : i.toRadixString(16);
}

String v4() {
  var r = List<int>(16);
  var rand = Random();
  for(int i = 0; i < 16; i++)
    r[i] = rand.nextInt(256);
  r[6] = (r[6] & 0x0f) | 0x40;
  r[8] = (r[8] & 0x3f) | 0x80;
  int i = 0;
  return '${_x(r[i++])}${_x(r[i++])}${_x(r[i++])}${_x(r[i++])}-'
         '${_x(r[i++])}${_x(r[i++])}-${_x(r[i++])}${_x(r[i++])}-'
         '${_x(r[i++])}${_x(r[i++])}-${_x(r[i++])}${_x(r[i++])}'
         '${_x(r[i++])}${_x(r[i++])}${_x(r[i++])}${_x(r[i++])}';
}

String htmlUnescape(String data) {
  if (data.indexOf('&') == -1) return data;
  StringBuffer buf = new StringBuffer();
  int offset = 0;
  while (true) {
    int nextAmp = data.indexOf('&', offset);
    if (nextAmp == -1) {
      buf.write(data.substring(offset));
      break;
    }
    buf.write(data.substring(offset, nextAmp));
    offset = nextAmp;
    var chunk = data.substring(offset, min(data.length, offset + 18));
    if (chunk.length > 4 && chunk.codeUnitAt(1) == 35) {
      int nextSemicolon = chunk.indexOf(';');
      if (nextSemicolon != -1) {
        var hex = chunk.codeUnitAt(2) == 120;
        var str = chunk.substring(hex ? 3 : 2, nextSemicolon);
        int ord = int.tryParse(str, radix: hex ? 16 : 10);
        if (ord != null) {
          buf.write(new String.fromCharCode(ord));
          offset += nextSemicolon + 1;
          continue;
        }
      }
    }
    var replaced = false;
    for (int i = 0; i < htmlcodes.keys.length; i++) {
      var key = htmlcodes.keys[i];
      if (chunk.startsWith(key)) {
        var replacement = htmlcodes.values[i];
        buf.write(replacement);
        offset += key.length;
        replaced = true;
        break;
      }
    }
    if (!replaced) {
      buf.write('&');
      offset++;
    }
  }
  return buf.toString();
}


http.Client _httpclient = http.Client();

Future<String> httpPost(String url, dynamic body, String id,
                        Map<String, String> headers, {bool useCache = true}) async {
  if(useCache) {
    String cachedResp = Prefs.getCache('$url\t$id');
    if(cachedResp != null) return cachedResp;
  }
  ampInfo(ctx: 'HTTP', message: 'Posting to "$url" with headers "$headers": $body');
  http.Response res = await _httpclient.post(url, body: body, headers: headers);
  ampInfo(ctx: 'HTTP', message: 'Got POST-Response.');
  if(res.statusCode == 200) Prefs.setCache('$url\t$id', res.body, ttl: Duration(minutes: 15));
  return res.body;
}

Future<String> httpGet(String url, {bool useCache = true}) async {
  if(useCache) {
    String cachedResp = Prefs.getCache(url);
    if(cachedResp != null) return cachedResp;
  }
  ampInfo(ctx: 'HTTP', message: 'Getting from "$url".');
  http.Response res = await _httpclient.get(url);
  ampInfo(ctx: 'HTTP', message: 'Got GET-Response.');
  if(res.statusCode == 200) Prefs.setCache(url, res.body, ttl: Duration(days: 4));
  return res.body;
}

bool _lastConnectivityCheckFailed = false;
ConnectivityResult _connectivityResult = ConnectivityResult.wifi;

void registerConnectivityHook(var rebuild) =>
  EventChannel('plugins.flutter.io/connectivity_status')
  .receiveBroadcastStream()
  .map((dynamic result) => result.toString())
  .map(parseConnectivityResult).listen((event) {
    if(event != ConnectivityResult.none && _lastConnectivityCheckFailed) {
      _lastConnectivityCheckFailed = false;
      dsbUpdateWidget(rebuild);
    }
    _connectivityResult = event;
  });

void checkConnectivity() async {
  if(_connectivityResult == null)
    _connectivityResult = await methodChannel
      .invokeMethod<String>('check').then(parseConnectivityResult);
  if(_connectivityResult == ConnectivityResult.none) {
    _lastConnectivityCheckFailed = true;
    throw 'Keine Internetverbindung.';
  }
}

MethodChannel methodChannel = MethodChannel('plugins.flutter.io/connectivity');

ConnectivityResult parseConnectivityResult(String state) {
  return state == 'wifi'   ? ConnectivityResult.wifi :
         state == 'mobile' ? ConnectivityResult.cellular :
                             ConnectivityResult.none;
}

enum ConnectivityResult {
  wifi,
  cellular,
  none
}
