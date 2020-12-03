import 'package:Amplessimus/langs/language.dart';
import 'package:Amplessimus/logging.dart';

final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);
final _letters = RegExp('[a-zA-Z]');
final _numbers = RegExp('[0-9]');

bool _numAt(String s, int i) {
  if (s == null || s.length <= i || i < 0) return false;
  final cu = s.codeUnitAt(i);
  return cu >= _zero && cu <= _nine;
}

//TODO: make a bit more agressive
const fullAbbreviations = {
  'sport': 'spo',
  'englisch': 'e',
  'evangelisch': 'ev',
  'deutsch': 'd',
  'informatik': 'i',
  'geschichte': 'g',
  'geografie': 'geo',
  'latein': 'l',
  'italienisch': 'it',
  'französisch': 'f',
  'sozialkunde': 'so',
  'mathematik': 'm',
  'musik': 'mu',
  'biologie': 'b',
  'bwl': 'bwl',
  'chemie': 'c',
  'kunst': 'k',
  'katholisch': 'ka',
  'physik': 'p',
  'wirtschaft': 'w',
  'nut': 'nut',
  'sprechstunde': 'spr',
};

bool abbreviationValid(String abbr, String sub) {
  ampInfo('abbrValid', 'Trying to parse $sub to $abbr...');
  fullAbbreviations.forEach((key, value) {
    if (value == abbr) {
      ampInfo('abbrValid', '$abbr = $value');
      ampInfo(
          'abbrValid', '${key.length >= sub.length} ${key.startsWith(sub)}');
      return key.length >= sub.length && key.startsWith(sub);
    }
  });
  return true;
}

String realSubject(String subject, [Language lang]) {
  lang ??= Language.current;
  if (subject == null) return null;

  //this code might break, but it hasnt as of nov 2020
  if (_numAt(subject, 0) || _numAt(subject, subject.length - 1)) {
    final firstLetter = subject.indexOf(_letters);
    final shortSubject =
        subject.substring(firstLetter, subject.lastIndexOf(_letters) + 1);
    final lnum = subject.substring(subject.lastIndexOf(_numbers));
    var fnum = '';
    if (firstLetter > 0) fnum = ' (${subject.substring(0, firstLetter)})';
    return '${realSubject(shortSubject, lang)} $lnum$fnum';
  }

  final sub = subject.toLowerCase();
  var s = subject;
  final lut = lang.subjectLut;
  for (final key in lut.keys) {
    if (sub.startsWith(key) && abbreviationValid(key, sub)) {
      s = lut[key];
    }
  }

  return s;
}
