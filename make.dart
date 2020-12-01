import 'dart:io';

final version = '2.9.1337';

var actualVersion = 'pls run main';

final flags = '--release --suppress-analytics';
final binFlags = '$flags --split-debug-info=/tmp --obfuscate';
final iosFlags = binFlags;
//--target-platform android-arm,android-arm64,android-x64
final apkFlags = '$binFlags --shrink';
final aabFlags = apkFlags;
final winFlags = binFlags;
final gtkFlags = binFlags;
final macFlags = binFlags;
final webFlags = '$flags --csp';

final testFlags = '--coverage -j 100 --test-randomize-ordering-seed random';

system(cmd) async {
  stderr.writeln(cmd);
  if (Platform.isWindows) {
    return (await Process.run('cmd', ['/c', cmd])).stdout.trimRight();
  } else {
    return (await Process.run('sh', ['-c', cmd])).stdout.trimRight();
  }
}

readfile(path) => File(path).readAsStringSync();
writefile(path, content) => File(path).writeAsStringSync(content);

rm(f) {
  if (File(f).existsSync()) File(f).deleteSync();
}

rmd(d) {
  if (Directory(d).existsSync()) Directory(d).deleteSync(recursive: true);
}

mv(from, to) => File(from).renameSync(to);
mvd(from, to) => Directory(from).renameSync(to);

cp(from, to) => File(from).copySync(to);

mkdirs(d) => Directory(d).createSync(recursive: true);

md5(path) => system("md5sum $path | awk '{ print \$1 }'");

flutter(cmd) => system('flutter $cmd');

sed(input, regex, replacement) {
  return input.toString().replaceAll(RegExp(regex), replacement.toString());
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
  mv('lib/appinfo.dart', 'lib/appinfo.dart.def');
  sedit('pubspec.yaml.def', 'pubspec.yaml', version: version);
  sedit(
    'lib/appinfo.dart.def',
    'lib/appinfo.dart',
    version: actualVersion,
  );
}

iosapp(buildDir) async {
  await flutter('build ios $iosFlags');
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

//TODO:
deb() async {}

apk() async {
  await flutter('build apk $apkFlags');
  mv('build/app/outputs/apk/release/app-release.apk', 'bin/$actualVersion.apk');
}

aab() async {
  await flutter('build appbundle $aabFlags');
  mv('build/app/outputs/apk/release/app-release.aab', 'bin/$actualVersion.aab');
}

test() async {
  await flutter('test $testFlags');
  await system('genhtml -o coverage/html coverage/lcov.info');
  await system('lcov -l coverage/lcov.info');
}

ios() async {
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$actualVersion.ipa');
  await deb();
}

android() async {
  final a = apk();
  await aab();
  await a;
}

web() async {
  flutter('config --enable-web');
  flutter('build web $webFlags');
  mvd('build/web', 'bin/$actualVersion.web');
}

//TODO:
win() async {}

//TODO:
mac() async {}

//TODO:
linux() async {}

ci() async {
  final a = apk();
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$actualVersion.ipa');
  await a;
}

ver() async {
  print(version);
}

main(List<String> argv) async {
  actualVersion = '$version.${await system('git rev-parse @ | cut -c 1-7')}';
  await flutter('channel master');
  await flutter('upgrade');
  await replaceversions(version, actualVersion);
  try {
    mkdirs('bin');
    mkdirs('tmp/Payload');
    mkdirs('tmp/deb/DEBIAN');
    mkdirs('tmp/deb/Applications');
    mkdirs('tmp/dmg');
    for (final target in argv) {
      const targets = {
        'ci': ci,
        'ios': ios,
        'android': android,
        'test': test,
        'web': web,
        'win': win,
        'mac': mac,
        'linux': linux,
        'ver': ver,
      };
      if (!targets.containsKey(target)) throw 'Target $target doesn\'t exist.';
      await targets[target]();
    }
  } catch (e) {
    stderr.writeln(e);
    if (e is Error) stderr.writeln(e.stackTrace);
  } finally {
    mv('pubspec.yaml.def', 'pubspec.yaml');
    mv('lib/appinfo.dart.def', 'lib/appinfo.dart');
    rmd('tmp');
  }
}
