#!/usr/bin/env dart run

import 'dart:io';

final majorMinorVersion = '3.4';

late String version;
late String buildNumber;

String get flags => '--release '
    '--suppress-analytics '
    '--no-sound-null-safety '
    '--build-name=$version '
    '--build-number $buildNumber';
String get binFlags => flags;
String get iosFlags => binFlags;
//--target-platform android-arm,android-arm64,android-x64
String get apkFlags => '$binFlags --shrink';
String get aabFlags => apkFlags;
String get winFlags => binFlags;
String get gtkFlags => binFlags;
String get macFlags => binFlags;
String get webFlags => '$flags --csp';

final testFlags = '--coverage -j 100 --test-randomize-ordering-seed random';

Future<String> system(
  String cmd, {
  bool throwOnFail = false,
  bool printInput = true,
  bool printOutput = true,
}) async {
  if (printInput) stderr.writeln(cmd);
  final p = Platform.isWindows
      ? await Process.run('cmd', ['/c', cmd])
      : await Process.run('sh', ['-c', cmd]);
  if (printOutput) {
    stderr.write(p.stderr);
    stderr.write(p.stdout);
  }
  if (p.exitCode != 0 && throwOnFail) throw p.exitCode;
  return p.stdout.trimRight();
}

Future<String> readfile(path) async => File(path).readAsString();
Future writefile(path, content) async => File(path).writeAsString(content);

Future<void> rm(f) async {
  if (await File(f).exists()) {
    await File(f).delete();
  }
}

Future<void> rmd(d) async {
  if (await Directory(d).exists()) {
    await Directory(d).delete(recursive: true);
  }
}

Future mv(from, to) => File(from).rename(to);
Future mvd(from, to) => Directory(from).rename(to);

Future mkdirs(d) => Directory(d).create(recursive: true);

Future<String> md5(String path) =>
    system("md5sum '$path' | cut -d' ' -f1", printOutput: false);

Future<void> flutter(String cmd) => system('flutter $cmd', throwOnFail: true);
Future build(String cmd, String flags) => flutter('build $cmd $flags');

Future<void> strip(String files) => system(
      'strip -u -r $files',
      printOutput: false,
    );

Future unsign(String app) => system('codesign --remove-signature \'$app\'');

Future<void> iosapp() async {
  const buildDir = 'build/ios/Release-iphoneos/Runner.app';
  await build('ios', iosFlags);
  await unsign(buildDir);
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  await mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await strip('$buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

Future<void> ipa() async {
  //await flutter('build ipa $iosFlags');
  await system('cp -rp build/ios/Release-iphoneos/Runner.app tmp/Payload');
  await rm('bin/$version.ipa');
  await system('cd tmp && zip -r -9 ../bin/$version.ipa Payload');
}

Future<void> apk() async {
  await build('apk', apkFlags);
  await mv('build/app/outputs/flutter-apk/app-release.apk', 'bin/$version.apk');
}

Future<void> aab() async {
  await build('appbundle', aabFlags);
  await mv(
      'build/app/outputs/bundle/release/app-release.aab', 'bin/$version.aab');
}

Future<void> test() async {
  await flutter('test $testFlags');
  await system('genhtml -o coverage/html coverage/lcov.info');
  await system('lcov -l coverage/lcov.info');
}

Future<void> ios() async {
  await iosapp();
  await ipa();
  //TODO: deb
}

Future<void> android() async {
  await apk();
  await aab();
}

Future<void> web() async {
  await flutter('config --enable-web');
  await build('web', webFlags);
  await mvd('build/web', 'bin/$version.web');
}

Future<void> win() async {
  await flutter('config --enable-windows-desktop');
  await build('windows', winFlags);
  await mvd('build/windows/runner/Release', 'bin/$version.win');
}

Future<void> mac() async {
  await flutter('config --enable-macos-desktop');
  await build('macos', macFlags);
  const bld = 'build/macos/Build/Products/Release/Amplessimus.app';
  await unsign(bld);
  const contents = '$bld/Contents';
  const frameworks = '$contents/Frameworks';
  await system('rm -f $frameworks/libswift*');

  await system('cp -rf $bld tmp/dmg');
  await system('ln -s /Applications tmp/dmg/Applications');
  await system('hdiutil create bin/$version.dmg -ov '
      '-srcfolder tmp/dmg -volname "Amplessimus" '
      '-fs APFS -format ULMO');
}

Future<void> linux() async {
  await flutter('config --enable-linux-desktop');
  await build('linux', gtkFlags);
  await mvd('build/linux/release/bundle', 'bin/$version.linux');
}

Future<void> ver() async {
  print(version);
}

Future<void> clean() async {
  await rmd('tmp');
  await rmd('build');
  await rmd('bin');
}

Future<void> init() async {
  buildNumber = await system(
    'git rev-list @ --count',
    printInput: false,
    printOutput: false,
    throwOnFail: true,
  );
  final commitNumber = await system(
    'echo \$(($buildNumber - 1150))',
    printInput: false,
    printOutput: false,
    throwOnFail: true,
  );
  version = '$majorMinorVersion.$commitNumber';
  await mkdirs('bin');
  await mkdirs('tmp/Payload');
  await mkdirs('tmp/deb/DEBIAN');
  await mkdirs('tmp/deb/Applications');
  await mkdirs('tmp/dmg');
}

Future<void> cleanup() async {
  await rmd('tmp');
  await rmd('build');
}

const targets = {
  'ios': ios,
  'android': android,
  'test': test,
  'web': web,
  'win': win,
  'mac': mac,
  'linux': linux,
  'ver': ver,
  'clean': clean,
};

Future<void> main(List<String> argv) async {
  try {
    await flutter('config --no-analytics');
    await flutter('channel master');
    await flutter('upgrade');
    await flutter('config --no-analytics');
    await init();
    for (final target in argv) {
      if (!targets.containsKey(target)) throw 'Target $target doesn\'t exist.';
      await targets[target]!();
    }
  } catch (e) {
    stderr.writeln(e);
    if (e is Error) stderr.writeln(e.stackTrace);
  }
  await cleanup();
}
