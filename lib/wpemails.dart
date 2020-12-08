import 'ui/first_login.dart';
import 'prefs.dart' as Prefs;
import 'uilib.dart';
import 'package:flutter/material.dart';
import 'package:html_search/html_search.dart';

Map<String, String> wpemailsave = {};

Future<Null> wpemailUpdate() async {
  if (Prefs.wpeDomain.isNotEmpty) {
    wpemailsave = await wpemails(Prefs.wpeDomain);
  }
}

Future<Map<String, String>> wpemails(String domain) async {
  try {
    if (domain == null) return null;
    final result = <String, String>{};

    var html = htmlParse(await cachedHttpGet(
      Uri.parse('https://$domain/schulfamilie/lehrkraefte/'),
    ));
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
  } catch (e) {
    return {};
  }
}

Widget wpemailWidget() {
  final w = <Widget>[];
  for (final e in wpemailsave.entries) {
    w.add(ListTile(
      title: ampText(e.key),
      subtitle: ampText(e.value),
      onTap: () => ampOpenUrl('mailto:${e.value}'),
    ));
  }
  return ampList(w);
}
