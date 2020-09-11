import 'package:Amplessimus/dsbutil.dart';
import 'package:Amplessimus/dsbhtmlcodes.dart' as htmlcodes;

import 'testlib.dart';

void main() {
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
