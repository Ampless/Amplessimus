import 'dart:math';
import 'package:Amplessimus/prefs.dart' as Prefs;
import 'package:html_unescape/html_unescape.dart';
import 'package:schttp/schttp.dart';
import 'dart:async';

final rand = Random();
final http = ScHttpClient(Prefs.getCache, Prefs.setCache);
final unescape = HtmlUnescape();

Future<String> httpGet(Uri url) async {
  return unescape
      .convert(await http.get(url))
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
