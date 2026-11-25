// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get placeholderTitle => 'Skeleton';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get localeTitle => 'Language';

  @override
  String get localeSystem => 'System';

  @override
  String get localeEnglish => 'English';

  @override
  String get localeIndonesian => 'Indonesia';

  @override
  String get checkConnection => 'Check connection';

  @override
  String get checkConnectionLoading => 'Checking connection…';

  @override
  String get checkConnectionSuccess => 'Connected. The server answered.';

  @override
  String get failureNetworkTitle => 'No connection';

  @override
  String get failureNetworkBody =>
      'Check your internet connection and try again.';

  @override
  String get failureUnauthorizedTitle => 'Access denied';

  @override
  String get failureUnauthorizedBody =>
      'You need to sign in or you do not have permission.';

  @override
  String get failureNotFoundTitle => 'Not found';

  @override
  String get failureNotFoundBody => 'We could not find what you asked for.';

  @override
  String get failureValidationTitle => 'Invalid request';

  @override
  String get failureValidationBody =>
      'Some of the information was not accepted. Check it and try again.';

  @override
  String get failureServerTitle => 'Server problem';

  @override
  String get failureServerBody =>
      'The server could not complete the request. Try again later.';

  @override
  String get failureCacheTitle => 'Storage problem';

  @override
  String get failureCacheBody =>
      'We could not read or save data on this device.';

  @override
  String get failureUnexpectedTitle => 'Something went wrong';

  @override
  String get failureUnexpectedBody =>
      'An unexpected error occurred. Try again.';
}
