import 'package:Amplessimus/langs/language.dart';

final _zero = '0'.codeUnitAt(0), _nine = '9'.codeUnitAt(0);
final _letters = RegExp(r'[a-zA-Z]');
final _numeric = RegExp(r'[0-9]');

bool _isNum(String s, int i) {
  if (s == null || s.length <= i || i < 0) return false;
  final cu = s.codeUnitAt(i);
  return cu >= _zero && cu <= _nine;
}

String realSubject(String subject, [Language lang]) {
  lang ??= Language.current;
  if (subject == null) return null;
  //this code might break with some newer systems
  if (_isNum(subject, 0) || _isNum(subject, subject.length - 1))
    return '${realSubject(subject.substring(subject.indexOf(_letters), subject.lastIndexOf(_letters) + 1), lang)} '
        '${subject.substring(subject.lastIndexOf(_numeric))}'
        '${subject.indexOf(_letters) > 0 ? " (${subject.substring(0, subject.indexOf(_letters))})" : ""}';
  final sub = subject.toLowerCase();
  var s = subject;
  final lut = lang.subjectLut;
  for (var key in lut.keys) if (sub.startsWith(key)) s = lut[key];
  return s;
}

String lesson(List<int> lessons) {
  if (lessons == null) return 'null';
  var lesson = '';
  for (var l in lessons) lesson += lesson.isEmpty ? l.toString() : '-$l';
  return lesson;
}
