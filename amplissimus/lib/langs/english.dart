import 'package:Amplissimus/dsbapi.dart';
import 'package:Amplissimus/langs/language.dart';

class English extends Language {
  @override
  String get appInfo => 'Amplissimus is an App for easily viewing Untis substitution plans using DSBMobile.';

  @override
  String get code => 'en';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuStart => 'Start';

  @override
  String get name => 'English';

  @override
  String get settingsAppInfo => 'App Information';

  @override
  String get settingsChangeAppearance => 'Change appearance';

  @override
  String get settingsChangeLogin => 'Login data';

  @override
  String get settingsChangeLoginPopup => 'DSBMobile Login';

  @override
  String get settingsLightsOff => 'Lights off';

  @override
  String get settingsLightsOn => 'Lights on';

  @override
  String get settingsSelectClass => 'Select class';

  @override
  String get settingsLightsNoSystem => 'Don\'t use\nsystem appearance';

  @override
  String get settingsLightsUseSystem => 'Use\nsystem appearance';

  @override
  String dsbSubtoSubtitle(DsbSubstitution sub) {
    String notesaddon = sub.notes.length > 0 ? ' (${sub.notes})' : '';
    return sub.isFree ? 'Free lesson${sub.hours.length == 1 ? '' : 'n'}$notesaddon'
                      : 'Substituted by ${sub.teacher}$notesaddon';
  }

  @override
  String dsbSubtoTitle(DsbSubstitution sub) {
    String hour = '';
    for(int h in sub.hours) {
      if(hour.length > 0) hour += '-';
      hour += h.toString();
      int r = h % 10;
      if(r == 1) hour += 'st';
      else if(r == 2) hour += 'nd';
      else if(r == 3) hour += 'rd';
      else hour += 'th';
    }
    return '$hour lesson ${sub.realSubject}';
  }

  @override
  String catchDsbGetData(dynamic e) {
    return 'Please check your internet connection. (Error: $e)';
  }

  @override
  String get dsbListErrorSubtitle => 'Please report to Amplus (https://amplus.chrissx.de/amplissimus)';

  @override
  String get dsbListErrorTitle => 'Amplissimus Error';

  @override
  String get dsbErrorNoLogin => 'No login data entered.';

  @override
  String get classSelectorEmpty => 'Empty';

  @override
  String get settingsChangeLoginPopupPassword => 'Password';

  @override
  String get settingsChangeLoginPopupUsername => 'Username';

  @override
  String get settingsChangeLoginPopupSave => 'Save';

  @override
  String get settingsChangeLoginPopupCancel => 'Cancel';

  @override
  String get dsbUiAllClasses => 'All classes';

  @override
  String get widgetValidatorFieldEmpty => 'Field is empty!';

  @override
  String get widgetValidatorInvalid => 'Invalid input!';

  @override
  String get settingsChangeLanguage => 'Change language';
}
