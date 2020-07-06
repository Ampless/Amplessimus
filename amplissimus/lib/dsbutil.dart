// this code is based on the pub packages 'uuid' and 'html_unescape'

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:Amplissimus/dsbhtmlcodes.dart' as htmlcodes;
import 'package:Amplissimus/logging.dart';
import 'package:Amplissimus/prefs.dart' as Prefs;
import 'package:flutter/material.dart';
import 'dart:async';

String _x(int i) => (i < 16 ? '0' : '') + i.toRadixString(16);

var rand = Random();
int _r(int max) => rand.nextInt(max);
String get _r0 => _x(_r(0x100));
String get _r2 => _r0 + _r0;
String get _r4 => _x(_r(0x10) | 0x40);
String get _r8 => _x(_r(0x40) | 0x80);

Color get rcolor => Color.fromARGB(255, _r(256), _r(256), _r(256));

String v4() => '$_r2$_r2-$_r2-$_r4$_r0-$_r8$_r0-$_r2$_r2$_r2';

String htmlUnescape(String data) {
  if (!data.contains('&')) return data;
  var buf = StringBuffer();
  var offset = 0;
  while (true) {
    var nextAmp = data.indexOf('&', offset);
    if (nextAmp == -1) {
      buf.write(data.substring(offset));
      break;
    }
    buf.write(data.substring(offset, nextAmp));
    offset = nextAmp;
    var chunk = data.substring(offset, min(data.length, offset + 18));
    if (chunk.length > 4 && chunk.codeUnitAt(1) == 35) {
      var nextSemicolon = chunk.indexOf(';');
      if (nextSemicolon != -1) {
        var hex = chunk.codeUnitAt(2) == 120;
        var str = chunk.substring(hex ? 3 : 2, nextSemicolon);
        var ord = int.tryParse(str, radix: hex ? 16 : 10);
        if (ord != null) {
          buf.write(String.fromCharCode(ord));
          offset += nextSemicolon + 1;
          continue;
        }
      }
    }
    var replaced = false;
    for (var i = 0; i < htmlcodes.keys.length; i++) {
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

var _httpClient = HttpClient();

Future<String> httpPost(
    Uri url, Object body, String id, Map<String, String> headers,
    {String Function(String) getCache = Prefs.getCache,
    void Function(String, String, Duration) setCache = Prefs.setCache}) async {
  if (getCache != null) {
    var cachedResp = getCache(id);
    if (cachedResp != null) return cachedResp;
  }
  ampInfo(ctx: 'HTTP][POST', message: '$url $headers: $body');
  var req = await _httpClient.postUrl(url);
  headers.forEach((key, value) => req.headers.add(key, value));
  req.writeln(body);
  var res = await req.close();
  var bytes = await res.toList();
  ampInfo(ctx: 'HTTP][POST', message: 'Done.');
  var actualBytes = <int>[];
  for (var b in bytes) actualBytes.addAll(b);
  var r = utf8.decode(actualBytes);
  if (res.statusCode == 200 && setCache != null)
    setCache(id, r, Duration(minutes: 15));
  return r;
}

Future<String> httpGet(Uri url,
    {String Function(String) getCache = Prefs.getCache,
    void Function(String, String, Duration) setCache = Prefs.setCache}) async {
  if (getCache != null) {
    var cachedResp = getCache('$url');
    if (cachedResp != null) return cachedResp;
  }
  ampInfo(ctx: 'HTTP][GET', message: '$url');
  var req = await _httpClient.getUrl(url);
  await req.flush();
  var res = await req.close();
  var bytes = await res.toList();
  var actualBytes = <int>[];
  for (var b in bytes) actualBytes.addAll(b);
  var r = htmlUnescape(String.fromCharCodes(actualBytes))
      .replaceAll('\n', '')
      .replaceAll('\r', '')
      //just fyi: these regexes only work because there are no more newlines
      .replaceAll(RegExp(r'<h1.*?</h1>'), '')
      .replaceAll(RegExp(r'</?p.*?>'), '')
      .replaceAll(RegExp(r'<th.*?</th>'), '')
      .replaceAll(RegExp(r'<head.*?</head>'), '')
      .replaceAll(RegExp(r'<script.*?</script>'), '')
      .replaceAll(RegExp(r'<style.*?</style>'), '')
      .replaceAll(RegExp(r'</?html.*?>'), '')
      .replaceAll(RegExp(r'</?body.*?>'), '')
      .replaceAll(RegExp(r'</?font.*?>'), '')
      .replaceAll(RegExp(r'</?span.*?>'), '')
      .replaceAll(RegExp(r'</?center.*?>'), '')
      .replaceAll(RegExp(r'</?a.*?>'), '')
      .replaceAll(RegExp(r'<tr.*?>'), '<tr>')
      .replaceAll(RegExp(r'<td.*?>'), '<td>')
      .replaceAll(RegExp(r'<th.*?>'), '<th>')
      .replaceAll(RegExp(r' +'), ' ')
      .replaceAll(RegExp(r'<br />'), '')
      .replaceAll(RegExp(r'<!-- .*? -->'), '');
  ampInfo(ctx: 'HTTP][GET', message: 'Done.');
  if (res.statusCode == 200 && setCache != null)
    setCache('$url', r, Duration(days: 4));
  return r;
}
