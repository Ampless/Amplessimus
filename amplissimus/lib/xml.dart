String xmlEscape(String s) => s.replaceAll('&', '&amp;')
                               .replaceAll('"', '&quot;')
                               .replaceAll("'", '&apos;')
                               .replaceAll('<', '&lt;')
                               .replaceAll('>', '&gt;');
