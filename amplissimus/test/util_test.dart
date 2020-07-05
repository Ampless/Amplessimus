import 'package:Amplissimus/dsbutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Amplissimus/dsbhtmlcodes.dart' as htmlcodes;

enum HttpMethod {
  GET,
  POST,
}

class HttpTestCase {
  String url;
  HttpMethod method;
  Object body;
  Map<String, String> headers;

  HttpTestCase(this.url, this.method, this.body, this.headers);
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
    int i = 1;
    for (var testCase in httpTestCases)
      test('http case ${i++}', () {
        if (testCase.method == HttpMethod.GET)
          httpGet(Uri.parse(testCase.url),
              setCache: null, getCache: null, log: false);
        else if (testCase.method == HttpMethod.POST)
          httpPost(
              Uri.parse(testCase.url), testCase.body, null, testCase.headers,
              getCache: null, setCache: null, log: false);
        else
          throw 'The test is broken.';
      });
    test('htmlcodes', () {
      String keys = '&lulwdisisnocode;&#9773;';
      for (String key in htmlcodes.keys) keys += key + 'kekw ';
      String values = '&lulwdisisnocode;☭';
      for (String value in htmlcodes.values) values += value + 'kekw ';
      assert(htmlUnescape(keys) == values);
    });
  });
}
