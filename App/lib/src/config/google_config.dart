/// Google OAuth 2.0 配置
/// 从 Google Cloud Console 获取这些 Client ID
class GoogleConfig {
  // 私有构造函数，防止实例化
  GoogleConfig._();

  /// Web Client ID - 用于 Android
  /// 从 Google Cloud Console 创建 Web 应用客户端获取
  static const String webClientId = '865872944830-hduu1vo9mjcinidf5oji7gucfnoq23ja.apps.googleusercontent.com';

  /// iOS Client ID
  /// 从 Google Cloud Console 创建 iOS 客户端获取
  static const String iosClientId = '865872944830-btf095tp1p1rubbttcotnbuud7pv6pfp.apps.googleusercontent.com';

  /// Android Client ID (可选，仅用于参考)
  /// 实际使用时 Android 平台使用 Web Client ID
  static const String androidClientId = '865872944830-7jd8dgvveoiub2hprs3bkbjg30aqe6j2.apps.googleusercontent.com';
}
