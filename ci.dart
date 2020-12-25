import 'dart:io';

import 'package:github/github.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import 'make.dart' as make;

Future<String> system(cmd) async {
  print(cmd);
  final p = Platform.isWindows
      ? await Process.run('cmd', ['/c', cmd])
      : await Process.run('sh', ['-c', cmd]);

  print(p.stderr);
  print(p.stdout);
  return p.stdout.trimRight();
}

Future githubRelease(String commit, String dir) async {
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
    ),
  );
  print('Created release.');
  print('Uploading assets...');
  //TODO: return this and use it for altstore
  await github.repositories.uploadReleaseAssets(
    release,
    await Directory(dir)
        .list()
        .asyncMap((event) async => event is File
            ? CreateReleaseAsset(
                name: basename(event.path),
                contentType: lookupMimeType(event.path),
                assetData: await event.readAsBytes())
            : null)
        .where((event) => event != null)
        .toList(),
  );
  print('Done uploading.');
}

Future updateAltstore() async {
  if (!(await Directory('~/ampless.chrissx.de').exists())) {
    await system(
      'git clone https://github.com/Ampless/ampless.chrissx.de ~/ampless.chrissx.de',
    );
  }
  await system('cd ~/ampless.chrissx.de/altstore ; git pull');
  var versionDate = await system('date -u +%FT%T');
  versionDate += '+00:00';
  final versionDescription = await system("date '+%d.%m.%y %H:%M'");
  await system('cd ~/ampless.chrissx.de/altstore;'
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
  await system('git stash');
  await system('git pull');

  await Directory('bin').create(recursive: true);

  final commit = await system('git rev-parse @');

  await make.init();

  final outputDir = '/usr/local/var/www/amplessimus/${make.version}';
  await Directory(outputDir).create(recursive: true);

  final date = await system('date');
  print('[AmpCI][$date] Running the Dart build system for ${make.version}.');

  await make.ci();
  await make.cleanup();

//TODO: reimplement in dart
  await system('mv -f bin $outputDir');

  final altstore = updateAltstore();
  await githubRelease(commit, outputDir);
  await altstore;
}
