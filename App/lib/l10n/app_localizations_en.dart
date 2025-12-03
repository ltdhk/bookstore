// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Book Store';

  @override
  String get home => 'Home';

  @override
  String get bookshelf => 'Bookshelf';

  @override
  String get profile => 'My';

  @override
  String get hot => 'Hot';

  @override
  String get newTab => 'New';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get searchHint => 'Search for novel next';

  @override
  String get settings => 'Setting';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get alwaysLightMode => 'Always Light Mode';

  @override
  String get autoUnlockChapter => 'Auto unlock chapter';

  @override
  String get language => 'Language';

  @override
  String get versionUpdate => 'Version Update';

  @override
  String get about => 'About Novel Next';

  @override
  String get rate => 'Rate Novel Next';

  @override
  String get followSystem => 'Follow System';

  @override
  String get alwaysDark => 'Always Dark Mode';

  @override
  String get alwaysLight => 'Always Light Mode';

  @override
  String get svipMember => 'SVIP';

  @override
  String get regularMember => 'Member';

  @override
  String get login => 'Log In';

  @override
  String get logout => 'Log Out';

  @override
  String get signUp => 'Sign Up';

  @override
  String get register => 'Register';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get loginToYourAccount => 'Log in to your account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signUpToGetStarted => 'Sign up to get started';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get nickname => 'Nickname (Optional)';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get registrationSuccessful => 'Registration successful! Please login.';

  @override
  String get agreeToTerms => 'Please agree to the Terms and Privacy Policy';

  @override
  String get iAgreeToThe => 'I agree to the ';

  @override
  String get userAgreement => 'User Agreement';

  @override
  String get and => ' and ';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyAgreement => 'Privacy Agreement';

  @override
  String get whenYouLogin =>
      'When you log in, we will assume that you have read and agreed to the\n';

  @override
  String get loginViaApple => 'Log in via apple';

  @override
  String get loginViaGoogle => 'Log in via google';

  @override
  String get loginViaEmail => 'Log in via Email';

  @override
  String get dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get alreadyHaveAccount => 'Already have an account? ';

  @override
  String get svipMembership => 'SVIP MEMBERSHIP';

  @override
  String get readAllNovels =>
      'Read all novels on the site without restrictions';

  @override
  String get subscribeNow => 'Subscribe now';

  @override
  String get readingHistory => 'Reading history';

  @override
  String get transactionRecord => 'Transaction Record';

  @override
  String get setting => 'Setting';

  @override
  String get myBookshelf => 'My bookshelf';

  @override
  String get edit => 'Edit';

  @override
  String get cancel => 'cancel';

  @override
  String get delete => 'Delete';

  @override
  String get deleteBooks => 'Delete Books';

  @override
  String deleteBooksConfirm(int count) {
    return 'Delete $count book(s) from your bookshelf?';
  }

  @override
  String get booksRemoved => 'Books removed from bookshelf';

  @override
  String errorRemovingBooks(String error) {
    return 'Error removing books: $error';
  }

  @override
  String get noBooksInBookshelf => 'No books in your bookshelf';

  @override
  String get browseBooks => 'Browse books';

  @override
  String get description => 'Description';

  @override
  String get reads => 'Reads';

  @override
  String get addToBookshelf => 'Add to Bookshelf';

  @override
  String get readNow => 'Read Now';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearHistoryConfirm =>
      'Are you sure you want to clear all reading history?';

  @override
  String get historyClearedSuccess => 'Reading history cleared successfully';

  @override
  String errorClearingHistory(String error) {
    return 'Error clearing history: $error';
  }

  @override
  String get noReadingHistory => 'No reading history yet';

  @override
  String get startReadingBooks =>
      'Start reading some books to see your history here';

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history: $error';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int minutes) {
    return '$minutes minutes ago';
  }

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String todayAt(String time) {
    return 'Today $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday $time';
  }

  @override
  String get pleaseLoginToView => 'Please log in to view transaction records';

  @override
  String get noTransactionRecords => 'No transaction records yet';

  @override
  String get noTransactionHint =>
      'Your subscription purchases will appear here';

  @override
  String errorLoadingOrders(String error) {
    return 'Error loading orders: $error';
  }

  @override
  String get loadMore => 'Load More';

  @override
  String get noMoreOrders => 'No more orders';

  @override
  String get pending => 'Pending';

  @override
  String get paid => 'Paid';

  @override
  String get refunded => 'Refunded';

  @override
  String get failedToLoadSubscriptions => 'Failed to load subscriptions';

  @override
  String get subscribeToSVIP => 'Subscribe to SVIP';

  @override
  String get unlockAllContent => 'Unlock all content';

  @override
  String get monthlyPlan => 'Monthly Plan';

  @override
  String get quarterlyPlan => 'Quarterly Plan';

  @override
  String get yearlyPlan => 'Yearly Plan';

  @override
  String get perMonth => '/month';

  @override
  String save(String percent) {
    return 'Save $percent%';
  }

  @override
  String totalPrice(String price) {
    return 'Total: \$$price';
  }

  @override
  String get subscribe => 'Subscribe';

  @override
  String get usePasscode => 'Use Passcode';

  @override
  String get enterPasscode => 'Enter Passcode';

  @override
  String get passcodeHint => 'Enter your 16-digit passcode';

  @override
  String get apply => 'Apply';

  @override
  String get invalidPasscode =>
      'Invalid passcode format. Please enter a 16-digit code.';

  @override
  String successfullySubscribed(String productName) {
    return 'Successfully subscribed to $productName!';
  }

  @override
  String subscriptionFailed(String error) {
    return 'Subscription failed: $error';
  }

  @override
  String get processing => 'Processing...';

  @override
  String chapter(String number) {
    return 'Chapter $number';
  }

  @override
  String get chapterLocked => 'This chapter is locked';

  @override
  String get unlockWithSVIP => 'Subscribe to SVIP to unlock';

  @override
  String get chapterLoadError => 'Failed to load chapter';

  @override
  String get loading => 'Loading...';

  @override
  String get novelMaster => 'Novel Next';
}
