import 'package:Amplissimus/dsbutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Amplissimus/dsbhtmlcodes.dart' as htmlcodes;

import 'testlib.dart';

enum HttpMethod {
  GET,
  POST,
}

class HttpTestCase extends AsyncTestCase {
  String url;
  HttpMethod method;
  Object body;
  Map<String, String> headers;

  HttpTestCase(this.url, this.method, this.body, this.headers);

  @override
  Future<Null> run() async {
    if (method == HttpMethod.GET)
      await httpGet(Uri.parse(url),
          setCache: null, getCache: null);
    else if (method == HttpMethod.POST)
      await httpPost(
          Uri.parse(url), body, null, headers,
          getCache: null, setCache: null);
    else
      throw 'The test is broken.';
  }
}

class HtmlCodeTestCase extends SyncTestCase {
  void Function() func;

  HtmlCodeTestCase(this.func);

  @override
  void run() => func();
}

HttpTestCase getCase(String url) =>
    HttpTestCase(url, HttpMethod.GET, null, null);

HttpTestCase postCase(String url, Object body, Map<String, String> headers) =>
    HttpTestCase(url, HttpMethod.POST, body, headers);

List<HttpTestCase> httpTestCases = [
  getCase('https://example.com/'),
];

void main() {
  group('dsbutil', () {
    var i = 1;
    for (var testCase in httpTestCases)
      runAsyncTest('http case ${i++}', testCase);
    runSyncTest('htmlcodes', HtmlCodeTestCase(() {
      var keys = '&lulwdisisnocode;&#9773;';
      for (var key in htmlcodes.keys) keys += key + 'kekw ';
      var values = '&lulwdisisnocode;☭';
      for (var value in htmlcodes.values) values += value + 'kekw ';
      assert(htmlUnescape(keys) == values);
    }));
  });
}
