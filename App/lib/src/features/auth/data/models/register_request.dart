class RegisterRequest {
  final String username;
  final String password;
  final String? nickname;

  RegisterRequest({
    required this.username,
    required this.password,
    this.nickname,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      if (nickname != null) 'nickname': nickname,
    };
  }
}
