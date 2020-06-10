int max(List<int> i) {
  if(i.length == 0) return null;
  int j = i[0];
  for(int k in i)
    if(j < k)
      j = k;
  return j;
}

int min(List<int> i) {
  if(i.length == 0) return null;
  int j = i[0];
  for(int k in i)
    if(j > k)
      j = k;
  return j;
}
