import 'ui/first_login.dart';
import 'prefs.dart' as Prefs;
import 'uilib.dart';
import 'package:flutter/material.dart';
import 'package:html_search/html_search.dart';

Map<String, String> wpemailsave;

Future<Null> wpemailUpdate([String domain]) async {
  domain ??= Prefs.wpeDomain;
  if (domain.isNotEmpty) wpemailsave = await wpemails(domain);
}

Future<Map<String, String>> wpemails(String domain) async {
  try {
    if (domain == null) return null;
    final result = <String, String>{};

    var html = htmlParse(
      await cachedHttpGet(
          Uri.parse('https://$domain/schulfamilie/lehrkraefte/')),
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
  } catch (e) {
    return null;
  }
}

Widget wpemailWidget(Map<String, String> emails) {
  final w = <Widget>[];
  for (final e in emails.entries)
    w.add(ampListTile(
      e.key,
      subtitle: e.value,
      onTap: () => ampOpenUrl('mailto:${e.value}'),
    ));
  return ampList(w);
}
