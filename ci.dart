import 'dart:io';

import 'package:github/github.dart';
import 'package:path/path.dart';

import 'make.dart' as make;

Future githubRelease(String commit, String dir) async {
  print('Creating release...');
  final github = GitHub(
    auth: Authentication.withToken(
      (await File('/etc/ampci.token').readAsLines()).first,
    ),
  );
  final release = await github.repositories.createRelease(
    RepositorySlug('Ampless', 'Amplessimus'),
    CreateRelease.from(
      tagName: make.version,
      name: make.version,
      targetCommitish: commit,
      isDraft: false,
      isPrerelease: true,
      body:
          'This is an automatic release by the ci.\n\n###### Changelog\n\n\n###### Known Problems\n\n',
    ),
  );
  print('Uploading assets...');
  //TODO: return url to ipa and use it for altstore
  await github.repositories.uploadReleaseAssets(
    release,
    await Directory(dir)
        .list()
        .where((event) => event is File)
        .asyncMap((event) async => CreateReleaseAsset(
            name: basename(event.path),
            contentType: 'application/octet-stream',
            assetData: await (event as File).readAsBytes()))
        .where((event) => event != null)
        .toList(),
  );
  print('Done uploading.');
}

Future updateAltstore() async {
  if (!(await Directory('~/ampless.chrissx.de').exists())) {
    await make.system(
      'git clone https://github.com/Ampless/ampless.chrissx.de ~/ampless.chrissx.de',
    );
  }
  await make.system('cd ~/ampless.chrissx.de/altstore ; git pull');
  var versionDate = await make.system('date -u +%FT%T');
  versionDate += '+00:00';
  final versionDescription = await make.system("date '+%d.%m.%y %H:%M'");
  await make.system('cd ~/ampless.chrissx.de/altstore;'
      'sed -E \'s/^ *"version": ".*",\$/      "version": "${make.version}",/\' alpha.json |'
      'sed -E \'s/^ *"versionDate": ".*",\$/      "versionDate": "$versionDate",/\' |'
      'sed -E \'s/^ *"versionDescription": ".*",\$/      "versionDescription": "$versionDescription",/\' |'
      'sed -E \'s/^ *"downloadURL": ".*",\$/      "downloadURL": "https:\\/\\/github.com\\/Ampless\\/Amplessimus\\/releases\\/download\\/${make.version}\\/${make.version}.ipa",/\' > temp.json;'
      'mv temp.json alpha.json;'
      'git add alpha.json;'
      'git commit -m "automatic ci update to amplessimus ios alpha ${make.version}";'
      'git push');
}

Future main() async {
  await make.system('git stash');
  await make.system('git pull');

  await Directory('bin').create(recursive: true);

  final commit = await make.system('git rev-parse @');

  await make.init();

  final outputDir = '/usr/local/var/www/amplessimus/${make.version}';

  final date = await make.system('date');
  print('[AmpCI][$date] Running the Dart build system for ${make.version}.');

  await make.ci();
  await make.cleanup();

//TODO: reimplement in dart
  await make.system('mv -f bin $outputDir');

  final altstore = updateAltstore();
  await githubRelease(commit, outputDir);
  await altstore;
}
