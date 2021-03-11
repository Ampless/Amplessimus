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

String lookupSubject(String subject) {
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

String parseSubject(String subject) {
  if (!prefs.parseSubjects) return subject;

  var offset = 0;
  for (final match in RegExp('[a-zA-Z]+').allMatches(subject)) {
    final start = match.start + offset;
    final end = match.end + offset;
    final res = lookupSubject(subject.substring(start, end));
    subject = subject.substring(0, start) + res + subject.substring(end);
    offset -= end - start;
    offset += res.length;
  }

  return subject;
}
