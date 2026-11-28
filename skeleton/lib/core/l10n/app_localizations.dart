import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @placeholderTitle.
  ///
  /// In en, this message translates to:
  /// **'Skeleton'**
  String get placeholderTitle;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @localeTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get localeTitle;

  /// No description provided for @localeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get localeSystem;

  /// No description provided for @localeEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get localeEnglish;

  /// No description provided for @localeIndonesian.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get localeIndonesian;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check connection'**
  String get checkConnection;

  /// No description provided for @checkConnectionLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking connection…'**
  String get checkConnectionLoading;

  /// No description provided for @checkConnectionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connected. The server answered.'**
  String get checkConnectionSuccess;

  /// No description provided for @failureNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get failureNetworkTitle;

  /// No description provided for @failureNetworkBody.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get failureNetworkBody;

  /// No description provided for @failureUnauthorizedTitle.
  ///
  /// In en, this message translates to:
  /// **'Access denied'**
  String get failureUnauthorizedTitle;

  /// No description provided for @failureUnauthorizedBody.
  ///
  /// In en, this message translates to:
  /// **'You need to sign in or you do not have permission.'**
  String get failureUnauthorizedBody;

  /// No description provided for @failureNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failureNotFoundTitle;

  /// No description provided for @failureNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'We could not find what you asked for.'**
  String get failureNotFoundBody;

  /// No description provided for @failureValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invalid request'**
  String get failureValidationTitle;

  /// No description provided for @failureValidationBody.
  ///
  /// In en, this message translates to:
  /// **'Some of the information was not accepted. Check it and try again.'**
  String get failureValidationBody;

  /// No description provided for @failureServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server problem'**
  String get failureServerTitle;

  /// No description provided for @failureServerBody.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request. Try again later.'**
  String get failureServerBody;

  /// No description provided for @failureCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage problem'**
  String get failureCacheTitle;

  /// No description provided for @failureCacheBody.
  ///
  /// In en, this message translates to:
  /// **'We could not read or save data on this device.'**
  String get failureCacheBody;

  /// No description provided for @failureUnexpectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get failureUnexpectedTitle;

  /// No description provided for @failureUnexpectedBody.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Try again.'**
  String get failureUnexpectedBody;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @themeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get themeModeLabel;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
