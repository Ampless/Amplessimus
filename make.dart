import 'dart:io';

final majorMinorVersion = '3.2';

String version;
String commitNumber;

String get flags => '--release '
    '--suppress-analytics '
    '--build-name=$version '
    '--build-number $commitNumber';
String get binFlags => '$flags --split-debug-info=/tmp --obfuscate';
String get iosFlags => binFlags;
//--target-platform android-arm,android-arm64,android-x64
String get apkFlags => '$binFlags --shrink';
String get aabFlags => apkFlags;
String get winFlags => binFlags;
String get gtkFlags => binFlags;
String get macFlags => binFlags;
String get webFlags => '$flags --csp';

final testFlags = '--coverage -j 100 --test-randomize-ordering-seed random';

Future<String> system(String cmd) async {
  stderr.writeln(cmd);
  final p = Platform.isWindows
      ? await Process.run('cmd', ['/c', cmd])
      : await Process.run('sh', ['-c', cmd]);
  stderr.write(p.stderr);
  stderr.write(p.stdout);
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

Future md5(path) => system("md5sum '$path' | cut -d' ' -f1");

Future<void> flutter(String cmd) => system('flutter $cmd');
Future build(String cmd, String flags) => flutter('build $cmd $flags');

Future hdiutil(String cmd) => system('hdiutil $cmd');
Future strip(String files) => system('strip -u -r $files');

Future<void> iosapp(buildDir) async {
  await build('ios', iosFlags);
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  await mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await strip('$buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

Future<void> ipa(buildDir) async {
  //await flutter('build ipa $iosFlags');
  await system('cp -rp $buildDir tmp/Payload');
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
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app');
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
  const contents = '$bld/Contents';
  await strip('$contents/Contents/Runner '
      '$contents/Contents/Frameworks/App.framework/Versions/A/App '
      '$contents/Contents/Frameworks/FlutterMacOS.framework/Versions/A/FlutterMacOS '
      '$contents/Contents/Frameworks/shared_preferences_macos.framework/Versions/A/shared_preferences_macos '
      '$contents/Contents/Frameworks/*.dylib');

  await system('cp -rf $bld tmp/dmg');
  await system('ln -s /Applications $bld/Applications');
  await hdiutil(
      'create tmp/tmp.dmg -ov -srcfolder tmp/dmg -fs APFS -volname "Install Amplessimus"');
  await hdiutil('convert tmp/tmp.dmg -ov -format UDBZ -o bin/$version.dmg');
}

Future<void> linux() async {
  await flutter('config --enable-linux-desktop');
  await build('linux', gtkFlags);
  await mvd('build/linux/release/bundle', 'bin/$version.linux');
}

Future<void> ci() async {
  await apk();
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app');
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
  commitNumber = await system('echo \$((\$(git rev-list @ --count) - 1148))');
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
  'ci': ci,
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
      await targets[target]();
    }
  } catch (e) {
    stderr.writeln(e);
    if (e is Error) stderr.writeln(e.stackTrace);
  }
  await cleanup();
}
