

const String DSB_BUNDLE_ID = "de.heinekingmedia.inhouse.dsbmobile.web";
const String DSB_DEVICE = "WebApp";
const String DSB_ID = "";
const String DSB_VERSION = "2.3";
const String DSB_LANGUAGE = "de";
const String DSB_WEBSERVICE = 'http://www.dsbmobile.de/JsonHandlerWeb.ashx/GetData';

enum DsbRequesttype {
  unknown,
  data,
  mail,
  feedback,
  subjects,
}

String removeLastChars(String s, int n) {
  return s.substring(0, s.length - n);
}

class DsbAccount {
  String username;
  String password;

  DsbAccount(this.username, this.password);

  void getData() {
    String datetime = removeLastChars(DateTime.now().toIso8601String(), 3);
    String uuid = new Uuid().v4();
    String json = '{"UserId":"158681","UserPw":"schuelergpg01","AppVersion":"2.5.9","Language":"de","OsVersion":"28 8.0","AppId":"91e87348-1de4-4487-bf07-17a1c0f355bf","Device":"SM-G935F","BundleId":"de.heinekingmedia.dsbmobile","Date":"2020-05-26T15:10:30.490Z","LastUpdate":"2020-05-26T15:10:30.490Z"}';
  }
}


