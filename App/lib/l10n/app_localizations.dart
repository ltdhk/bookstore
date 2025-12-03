import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('es'),
    Locale('id'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Book Store'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @bookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get bookshelf;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'My'**
  String get profile;

  /// No description provided for @hot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get hot;

  /// No description provided for @newTab.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newTab;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search for novel next'**
  String get searchHint;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get settings;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @alwaysLightMode.
  ///
  /// In en, this message translates to:
  /// **'Always Light Mode'**
  String get alwaysLightMode;

  /// No description provided for @autoUnlockChapter.
  ///
  /// In en, this message translates to:
  /// **'Auto unlock chapter'**
  String get autoUnlockChapter;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @versionUpdate.
  ///
  /// In en, this message translates to:
  /// **'Version Update'**
  String get versionUpdate;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About Novel Next'**
  String get about;

  /// No description provided for @rate.
  ///
  /// In en, this message translates to:
  /// **'Rate Novel Next'**
  String get rate;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @alwaysDark.
  ///
  /// In en, this message translates to:
  /// **'Always Dark Mode'**
  String get alwaysDark;

  /// No description provided for @alwaysLight.
  ///
  /// In en, this message translates to:
  /// **'Always Light Mode'**
  String get alwaysLight;

  /// No description provided for @svipMember.
  ///
  /// In en, this message translates to:
  /// **'SVIP'**
  String get svipMember;

  /// No description provided for @regularMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get regularMember;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get loginToYourAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started'**
  String get signUpToGetStarted;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname (Optional)'**
  String get nickname;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Error message when login fails
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// Error message when registration fails
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Please login.'**
  String get registrationSuccessful;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms and Privacy Policy'**
  String get agreeToTerms;

  /// No description provided for @iAgreeToThe.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get iAgreeToThe;

  /// No description provided for @userAgreement.
  ///
  /// In en, this message translates to:
  /// **'User Agreement'**
  String get userAgreement;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyAgreement.
  ///
  /// In en, this message translates to:
  /// **'Privacy Agreement'**
  String get privacyAgreement;

  /// No description provided for @whenYouLogin.
  ///
  /// In en, this message translates to:
  /// **'When you log in, we will assume that you have read and agreed to the\n'**
  String get whenYouLogin;

  /// No description provided for @loginViaApple.
  ///
  /// In en, this message translates to:
  /// **'Log in via apple'**
  String get loginViaApple;

  /// No description provided for @loginViaGoogle.
  ///
  /// In en, this message translates to:
  /// **'Log in via google'**
  String get loginViaGoogle;

  /// No description provided for @loginViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Log in via Email'**
  String get loginViaEmail;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @svipMembership.
  ///
  /// In en, this message translates to:
  /// **'SVIP MEMBERSHIP'**
  String get svipMembership;

  /// No description provided for @readAllNovels.
  ///
  /// In en, this message translates to:
  /// **'Read all novels on the site without restrictions'**
  String get readAllNovels;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe now'**
  String get subscribeNow;

  /// No description provided for @readingHistory.
  ///
  /// In en, this message translates to:
  /// **'Reading history'**
  String get readingHistory;

  /// No description provided for @transactionRecord.
  ///
  /// In en, this message translates to:
  /// **'Transaction Record'**
  String get transactionRecord;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @myBookshelf.
  ///
  /// In en, this message translates to:
  /// **'My bookshelf'**
  String get myBookshelf;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBooks.
  ///
  /// In en, this message translates to:
  /// **'Delete Books'**
  String get deleteBooks;

  /// Confirmation message for deleting books
  ///
  /// In en, this message translates to:
  /// **'Delete {count} book(s) from your bookshelf?'**
  String deleteBooksConfirm(int count);

  /// No description provided for @booksRemoved.
  ///
  /// In en, this message translates to:
  /// **'Books removed from bookshelf'**
  String get booksRemoved;

  /// Error message when removing books fails
  ///
  /// In en, this message translates to:
  /// **'Error removing books: {error}'**
  String errorRemovingBooks(String error);

  /// No description provided for @noBooksInBookshelf.
  ///
  /// In en, this message translates to:
  /// **'No books in your bookshelf'**
  String get noBooksInBookshelf;

  /// No description provided for @browseBooks.
  ///
  /// In en, this message translates to:
  /// **'Browse books'**
  String get browseBooks;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @reads.
  ///
  /// In en, this message translates to:
  /// **'Reads'**
  String get reads;

  /// No description provided for @addToBookshelf.
  ///
  /// In en, this message translates to:
  /// **'Add to Bookshelf'**
  String get addToBookshelf;

  /// No description provided for @readNow.
  ///
  /// In en, this message translates to:
  /// **'Read Now'**
  String get readNow;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all reading history?'**
  String get clearHistoryConfirm;

  /// No description provided for @historyClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reading history cleared successfully'**
  String get historyClearedSuccess;

  /// Error message when clearing history fails
  ///
  /// In en, this message translates to:
  /// **'Error clearing history: {error}'**
  String errorClearingHistory(String error);

  /// No description provided for @noReadingHistory.
  ///
  /// In en, this message translates to:
  /// **'No reading history yet'**
  String get noReadingHistory;

  /// No description provided for @startReadingBooks.
  ///
  /// In en, this message translates to:
  /// **'Start reading some books to see your history here'**
  String get startReadingBooks;

  /// Error message when loading history fails
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorLoadingHistory(String error);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes} minutes ago'**
  String minutesAgo(int minutes);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Today with time
  ///
  /// In en, this message translates to:
  /// **'Today {time}'**
  String todayAt(String time);

  /// Yesterday with time
  ///
  /// In en, this message translates to:
  /// **'Yesterday {time}'**
  String yesterdayAt(String time);

  /// No description provided for @pleaseLoginToView.
  ///
  /// In en, this message translates to:
  /// **'Please log in to view transaction records'**
  String get pleaseLoginToView;

  /// No description provided for @noTransactionRecords.
  ///
  /// In en, this message translates to:
  /// **'No transaction records yet'**
  String get noTransactionRecords;

  /// No description provided for @noTransactionHint.
  ///
  /// In en, this message translates to:
  /// **'Your subscription purchases will appear here'**
  String get noTransactionHint;

  /// Error message when loading orders fails
  ///
  /// In en, this message translates to:
  /// **'Error loading orders: {error}'**
  String errorLoadingOrders(String error);

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @noMoreOrders.
  ///
  /// In en, this message translates to:
  /// **'No more orders'**
  String get noMoreOrders;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get refunded;

  /// No description provided for @failedToLoadSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions'**
  String get failedToLoadSubscriptions;

  /// No description provided for @subscribeToSVIP.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to SVIP'**
  String get subscribeToSVIP;

  /// No description provided for @unlockAllContent.
  ///
  /// In en, this message translates to:
  /// **'Unlock all content'**
  String get unlockAllContent;

  /// No description provided for @monthlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Monthly Plan'**
  String get monthlyPlan;

  /// No description provided for @quarterlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Plan'**
  String get quarterlyPlan;

  /// No description provided for @yearlyPlan.
  ///
  /// In en, this message translates to:
  /// **'Yearly Plan'**
  String get yearlyPlan;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// Savings percentage
  ///
  /// In en, this message translates to:
  /// **'Save {percent}%'**
  String save(String percent);

  /// Total price display
  ///
  /// In en, this message translates to:
  /// **'Total: \${price}'**
  String totalPrice(String price);

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @usePasscode.
  ///
  /// In en, this message translates to:
  /// **'Use Passcode'**
  String get usePasscode;

  /// No description provided for @enterPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter Passcode'**
  String get enterPasscode;

  /// No description provided for @passcodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your 16-digit passcode'**
  String get passcodeHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @invalidPasscode.
  ///
  /// In en, this message translates to:
  /// **'Invalid passcode format. Please enter a 16-digit code.'**
  String get invalidPasscode;

  /// Success message for subscription
  ///
  /// In en, this message translates to:
  /// **'Successfully subscribed to {productName}!'**
  String successfullySubscribed(String productName);

  /// Error message for subscription failure
  ///
  /// In en, this message translates to:
  /// **'Subscription failed: {error}'**
  String subscriptionFailed(String error);

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Chapter number
  ///
  /// In en, this message translates to:
  /// **'Chapter {number}'**
  String chapter(String number);

  /// No description provided for @chapterLocked.
  ///
  /// In en, this message translates to:
  /// **'This chapter is locked'**
  String get chapterLocked;

  /// No description provided for @unlockWithSVIP.
  ///
  /// In en, this message translates to:
  /// **'Subscribe to SVIP to unlock'**
  String get unlockWithSVIP;

  /// No description provided for @chapterLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load chapter'**
  String get chapterLoadError;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @novelMaster.
  ///
  /// In en, this message translates to:
  /// **'Novel Next'**
  String get novelMaster;
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
      <String>['en', 'es', 'id', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
