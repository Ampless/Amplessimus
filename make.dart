import 'dart:io';

final version = '2.9.1337';

system(cmd) => Process.run('sh', ['-c', cmd]);
readfile(path) => File(path).readAsStringSync();
writefile(path, content) => File(path).writeAsStringSync(content);

rm(from) => File(from).deleteSync();
rmd(from) => Directory(from).deleteSync();

mv(from, to) => File(from).renameSync(to);
mvd(from, to) => Directory(from).renameSync(to);

cp(from, to) => File(from).copySync(to);

mkdirs(d) => Directory(d).createSync(recursive: true);

md5(path) => system("md5sum $path | awk '{ print \$1 }'");

flutter(cmd) => Process.run('flutter', cmd.split(' '));

sed(input, regex, replacement) {
  return input.replaceAll(RegExp(regex), replacement);
}

sedit(input, output,
    {deb = '/dev/null', buildDir = '/dev/null', version = '0.0.0-1'}) async {
  var s = readfile(input);
  s = sed(s, '0.0.0-1', version);
  s = sed(s, '\$ISIZE', Directory(buildDir).statSync().size);
  s = sed(s, '\$SIZE', File(deb).statSync().size);
  s = sed(s, '\$MD5', await md5(deb));
  s = sed(s, '\$ARCH', 'iphoneos-arm');
  writefile(output, s);
}

replaceversions(version, actualVersion) async {
  mv('pubspec.yaml', 'pubspec.yaml.def');
  mv('lib/stringsisabadname.dart', 'lib/stringsisabadname.dart.def');
  sedit('pubspec.yaml.def', 'pubspec.yaml', version: version);
  sedit(
    'lib/stringsisabadname.dart.def',
    'lib/stringsisabadname.dart',
    version: actualVersion,
  );
}

iosapp(flags, buildDir) async {
  await flutter('build ios $flags');
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await system(
      'strip -u -r $buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

ipa(buildDir, output) async {
  await system('cp -rp $buildDir tmp/Payload');
  rm(output);
  await system('cd tmp && zip -r -9 ../$output Payload');
}

apk(flags, output) async {
  flutter('build apk $flags');
  mv('build/app/outputs/apk/release/app-release.apk', output);
}

ci(
  version,
  actualVersion,
  iosBuildDir,
  iosFlags,
  apkFlags,
) async {
  final a = apk(apkFlags, 'bin/$actualVersion.apk');
  await iosapp(iosFlags, iosBuildDir);
  await ipa(iosBuildDir, 'bin/$actualVersion.ipa');
  await a;
}

main() async {
  try {
    var currentCommit = (await system('git rev-parse @ | cut -c 1-7')).stdout;
    final actualVersion = '$version.$currentCommit';
    await replaceversions(version, actualVersion);
    for (final d in [
      'bin',
      'tmp/Payload',
      'tmp/deb/DEBIAN',
      'tmp/deb/Applications',
      'tmp/dmg',
    ]) mkdirs(d);
    await ci(
      version,
      actualVersion,
      'build/ios/Release-iphoneos/Runner.app',
      '--release --suppress-analytics --split-debug-info=/tmp --obfuscate',
      '--release --suppress-analytics --split-debug-info=/tmp --obfuscate --shrink',
    );
  } catch (e) {
    print(e);
    if (e is Error) print(e.stackTrace);
  } finally {
    rmd('tmp');
    mv('pubspec.yaml.def', 'pubspec.yaml');
    mv('lib/stringsisabadname.dart.def', 'lib/stringsisabadname.dart');
  }
}
