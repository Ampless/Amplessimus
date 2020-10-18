import 'package:Amplessimus/wpemails.dart';

import 'testlib.dart';

main() {
  tests([
    () async {
      print(await wpemails('gympeg.de'));
    }
  ], 'wpemails');
}
