int max(List<int> i) {
  if (i == null || i.isEmpty) return null;
  var j = i[0];
  for (var k in i) if (j < k) j = k;
  return j;
}

int min(List<int> i) {
  if (i == null || i.isEmpty) return null;
  var j = i[0];
  for (var k in i) if (j > k) j = k;
  return j;
}
