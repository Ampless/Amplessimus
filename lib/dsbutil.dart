// this code is based on the pub package 'html_unescape'

import 'dart:math';
import 'package:Amplessimus/dsbhtmlcodes.dart' as htmlcodes;
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:schttp/schttp.dart';
import 'dart:async';

var rand = Random();

String htmlUnescape(String data) {
  //this optimization is kind of unnecessary for small strings
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

var _httpClient = ScHttpClient(Prefs.getCache, Prefs.setCache);

Future<String> httpPost(
  Uri url,
  Object body,
  String id,
  Map<String, String> headers,
) =>
    _httpClient.post(url, body, id, headers);

Future<String> httpGet(Uri url) async {
  return htmlUnescape(await _httpClient.get(url))
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
}
