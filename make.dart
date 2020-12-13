import 'dart:io';

final majorMinorVersion = '3.0';

var version;

get flags => '--release --suppress-analytics --dart-define=versionlel=$version';
get binFlags => '$flags --split-debug-info=/tmp --obfuscate';
get iosFlags => binFlags;
//--target-platform android-arm,android-arm64,android-x64
get apkFlags => '$binFlags --shrink';
get aabFlags => apkFlags;
get winFlags => binFlags;
get gtkFlags => binFlags;
get macFlags => binFlags;
get webFlags => '$flags --csp';

final testFlags = '--coverage -j 100 --test-randomize-ordering-seed random';

Future<String> system(cmd) async {
  stderr.writeln(cmd);
  if (Platform.isWindows) {
    return (await Process.run('cmd', ['/c', cmd])).stdout.trimRight();
  } else {
    return (await Process.run('sh', ['-c', cmd])).stdout.trimRight();
  }
}

Future<String> readfile(path) async => File(path).readAsString();
Future writefile(path, content) async => File(path).writeAsString(content);

Future rm(f) async {
  if (await File(f).exists()) {
    await File(f).delete();
  }
}

Future rmd(d) async {
  if (await Directory(d).exists()) {
    await Directory(d).delete(recursive: true);
  }
}

Future mv(from, to) => File(from).rename(to);
Future mvd(from, to) => Directory(from).rename(to);

Future mkdirs(d) => Directory(d).create(recursive: true);

Future md5(path) => system("md5sum '$path' | cut -d' ' -f1");

Future flutter(cmd) => system('flutter $cmd');
Future hdiutil(cmd) => system('hdiutil $cmd');
Future strip(files) => system('strip -u -r $files');

String sed(input, String regex, replacement) {
  return input.toString().replaceAll(RegExp(regex), replacement.toString());
}

Future sedit(input, output, {deb = '/dev/null', buildDir = '/dev/null'}) async {
  var s = await readfile(input);
  s = sed(s, '0.0.0-1', version);
  s = sed(s, '\$ISIZE', (await Directory(buildDir).stat()).size);
  s = sed(s, '\$SIZE', (await File(deb).stat()).size);
  s = sed(s, '\$MD5', await md5(deb));
  s = sed(s, '\$ARCH', 'iphoneos-arm');
  await writefile(output, s);
}

Future replaceversions() async {
  await mv('pubspec.yaml', 'pubspec.yaml.def');
  await sedit('pubspec.yaml.def', 'pubspec.yaml');
}

Future iosapp(buildDir) async {
  await flutter('build ios $iosFlags');
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  await mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await strip('$buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

Future ipa(buildDir, output) async {
  print(await flutter('build ipa $iosFlags'));
  print(await system('ls -R'));
  //await system('cp -rp $buildDir tmp/Payload');
  //await rm(output);
  //await system('cd tmp && zip -r -9 ../$output Payload');
}

// http://www.saurik.com/id/7
// but its broken...
Future deb(buildDir, output) async {
  await system('cp -rp $buildDir tmp/deb/Applications/');
  await sedit('control.def', 'tmp/deb/DEBIAN/control', buildDir: buildDir);
  await system('COPYFILE_DISABLE= COPY_EXTENDED_ATTRIBUTES_DISABLE= '
      'dpkg-deb -Sextreme -z9 --build tmp/deb $output');
}

Future cydiainfo(buildDir, output, debFile) async {
  await sedit('Packages.def', '$output/Packages',
      buildDir: buildDir, deb: debFile);
  await system('gzip -9 -c $output/Packages > $output/Packages.gz');
}

Future apk() async {
  await flutter('build apk $apkFlags');
  await mv('build/app/outputs/flutter-apk/app-release.apk', 'bin/$version.apk');
}

Future aab() async {
  await flutter('build appbundle $aabFlags');
  await mv(
      'build/app/outputs/bundle/release/app-release.aab', 'bin/$version.aab');
}

Future test() async {
  await flutter('test $testFlags');
  await system('genhtml -o coverage/html coverage/lcov.info');
  await system('lcov -l coverage/lcov.info');
}

Future ios() async {
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$version.ipa');
  await deb('build/ios/Release-iphoneos/Runner.app', 'bin/$version.deb');
}

Future android() async {
  final a = apk();
  await aab();
  await a;
}

Future web() async {
  await flutter('config --enable-web');
  await flutter('build web $webFlags');
  await mvd('build/web', 'bin/$version.web');
}

Future win() async {
  await flutter('config --enable-windows-desktop');
  await flutter('build windows $winFlags');
  await mvd('build/windows/runner/Release', 'bin/$version.win');
}

Future mac() async {
  await flutter('config --enable-macos-desktop');
  await flutter('build macos $macFlags');
  const build = 'build/macos/Build/Products/Release/Amplessimus.app';
  const contents = '$build/Contents';
  await strip('$contents/Contents/Runner '
      '$contents/Contents/Frameworks/App.framework/Versions/A/App '
      '$contents/Contents/Frameworks/FlutterMacOS.framework/Versions/A/FlutterMacOS '
      '$contents/Contents/Frameworks/shared_preferences_macos.framework/Versions/A/shared_preferences_macos '
      '$contents/Contents/Frameworks/*.dylib');

  await system('cp -rf $build tmp/dmg');
  await system('ln -s /Applications $build/Applications');
  await system(
      'hdiutil create tmp/tmp.dmg -ov -srcfolder tmp/dmg -fs APFS -volname "Install Amplessimus"');
  await system(
      'hdiutil convert tmp/tmp.dmg -ov -format UDBZ -o bin/$version.dmg');
}

Future linux() async {
  await flutter('config --enable-linux-desktop');
  await flutter('build linux $gtkFlags');
  await mvd('build/linux/release/bundle', 'bin/$version.linux');
}

Future ci() async {
  final a = apk();
  //await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$version.ipa');
  await a;
}

Future ver() async {
  print(version);
}

Future clean() async {
  await rmd('tmp');
  await rmd('build');
  await rmd('bin');
}

Future upgrade() async {
  await flutter('config --no-analytics');
  await flutter('channel master');
  await flutter('upgrade');
  await flutter('config --no-analytics');
}

Future main(List<String> argv) async {
  final commits = await system('echo \$((\$(git rev-list @ --count) - 1148))');
  version = '$majorMinorVersion.$commits';
  await upgrade();
  await replaceversions();
  try {
    await mkdirs('bin');
    await mkdirs('tmp/Payload');
    await mkdirs('tmp/deb/DEBIAN');
    await mkdirs('tmp/deb/Applications');
    await mkdirs('tmp/dmg');
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
        'clean': clean,
        'upgrade': upgrade,
      };
      if (!targets.containsKey(target)) throw 'Target $target doesn\'t exist.';
      await targets[target]();
    }
  } catch (e) {
    stderr.writeln(e);
    if (e is Error) stderr.writeln(e.stackTrace);
  } finally {
    await mv('pubspec.yaml.def', 'pubspec.yaml');
    await rmd('tmp');
  }
}
