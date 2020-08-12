import 'package:Amplessimus/langs/language.dart';

bool _isNum(String s, int i) {
  if (s == null || s.length <= i || i < 0) return false;
  var cu = s.codeUnitAt(i);
  return cu >= _zero && cu <= _nine;
}

final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);
final _letters = RegExp(r'[a-zA-Z]');
final _numeric = RegExp(r'[0-9]');

String realSubject(String subject, [Language lang]) {
  lang ??= Language.current;
  if (subject == null) return null;
  if (_isNum(subject, 0) || _isNum(subject, subject.length - 1))
    return '${realSubject(subject.substring(subject.indexOf(_letters), subject.lastIndexOf(_letters) + 1), lang)} '
        '${subject.substring(subject.lastIndexOf(_numeric))} (${subject.substring(0, subject.indexOf(_letters))})';
  var sub = subject.toLowerCase();
  var s = subject;
  var lut = lang.subjectLut;
  for (var key in lut.keys) if (sub.startsWith(key)) s = lut[key];
  return s;
}
