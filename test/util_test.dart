import 'package:Amplessimus/dsbutil.dart';
import 'package:Amplessimus/dsbhtmlcodes.dart' as htmlcodes;

import 'testlib.dart';

enum HttpMethod {
  GET,
  POST,
}

testCase httpTestCase(String url, HttpMethod method, Object body,
        Map<String, String> headers) =>
    () async {
      var _setCacheCalled = false;
      var _getCacheCalled = false;
      if (method == HttpMethod.GET)
        await httpGet(
          Uri.parse(url),
          setCache: (_, __, ___) => _setCacheCalled = true,
          getCache: (_) {
            _getCacheCalled = true;
            return null;
          },
          flushCache: null,
        );
      else if (method == HttpMethod.POST)
        await httpPost(
          Uri.parse(url),
          body,
          null,
          headers,
          setCache: (_, __, ___) => _setCacheCalled = true,
          getCache: (_) {
            _getCacheCalled = true;
            return null;
          },
          flushCache: null,
        );
      else
        throw 'The test is broken.';
      assert(_setCacheCalled && _getCacheCalled);
    };

testCase getCase(String url) => httpTestCase(url, HttpMethod.GET, null, null);

testCase postCase(String url, Object body, Map<String, String> headers) =>
    httpTestCase(url, HttpMethod.POST, body, headers);

List<testCase> httpTestCases = [
  getCase('https://example.com/'),
  postCase('https://example.com/', 'this is a test', {}),
];

void main() {
  tests(httpTestCases, 'dsbutil http');
  tests([
    () async {
      var keys = '&lulwdisisnocode;&#9773;';
      for (var key in htmlcodes.keys) keys += key + 'kekw ';
      var values = '&lulwdisisnocode;☭';
      for (var value in htmlcodes.values) values += value + 'kekw ';
      assert(htmlUnescape(keys) == values);
    }
  ], 'dsbutil htmlcodes');
}
