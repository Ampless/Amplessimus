import 'package:Amplessimus/first_login.dart';
import 'package:html_search/html_search.dart';

Future<Map<String, String>> wpemails(String domain) async {
  final result = <String, String>{};
  var html = htmlParse(
    await httpGetFunc(Uri.parse('https://$domain/schulfamilie/lehrkraefte/')),
  );
  html = htmlSearchByClass(html, 'entry-content').children;
  html = htmlSearchAllByPredicate(
      html,
      (e) =>
          e.innerHtml.contains(',') &&
          e.innerHtml.contains('(') &&
          e.innerHtml.contains('.') &&
          !e.innerHtml.contains('<'));
  for (final p in html) {
    final raw = p.innerHtml
        .replaceAll(RegExp('[ ­]'), '')
        .replaceAll(RegExp('&.+?;'), '')
        .split(',');
    final fn = raw[1].split('.').first, ln = raw[0].split('.').last;
    result['$ln $fn.'] = '$fn.$ln@gympeg.de'.toLowerCase();
  }
  return result;
}
