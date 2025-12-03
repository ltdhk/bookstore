class AppleSignInRequest {
  final String identityToken;
  final String? authorizationCode;
  final String? email;
  final String? fullName;
  final String? nonce;

  AppleSignInRequest({
    required this.identityToken,
    this.authorizationCode,
    this.email,
    this.fullName,
    this.nonce,
  });

  Map<String, dynamic> toJson() {
    return {
      'identityToken': identityToken,
      if (authorizationCode != null) 'authorizationCode': authorizationCode,
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      if (nonce != null) 'nonce': nonce,
    };
  }
}
