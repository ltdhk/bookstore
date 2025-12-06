class UserVO {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final int? coins;
  final int? bonus;
  final bool? isSvip;
  final String token;
  final String? subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final String? subscriptionPlanType;

  UserVO({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.coins,
    this.bonus,
    this.isSvip,
    required this.token,
    this.subscriptionStatus,
    this.subscriptionEndDate,
    this.subscriptionPlanType,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      id: json['id'] as int,
      username: json['username'] as String,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      coins: json['coins'] as int?,
      bonus: json['bonus'] as int?,
      isSvip: json['isSvip'] as bool?,
      token: json['token'] as String,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'] as String)
          : null,
      subscriptionPlanType: json['subscriptionPlanType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar,
      'coins': coins,
      'bonus': bonus,
      'isSvip': isSvip,
      'token': token,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'subscriptionPlanType': subscriptionPlanType,
    };
  }

  UserVO copyWith({
    int? id,
    String? username,
    String? nickname,
    String? avatar,
    int? coins,
    int? bonus,
    bool? isSvip,
    String? token,
    String? subscriptionStatus,
    DateTime? subscriptionEndDate,
    String? subscriptionPlanType,
  }) {
    return UserVO(
      id: id ?? this.id,
      username: username ?? this.username,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      coins: coins ?? this.coins,
      bonus: bonus ?? this.bonus,
      isSvip: isSvip ?? this.isSvip,
      token: token ?? this.token,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      subscriptionPlanType: subscriptionPlanType ?? this.subscriptionPlanType,
    );
  }
}
