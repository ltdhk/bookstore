class UserVO {
  final int id;
  final String username;
  final String? nickname;
  final String? avatar;
  final int? coins;
  final int? bonus;
  final bool? isSvip;
  final String token;

  UserVO({
    required this.id,
    required this.username,
    this.nickname,
    this.avatar,
    this.coins,
    this.bonus,
    this.isSvip,
    required this.token,
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
    };
  }
}
