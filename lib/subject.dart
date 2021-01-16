import 'langs/language.dart';
import 'main.dart';

const fullAbbreviations = {
  'spo': 'sport',
  'e': 'englisch',
  'ev': 'evangelisch',
  'et': 'ethik',
  'd': 'deutsch',
  'i': 'informatik',
  'g': 'geschichte',
  'geo': 'geografie',
  'l': 'latein',
  'it': 'italienisch',
  'f': 'französisch',
  'frz': 'frz',
  'so': 'sozialkunde',
  'sk': 'skunde',
  'm': 'mathematik',
  'mu': 'musik',
  'b': 'biologie',
  'bwl': 'bwl',
  'c': 'chemie',
  'k': 'kunst',
  'ka': 'katholisch',
  'p': 'physik',
  'ps': 'psychologie',
  'w': 'wirtschaft',
  'nut': 'nut',
  'spr': 'sprechstunde',
};

bool abbreviationValid(String abbr, String sub) {
  if (!sub.startsWith(abbr)) return false;
  final fa = fullAbbreviations[abbr];
  if (fa == null) return true;
  return fa.length >= sub.length && fa.startsWith(sub);
}

String parseSubject(String subject) {
  if (!prefs.parseSubjects) return subject;

  if (RegExp('[a-zA-Z]').allMatches(subject).length < subject.length) {
    final letters = RegExp('[a-zA-Z]+').allMatches(subject);
    final start = letters.first.start;
    final end = letters.last.end;
    return subject.substring(0, start) +
        parseSubject(subject.substring(start, end)) +
        subject.substring(end);
  }

  final sub = subject.toLowerCase();
  var s = subject;
  final lut = Language.current.subjectLut;
  for (final entry in lut.entries) {
    if (abbreviationValid(entry.key, sub)) {
      s = entry.value;
    }
  }

  return s;
}
