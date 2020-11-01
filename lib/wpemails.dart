import 'package:Amplessimus/first_login.dart';
import 'package:Amplessimus/uilib.dart';
import 'package:flutter/material.dart';
import 'package:html_search/html_search.dart';
import 'package:url_launcher/url_launcher.dart';

Map<String, String> wpemailsave;

Future<Map<String, String>> wpemails(String domain) async {
  try {
    if (domain == null) return null;
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
  } catch (e) {
    return null;
  }
}

Widget wpemailWidget(Map<String, String> emails) {
  final w = <Widget>[];
  for (final e in emails.entries)
    w.add(ampListTile(e.key, subtitle: e.value, onTap: () async {
      if (await canLaunch('mailto:${e.value}'))
        await launch('mailto:${e.value}');
    }));
  return ampColumn(w);
}
