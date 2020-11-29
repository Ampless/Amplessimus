import 'package:Amplessimus/langs/language.dart';

final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);
final _letters = RegExp('[a-zA-Z]');
final _numbers = RegExp('[0-9]');

bool _numAt(String s, int i) {
  if (s == null || s.length <= i || i < 0) return false;
  final cu = s.codeUnitAt(i);
  return cu >= _zero && cu <= _nine;
}

//TODO: reverse the key<->value order and make a bit more agressive
const fullAbbreviations = {
  'spo': 'sport',
  'e': 'englisch',
  'ev': 'evangelisch',
  'd': 'deutsch',
  'i': 'informatik',
  'g': 'geschichte',
  'geo': 'geografie',
  'l': 'latein',
  'it': 'italienisch',
  'f': 'französisch',
  'so': 'sozialkunde',
  'sk': 'sozialkunde',
  'm': 'mathematik',
  'mu': 'musik',
  'b': 'biologie',
  'bwl': 'bwl',
  'c': 'chemie',
  'k': 'kunst',
  'ka': 'katholisch',
  'p': 'physik',
  'w': 'wirtschaft',
  'nut': 'nut',
  'spr': 'sprechstunde',
};

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
    if (sub.startsWith(key) &&
        fullAbbreviations[key].length <= sub.length &&
        fullAbbreviations[key].startsWith(sub)) {
      s = lut[key];
    }
  }

  return s;
}
