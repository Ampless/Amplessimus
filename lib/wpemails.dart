import 'package:Amplessimus/first_login.dart';
import 'package:html_search/html_search.dart';

Future<Map<String, String>> wpemails(String domain) async {
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
  for (final p in html) print(p.innerHtml);
}
