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
  String get searchHint => 'Search for novel';
}
