import 'dart:io';

import 'package:github/github.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

import 'make.dart' as make;

Future<String> system(cmd) async {
  stderr.writeln(cmd);
  var p;
  if (Platform.isWindows) {
    p = await Process.run('cmd', ['/c', cmd]);
  } else {
    p = await Process.run('sh', ['-c', cmd]);
  }
  stderr.write(p.stderr);
  stderr.write(p.stdout);
  return p.stdout.trimRight();
}

Future githubRelease(
  String commit,
  String dir
) async {
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
    await (await Directory(dir).list().asyncMap((event) async => event is File
            ? CreateReleaseAsset(
                name: basename(event.path),
                contentType: lookupMimeType(event.path),
                assetData: await event.readAsBytes())
            : null))
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
  //TODO: actually do it
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

//TODO: mv -f bin $outputDir

  final altstore = updateAltstore();
  await githubRelease(commit, outputDir);
  await altstore;
}
