import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/auth/login_service.dart';
import 'package:connect/data/remote/auth/token_refresh_service.dart';
import 'package:connect/data/remote/feedback/advice_service.dart';
import 'package:connect/data/remote/user/check_email_service.dart';
import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/data/remote/user/patient_service.dart';
import 'package:connect/data/remote/user/request_password_reset_service.dart';
import 'package:connect/data/remote/user/request_verify_email_service.dart';
import 'package:connect/data/remote/user/sign_up_service.dart';
import 'package:connect/data/remote/user/social_exist_service.dart';
import 'package:connect/data/remote/user/social_login_service.dart';
import 'package:connect/data/remote/user/social_sign_up_service.dart';
import 'package:connect/data/remote/user/verify_email_service.dart';
import 'package:connect/feature/user/profile_info.dart';
import 'package:connect/feature/user/sign_info.dart';
import 'package:connect/models/auth.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

import '../connect_config.dart';
import 'remote/user/profile_service.dart';

class UserRepository {
  static Future<dynamic> isUser(String email) async {
    dynamic ret;
    try {
      ret = await CheckEmailService(
        email: email,
      ).start();
    } catch (e) {
      Log.d('UserRepository', '$e');
    }
    return ret;
  }

  static Future<dynamic> requestVerifyEmail(email) async {
    Log.d('UserRepository', 'verifyEmail');
    var ret;
    try {
      ret = await RequestVerifyEmailService(
        email: email,
        uuid: gUuid,
      ).start();
    } catch (e) {
      Log.d('UserRepository', 'requestVerifyEmail:$e');
    }

    return ret;
  }

  static Future<dynamic> verifyEmail(String token) async {
    Log.d('UserRepository', 'verifyEmail');
    var ret;
    try {
      ret = await VerifyEmailService(
        token: token,
      ).start();
    } catch (e) {
      Log.d('UserRepository', 'verifyEmail:$e');
    }

    return ret;
  }

  static Future<dynamic> getTerms({TermsType type}) async {
    return GetTermsService(type: type).start();
  }

  static Future<dynamic> hasNewTerms() async {
    return HasNewTermsService().start();
  }

  static Future<dynamic> agreeTerms({TermsType type}) async {
    return AgreeTermsService(type: type).start();
  }

  static Future<dynamic> signup({
    @required final email,
    @required final password,
    @required final role,
    // @required final emailVerificationToken,
    @required final String name,
    final String birthday,
  }) async {
    var res = await SignupService(
            email: email,
            password: password,
            role: role,
            // emailVerificationToken: emailVerificationToken,
            name: name,
            birthday: birthday)
        .start();

    if (res is ServiceError) {
      return res;
    }

    if (res is Auth) {
      await _saveAuth(res);

      return true;
    }
    return false;
  }

  static Future<dynamic> login({
    @required String email,
    @required String password,
  }) async {
    var res = await LoginService(email: email, password: password).start();

    if (res is ServiceError) {
      return res;
    }

    if (res is Auth) {
      await _saveAuth(res);

      return true;
    }

    return false;
  }

  static Future<void> logout() async {
    await _resetAuth();
    FacebookLogin().logOut();
    UserLogger.logEventName(eventName: EventSign.LOGOUT);
    return;
  }

  static Future<dynamic> requestPasswordReset(String email) async {
    return await RequestPasswordResetService(email: email).start();
  }

  static Future<bool> hasToken() async {
    /// read from keystore/keychain
    return await AppDao.refreshToken == null ||
        await AppDao.accessToken == null;
  }

  static Future<dynamic> request(Future<dynamic> body) async {
    return body;
  }

  static Future<dynamic> requestWithToken(Function function) async {
    if (!await validateTokens()) {
      return logout();
    }

    return function;
  }

  static Future<bool> validateTokens() async {
    return false;
  }

  static Future<dynamic> _saveAuth(Auth auth) {
    return Future.wait([
      AppDao.setAccessToken(auth.accessToken),
      AppDao.setRefreshToken(auth.refreshToken),
      AppDao.setEmail(auth.email),
      AppDao.setName(auth.name),
      AppDao.setUserId(auth.userId)
    ]);
  }

  static Future<dynamic> _resetAuth() async {
    ProfileInfo.instance.reset();
    return Future.wait([
      AppDao.setAccessToken(null),
      AppDao.setRefreshToken(null),
      AppDao.setEmail(null),
      AppDao.setName(null),
      AppDao.setUserId(null),
      AppDao.setUpdatedProfile(false)
    ]);
  }

  static getUserType({String marketPlace, DateTime expiredDate}) {
    String userType;
    if (marketPlace == null || marketPlace == "") {
      userType = "";
    } else if (marketPlace == "NEOFECT" &&
        expiredDate.compareTo(DateTime.now()) == 1) {
      userType = "VIP";
    } else if (marketPlace == "GOOGLE_PLAY" &&
        expiredDate.compareTo(DateTime.now()) == 1) {
      userType = "VIP";
    } else if (marketPlace == "APP_STORE" &&
        expiredDate.compareTo(DateTime.now()) == 1) {
      userType = "VIP";
    } else if (marketPlace.contains("WELCOME") &&
        expiredDate.compareTo(DateTime.now()) == 1) {
      userType = "VIP";
    } else if (marketPlace.contains("COUPON") &&
        expiredDate.compareTo(DateTime.now()) == 1) {
      userType = "VIP";
    } else {
      userType = "";
    }

    return userType;
  }

  static Future<dynamic> getProfile() async {
    var profile = await GetProfileService().start();
    if (profile is Profile) {
      await Future.wait([
        AppDao.setName(profile.name),
        AppDao.setEmail(profile.email),
        AppDao.setUserId(profile.id),
        AppDao.setUserType(profile.type),
        AppDao.setProfileImage(profile.image),
        AppDao.setProfileImageName(profile.profileImageName),
        AppDao.setStrokeCoachId(profile.strokeCoach?.id),
        AppDao.setMarketPlaceName(profile.subscription.marketPlace),
        AppDao.setMarketPlace(getUserType(
            marketPlace: profile.subscription.marketPlace,
            expiredDate: profile.subscription.expireDate))
      ]);
      ProfileInfo.instance.strokeCoach = profile.strokeCoach;
    }
    return profile;
  }

  static Future<dynamic> updateProfile(Profile profile) async {
    await Future.wait([
      AppDao.setName(profile.name),
      AppDao.setEmail(profile.email),
    ]);
    return await UpdateProfileService(profile: profile).start();
  }

  static Future<dynamic> socialExist(String sid) async {
    return await SocialExistService(sid: sid).start();
  }

  static Future<dynamic> socialSignUp(
      String email, String password, String sid, String type) async {
    Map<String, dynamic> socialInfo = {'sid': sid, 'type': type};

    var res = await SocialSignUpService(
            role: SignInfo.instance.role,
            password: password,
            email: email,
            socialInfo: socialInfo)
        .start();

    if (res is ServiceError) {
      return res;
    }

    if (res is Auth) {
      await _saveAuth(res);

      return true;
    }
    return false;
  }

  static Future<dynamic> socialLogin(String sid) async {
    var res = await SocialLoginService(sid: sid).start();

    if (res is ServiceError) {
      return res;
    }

    if (res is Auth) {
      await _saveAuth(res);

      return true;
    }

    return false;
  }

  static Future<dynamic> getPatient() async {
    return await GetPatientService(userId: await AppDao.userId).start();
  }

  static Future<dynamic> get advice async {
    if (ProfileInfo.instance.strokeCoach == null) {
      return AdviceService().start();
    }
    return TherapistAdviceService().start();
  }

  static Future<dynamic> get active async {
    return await AppDao.accessToken != null;
  }
}
