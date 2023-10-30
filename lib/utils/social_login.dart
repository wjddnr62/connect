import 'dart:convert';

import 'package:connect/connect_config.dart';
import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/sign/sign_up_page.dart';
import 'package:connect/models/error.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:uuid/uuid.dart';

import 'appsflyer/apps_flyer.dart';

bool facebookLoginIng = false;
bool appleLoginIng = false;
bool googleLoginIng = false;

Future<dynamic> facebookLogin(context) async {
  if (!facebookLoginIng) {
    facebookLoginIng = true;
    final facebookLogin = FacebookLogin();
    final result = await facebookLogin.logIn(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final token = result.accessToken.token;
        final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = json.decode(graphResponse.body);
        print(
            "profile : ${profile['name']}, ${profile['email']}, ${profile['id']}");

        String facebookSid = 'fb' + profile['id'];

        if (await socialUserCheck(facebookSid)) {
          var res = await UserRepository.socialLogin(facebookSid);

          if (res) {
            String date =
                "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
            await DurationRepository.durationRegist(date);
            UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
            pushNamedAndRemoveUntil(
                context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
            appsflyer.saveLog(facebookLoginLog);
            facebookLoginIng = false;
            return true;
          }
        } else {
          await socialSignUp(
              context: context,
              email: facebookSid + "*" + profile['email'],
              sid: facebookSid,
              socialType: "FACEBOOK");
          appsflyer.saveLog(facebookSign);
          facebookLoginIng = false;
          return true;
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Login cancel");
        facebookLoginIng = false;
        return true;
        break;
      case FacebookLoginStatus.error:
        print("Login Error : ${result.errorMessage}");
        facebookLogin.logOut();
        showDialog(
            context: context,
            child: BaseAlertDialog(
                content: AppStrings.of(StringKey.social_login_fail),
                onConfirm: () {}));
        facebookLoginIng = false;
        return true;
        break;
    }
    return false;
  }
}

googleLogin(context) async {
  if (!googleLoginIng) {
    googleLoginIng = true;

    GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'https://www.googleapis.com/auth/contacts.readonly']);

    try {
      await googleSignIn.signIn().then((value) async {
        googleLoginIng = false;
        if (value != null) {
          String googleSid = "gg" + value.id;

          if (await socialUserCheck(googleSid)) {
            var res = await UserRepository.socialLogin(googleSid);

            if (res) {
              String date =
                  "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
              await DurationRepository.durationRegist(date);
              UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
              pushNamedAndRemoveUntil(
                  context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
              appsflyer.saveLog(googleLoginLog);
              googleLoginIng = false;
              return true;
            } else {
              googleLoginIng = false;

              showDialog(
                  context: context,
                  child: BaseAlertDialog(
                      content: AppStrings.of(StringKey.social_login_fail),
                      onConfirm: () {}));
              return false;
            }
          } else {
            await socialSignUp(
                context: context,
                sid: googleSid,
                email: googleSid + "*" + value.email,
                socialType: 'GOOGLE');
            appsflyer.saveLog(googleSign);
            googleLoginIng = false;
            return true;
          }
        } else {
          print("Google Login Cancel");
        }
      });
    } catch (error) {
      googleLoginIng = false;
      print("Google Login Error : $error");
    }
  }
}

appleLogin(context) async {
  if (!appleLoginIng) {
    appleLoginIng = true;
    final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
            clientId: "com.neofect.connect.service",
            redirectUri:
                Uri.parse('${baseUrl}uaa/apple/callbacks/sign_in_with_apple')));

    Map<String, dynamic> decodeToken =
        JwtDecoder.decode(credential.identityToken);

    String appleSid = 'ap' + decodeToken['sub'];

    if (await socialUserCheck(appleSid)) {
      var res = await UserRepository.socialLogin(appleSid);

      if (res) {
        String date =
            "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
        await DurationRepository.durationRegist(date);
        UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
        pushNamedAndRemoveUntil(
            context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
        appsflyer.saveLog(appleLoginLog);
        appleLoginIng = false;
        return true;
      } else {
        appleLoginIng = false;

        showDialog(
            context: context,
            child: BaseAlertDialog(
                content: AppStrings.of(StringKey.social_login_fail),
                onConfirm: () {}));
        return false;
      }
    } else {
      await socialSignUp(
          context: context,
          sid: appleSid,
          email: appleSid + "*" + decodeToken['email'],
          socialType: 'APPLE');
      appsflyer.saveLog(appleSign);
      appleLoginIng = false;
      return true;
    }
    appleLoginIng = false;
    return false;
  }
}

socialUserCheck(sid) async {
  final result = await UserRepository.socialExist(sid);
  if (result) {
    return true;
  } else {
    return false;
  }
}

socialSignUp({context, email, sid, socialType}) async {
  var uuid = Uuid();
  String password = uuid.v1();

  var res = await UserRepository.socialSignUp(email, password, sid, socialType);

  if (res is ServiceError) {
    return false;
  }

  var loginRes = await UserRepository.socialLogin(sid);

  if (loginRes is ServiceError) {
    return false;
  } else if (loginRes as bool) {
    String date =
        "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
    await DurationRepository.durationRegist(date);
    UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
    pushNamedAndRemoveUntil(context, SplashPage.ROUTE_FIRST_LOGIN);
  }
}
