dynamic jsonIsMap(dynamic json) {
  assert(json is Map);
  return json;
}

dynamic jsonContainsKey(dynamic json, dynamic key) {
  assert(json.containsKey(key));
  return json;
}

dynamic jsonIsList(dynamic json) {
  assert(json is List);
  return json;
}

dynamic jsonContainsIndex(dynamic json, int index) {
  assert(json.length > index);
  return json;
}

dynamic jsonListLength(dynamic json) => jsonIsList(json).length;
dynamic jsonMapLength(dynamic json) => jsonIsMap(json).length;
dynamic jsonGetKey(dynamic json, dynamic key) => jsonContainsKey(jsonIsMap(json), key)[key];
dynamic jsonGetIndex(dynamic json, {int index = 0}) => jsonContainsIndex(jsonIsList(json), index)[index];
