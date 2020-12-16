import 'dart:io';

import 'package:github/github.dart';

void githubRelease(String version) async{
  final github = GitHub(
    auth: Authentication.withToken(
      (await File('/etc/ampci.token').readAsLines()).first,
    ),
  );
  await github.repositories.createRelease(RepositorySlug('Ampless', 'Amplessimus'), CreateRelease.from(tagName: tagName, name: name, targetCommitish: targetCommitish, isDraft: false, isPrerelease: true));
}
