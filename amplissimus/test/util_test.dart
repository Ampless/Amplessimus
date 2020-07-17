import 'package:Amplessimus/dsbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Amplessimus/dsbhtmlcodes.dart' as htmlcodes;

import 'testlib.dart';

enum HttpMethod {
  GET,
  POST,
}

class HttpTestCase extends TestCase {
  String url;
  HttpMethod method;
  Object body;
  Map<String, String> headers;
  bool _setCacheCalled = false;
  bool _getCacheCalled = false;

  HttpTestCase(this.url, this.method, this.body, this.headers);

  @override
  Future<Null> run() async {
    if (method == HttpMethod.GET)
      await httpGet(Uri.parse(url),
          setCache: (_, __, ___) => _setCacheCalled = true,
          getCache: (_) {
            _getCacheCalled = true;
            return null;
          });
    else if (method == HttpMethod.POST)
      await httpPost(Uri.parse(url), body, null, headers,
          setCache: (_, __, ___) => _setCacheCalled = true,
          getCache: (_) {
            _getCacheCalled = true;
            return null;
          });
    else
      throw 'The test is broken.';
    assert(_setCacheCalled && _getCacheCalled);
  }
}

HttpTestCase getCase(String url) =>
    HttpTestCase(url, HttpMethod.GET, null, null);

HttpTestCase postCase(String url, Object body, Map<String, String> headers) =>
    HttpTestCase(url, HttpMethod.POST, body, headers);

List<HttpTestCase> httpTestCases = [
  getCase('https://example.com/'),
  postCase('https://example.com/', 'this is a test', {}),
];

void main() {
  runTests(httpTestCases, 'dsbutil http');
  runTests([
    GenericTestCase(() async {
      var keys = '&lulwdisisnocode;&#9773;';
      for (var key in htmlcodes.keys) keys += key + 'kekw ';
      var values = '&lulwdisisnocode;☭';
      for (var value in htmlcodes.values) values += value + 'kekw ';
      assert(htmlUnescape(keys) == values);
    })
  ], 'dsbutil htmlcodes');
  runTests([
    GenericTestCase(() async {
      assert(rcolor is Color);
    })
  ], 'dsbutil rcolor');
}
