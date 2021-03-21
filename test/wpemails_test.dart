import 'package:amplessimus/wpemails.dart';
import 'package:schttp/schttp.dart';

import 'testlib.dart';

void main() async {
  final wpe = await wpemails('gympeg.de', ScHttpClient());
  tests([testAssert(wpe.length > 50)], 'wpemails length');
  tests(
    wpe.values.map(
      (e) => testAssert(RegExp('.+?\\..+?@gympeg\\.de').hasMatch(e)),
    ),
    'wpemails',
  );
}
