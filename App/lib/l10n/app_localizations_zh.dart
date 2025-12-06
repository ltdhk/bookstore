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
  String get hot => '热门';

  @override
  String get newTab => '最新';

  @override
  String get male => '男生';

  @override
  String get female => '女生';

  @override
  String get searchHint => '搜索小说';

  @override
  String get settings => '设置';

  @override
  String get darkMode => '深色模式';

  @override
  String get alwaysLightMode => '始终浅色模式';

  @override
  String get autoUnlockChapter => '自动解锁章节';

  @override
  String get language => '语言';

  @override
  String get versionUpdate => '版本更新';

  @override
  String get about => '关于我们';

  @override
  String get rate => '去评分';

  @override
  String get followSystem => '跟随系统';

  @override
  String get alwaysDark => '始终深色模式';

  @override
  String get alwaysLight => '始终浅色模式';

  @override
  String get svipMember => 'SVIP会员';

  @override
  String get regularMember => '普通会员';

  @override
  String get login => '登录';

  @override
  String get logout => '退出登录';

  @override
  String get signUp => '注册';

  @override
  String get register => '注册';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get loginToYourAccount => '登录您的账户';

  @override
  String get createAccount => '创建账户';

  @override
  String get signUpToGetStarted => '注册开始使用';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get nickname => '昵称（可选）';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get pleaseEnterEmail => '请输入您的邮箱';

  @override
  String get pleaseEnterValidEmail => '请输入有效的邮箱地址';

  @override
  String get pleaseEnterPassword => '请输入您的密码';

  @override
  String get passwordMinLength => '密码至少需要6个字符';

  @override
  String get pleaseConfirmPassword => '请确认您的密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String loginFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String registrationFailed(String error) {
    return '注册失败：$error';
  }

  @override
  String get registrationSuccessful => '注册成功！请登录。';

  @override
  String get agreeToTerms => '请同意条款和隐私政策';

  @override
  String get iAgreeToThe => '我同意';

  @override
  String get userAgreement => '用户协议';

  @override
  String get and => '和';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get privacyAgreement => '隐私协议';

  @override
  String get whenYouLogin => '登录即表示您已阅读并同意\n';

  @override
  String get loginViaApple => '通过 Apple 登录';

  @override
  String get loginViaGoogle => '通过 Google 登录';

  @override
  String get loginViaEmail => '通过邮箱登录';

  @override
  String get dontHaveAccount => '还没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get svipMembership => 'SVIP 会员';

  @override
  String get readAllNovels => '无限制阅读网站上的所有小说';

  @override
  String get subscribeNow => '立即订阅';

  @override
  String get readingHistory => '阅读记录';

  @override
  String get transactionRecord => '交易记录';

  @override
  String get setting => '设置';

  @override
  String get myBookshelf => '我的书架';

  @override
  String get edit => '编辑';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get deleteBooks => '删除书籍';

  @override
  String deleteBooksConfirm(int count) {
    return '从书架中删除 $count 本书？';
  }

  @override
  String get booksRemoved => '书籍已从书架中移除';

  @override
  String errorRemovingBooks(String error) {
    return '移除书籍时出错：$error';
  }

  @override
  String get noBooksInBookshelf => '书架中没有书籍';

  @override
  String get browseBooks => '浏览书籍';

  @override
  String get description => '简介';

  @override
  String get reads => '阅读';

  @override
  String get addToBookshelf => '加入书架';

  @override
  String get readNow => '立即阅读';

  @override
  String get continueReading => '继续阅读';

  @override
  String get clearAll => '清空全部';

  @override
  String get clearHistoryConfirm => '确定要清空所有阅读记录吗？';

  @override
  String get historyClearedSuccess => '阅读记录已清空';

  @override
  String errorClearingHistory(String error) {
    return '清空记录时出错：$error';
  }

  @override
  String get noReadingHistory => '暂无阅读记录';

  @override
  String get startReadingBooks => '开始阅读一些书籍，您的记录将显示在这里';

  @override
  String errorLoadingHistory(String error) {
    return '加载记录时出错：$error';
  }

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int minutes) {
    return '$minutes 分钟前';
  }

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String todayAt(String time) {
    return '今天 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String get pleaseLoginToView => '请登录查看交易记录';

  @override
  String get noTransactionRecords => '暂无交易记录';

  @override
  String get noTransactionHint => '您的订阅购买记录将显示在这里';

  @override
  String errorLoadingOrders(String error) {
    return '加载订单时出错：$error';
  }

  @override
  String get loadMore => '加载更多';

  @override
  String get noMoreOrders => '没有更多订单了';

  @override
  String get pending => '待支付';

  @override
  String get paid => '已支付';

  @override
  String get refunded => '已退款';

  @override
  String get failedToLoadSubscriptions => '加载订阅失败';

  @override
  String get subscribeToSVIP => '订阅 SVIP';

  @override
  String get unlockAllContent => '解锁所有内容';

  @override
  String get monthlyPlan => '月度计划';

  @override
  String get quarterlyPlan => '季度计划';

  @override
  String get yearlyPlan => '年度计划';

  @override
  String get perMonth => '/月';

  @override
  String save(String percent) {
    return '省 $percent%';
  }

  @override
  String totalPrice(String price) {
    return '总计：\$$price';
  }

  @override
  String get subscribe => '订阅';

  @override
  String get usePasscode => '使用兑换码';

  @override
  String get enterPasscode => '输入兑换码';

  @override
  String get passcodeHint => '请输入16位兑换码';

  @override
  String get apply => '兑换';

  @override
  String get invalidPasscode => '兑换码格式无效，请输入16位数字码。';

  @override
  String successfullySubscribed(String productName) {
    return '成功订阅 $productName！';
  }

  @override
  String subscriptionFailed(String error) {
    return '订阅失败：$error';
  }

  @override
  String get processing => '处理中...';

  @override
  String chapter(String number) {
    return '第 $number 章';
  }

  @override
  String get chapterLocked => '本章节已锁定';

  @override
  String get unlockWithSVIP => '订阅 SVIP 以解锁';

  @override
  String get chapterLoadError => '章节加载失败';

  @override
  String get loading => '加载中...';

  @override
  String get novelMaster => '小说大师';

  @override
  String get expiresOn => '到期时间';
}
