import 'dart:io';

final majorMinorVersion = '2.999';

var version = 'pls run main';

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
hdiutil(cmd) => system('hdiutil $cmd');
strip(files) => system('strip -u -r $files');

sed(input, regex, replacement) {
  return input.toString().replaceAll(RegExp(regex), replacement.toString());
}

sedit(input, output, {deb = '/dev/null', buildDir = '/dev/null'}) async {
  var s = readfile(input);
  s = sed(s, '0.0.0-1', version);
  s = sed(s, '\$ISIZE', Directory(buildDir).statSync().size);
  s = sed(s, '\$SIZE', File(deb).statSync().size);
  s = sed(s, '\$MD5', await md5(deb));
  s = sed(s, '\$ARCH', 'iphoneos-arm');
  writefile(output, s);
}

replaceversions() async {
  mv('pubspec.yaml', 'pubspec.yaml.def');
  mv('lib/appinfo.dart', 'lib/appinfo.dart.def');
  await sedit('pubspec.yaml.def', 'pubspec.yaml');
  await sedit('lib/appinfo.dart.def', 'lib/appinfo.dart');
}

iosapp(buildDir) async {
  await flutter('build ios $iosFlags');
  await system(
      'xcrun bitcode_strip $buildDir/Frameworks/Flutter.framework/Flutter -r -o tmpfltr');
  mv('tmpfltr', '$buildDir/Frameworks/Flutter.framework/Flutter');
  await system('rm -f $buildDir/Frameworks/libswift*');
  await strip('$buildDir/Runner $buildDir/Frameworks/*.framework/*');
}

ipa(buildDir, output) async {
  await system('cp -rp $buildDir tmp/Payload');
  rm(output);
  await system('cd tmp && zip -r -9 ../$output Payload');
}

// http://www.saurik.com/id/7
// but its broken...
deb(buildDir, output) async {
  await system('cp -rp $buildDir tmp/deb/Applications/');
  await sedit('control.def', 'tmp/deb/DEBIAN/control', buildDir: buildDir);
  await system('COPYFILE_DISABLE= COPY_EXTENDED_ATTRIBUTES_DISABLE= '
      'dpkg-deb -Sextreme -z9 --build tmp/deb $output');
}

cydiainfo(buildDir, output, debFile) async {
  await sedit('Packages.def', '$output/Packages',
      buildDir: buildDir, deb: debFile);
  await system('gzip -9 -c $output/Packages > $output/Packages.gz');
}

apk() async {
  await flutter('build apk $apkFlags');
  mv('build/app/outputs/flutter-apk/app-release.apk', 'bin/$version.apk');
}

aab() async {
  await flutter('build appbundle $aabFlags');
  mv('build/app/outputs/bundle/release/app-release.aab', 'bin/$version.aab');
}

test() async {
  await flutter('test $testFlags');
  await system('genhtml -o coverage/html coverage/lcov.info');
  await system('lcov -l coverage/lcov.info');
}

ios() async {
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$version.ipa');
  await deb('build/ios/Release-iphoneos/Runner.app', 'bin/$version.deb');
}

android() async {
  final a = apk();
  await aab();
  await a;
}

web() async {
  await flutter('config --enable-web');
  await flutter('build web $webFlags');
  mvd('build/web', 'bin/$version.web');
}

win() async {
  await flutter('config --enable-windows-desktop');
  await flutter('build windows $winFlags');
  mvd('build/windows/runner/Release', 'bin/$version.win');
}

mac() async {
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

linux() async {
  await flutter('config --enable-linux-desktop');
  await flutter('build linux $gtkFlags');
  mvd('build/linux/release/bundle', 'bin/$version.linux');
}

ci() async {
  final a = apk();
  await iosapp('build/ios/Release-iphoneos/Runner.app');
  await ipa('build/ios/Release-iphoneos/Runner.app', 'bin/$version.ipa');
  await a;
}

ver() async {
  print(version);
}

clean() async {
  rmd('tmp');
  rmd('build');
  rmd('bin');
}

main(List<String> argv) async {
  version = '$majorMinorVersion.${await system('git rev-list @ --count')}';
  await flutter('channel master');
  await flutter('upgrade');
  await replaceversions();
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
        'clean': clean,
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
