class GoogleSignInRequest {
  final String idToken;
  final String? serverAuthCode;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  GoogleSignInRequest({
    required this.idToken,
    this.serverAuthCode,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      if (serverAuthCode != null) 'serverAuthCode': serverAuthCode,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }
}
