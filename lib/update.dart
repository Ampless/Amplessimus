import 'dart:convert';

class UpdateInfo {
  String version, url;

  UpdateInfo(this.version, this.url);

  static Future<UpdateInfo> getFromGitHub(
    String repo,
    String currentVersion,
    Future<String> Function(Uri) httpGet,
  ) async {
    try {
      var json = jsonDecode(await httpGet(Uri.parse(
        'https://api.github.com/repos/$repo/releases',
      )));
      for (var release in json)
        if (!release['prerelease'])
          return currentVersion != release['tag_name']
              ? UpdateInfo(release['tag_name'], release['html_url'])
              : null;
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }
}
