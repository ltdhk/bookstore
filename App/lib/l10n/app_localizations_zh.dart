// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '书城';

  @override
  String get home => '首页';

  @override
  String get bookshelf => '书架';

  @override
  String get profile => '我的';

  @override
  String get searchHint => '搜索小说';
}
