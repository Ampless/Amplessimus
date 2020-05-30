// this code is based on the pub packages 'uuid' and 'html_unescape'

import 'dart:convert';
import 'dart:math';
import 'package:amplissimus/dsbhtmlcodes.dart' as htmlcodes;

String hex(int i) {
  return i < 16 ? '0' + i.toRadixString(16) : i.toRadixString(16);
}

String v4() {
  int rand;
  var r = List<int>(16);
  var _rand = Random();
  for(var i = 0; i < 16; i++) {
    if((i & 0x03) == 0)
      rand = (_rand.nextDouble() * 0x100000000).floor().toInt();
    r[i] = rand >> ((i & 0x03) << 3) & 0xff;
  }
  r[6] = (r[6] & 0x0f) | 0x40;
  r[8] = (r[8] & 0x3f) | 0x80;
  int i = 0;
  return '${hex(r[i++])}${hex(r[i++])}${hex(r[i++])}${hex(r[i++])}-'
         '${hex(r[i++])}${hex(r[i++])}-${hex(r[i++])}${hex(r[i++])}-'
         '${hex(r[i++])}${hex(r[i++])}-${hex(r[i++])}${hex(r[i++])}'
         '${hex(r[i++])}${hex(r[i++])}${hex(r[i++])}${hex(r[i++])}';
}



class HtmlUnescape extends Converter<String, String> {

  int _chunkLength;

  HtmlUnescape() {
    _chunkLength = 18;
  }

  String convert(String data) {
    if (data.indexOf('&') == -1) return data;

    StringBuffer buf = new StringBuffer();
    int offset = 0;

    while (true) {
      int nextAmp = data.indexOf('&', offset);
      if (nextAmp == -1) {
        buf.write(data.substring(offset));
        break;
      }
      buf.write(data.substring(offset, nextAmp));
      offset = nextAmp;

      var chunk = data.substring(offset, min(data.length, offset + _chunkLength));

      if (chunk.length > 4 && chunk.codeUnitAt(1) == 35) {
        int nextSemicolon = chunk.indexOf(';');
        if (nextSemicolon != -1) {
          var hex = chunk.codeUnitAt(2) == 120;
          var str = chunk.substring(hex ? 3 : 2, nextSemicolon);
          int ord = int.tryParse(str, radix: hex ? 16 : 10);
          if (ord != null) {
            buf.write(new String.fromCharCode(ord));
            offset += nextSemicolon + 1;
            continue;
          }
        }
      }

      var replaced = false;
      for (int i = 0; i < htmlcodes.keys.length; i++) {
        var key = htmlcodes.keys[i];
        if (chunk.startsWith(key)) {
          var replacement = htmlcodes.values[i];
          buf.write(replacement);
          offset += key.length;
          replaced = true;
          break;
        }
      }

      if (!replaced) {
        buf.write('&');
        offset++;
      }
    }

    return buf.toString();
  }
}