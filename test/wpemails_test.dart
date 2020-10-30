import 'package:Amplessimus/wpemails.dart';

import 'testlib.dart';

main() {
  tests([
    () async {
      final emails = await wpemails('gympeg.de');
      for (final e in emails.values)
        if (!RegExp('.+?\\..+?@gympeg\\.de').hasMatch(e))
          throw 'Not a valid email: $e';
    }
  ], 'wpemails');
}
