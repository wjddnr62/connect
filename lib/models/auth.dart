import 'package:connect/utils/logger/log.dart';

class Auth {
  final String accessToken;

  final String tokenType;

  final String refreshToken;

  final int expiresIn;

  final String scope;

  final String email;

  final String name;

  final int userId;

  final String jti;

  Auth({
    this.accessToken,
    this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.scope,
    this.email,
    this.jti,
    this.name,
    this.userId,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    Auth ret;
    try {
      ret = Auth(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String,
        refreshToken: json['refresh_token'] as String,
        expiresIn: json['expires_in'] as int,
        scope: json['scope'] as String,
        email: json['email'] as String,
        jti: json['jti'] as String,
        name: json['name'] as String,
        userId: json['user_id'] as int,
      );
    } catch (e) {
      Log.d('Auth', '$e');
    }

    return ret;
  }
}
