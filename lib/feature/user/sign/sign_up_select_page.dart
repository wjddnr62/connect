import 'dart:io';

import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/remote/user/get_terms_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/feature/user/login/login_page.dart';
import 'package:connect/feature/user/sign/sign_up_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/social_login.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../connect_config.dart';
import 'sign_up_select_bloc.dart';

class SignUpSelectPage extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/sign_up_select_page';

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(ROUTE_NAME, (route) => false);
  }

  static Future<Object> push(BuildContext context) {
    return Navigator.of(context).pushNamed(ROUTE_NAME);
  }

  @override
  _SignUpSelectState buildState() => _SignUpSelectState();
}

class _SignUpSelectState extends BlocState<SignUpSelectBloc, SignUpSelectPage> {
  String privacyText = "By continuing,You agree to Rehabit’s";
  String termsAndConditions = "Terms & Conditions";
  String privacyPolicy = "Privacy Policy";

  neofectLogo(context) {
    return Image.asset(
      AppImages.img_logo_rehabit_black,
      width: resize(146),
      height: resize(32),
    );
  }

  privacyContent(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            privacyText,
            style: AppTextStyle.from(
                size: TextSize.caption_small, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          emptySpaceH(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  ShowTermsPage.pushViewing(context, type: TermsType.TERMS);
                },
                child: Text(
                  termsAndConditions,
                  style: AppTextStyle.from(
                      size: TextSize.caption_small, color: AppColors.purple),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "and ",
                style: AppTextStyle.from(
                    size: TextSize.caption_small, color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  ShowTermsPage.pushViewing(context,
                      type: TermsType.PRIVACY_POLICY);
                },
                child: Text(
                  privacyPolicy,
                  style: AppTextStyle.from(
                    size: TextSize.caption_small,
                    color: AppColors.purple,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  signUpNeofectAccount(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(neofectSelect);
          SignUpPage.push(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.purple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.ic_sign_mail,
                  width: resize(24),
                  height: resize(24),
                ),
                emptySpaceW(width: 16),
                Text(
                  AppStrings.of(StringKey.make_a_neofect_account),
                  style: AppTextStyle.from(
                      color: AppColors.white,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        ));
  }

  signUpFacebook(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(facebookSelect);
          facebookLogin(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(
              color: AppColors.lightGrey04
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.ic_sign_facebook,
                  width: resize(24),
                  height: resize(24),
                ),
                emptySpaceW(width: 16),
                Text(
                  AppStrings.of(StringKey.continue_with_facebook),
                  style: AppTextStyle.from(
                      color: AppColors.black,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
        ));
  }

  signUpApple(context) {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(appleSelect);
          if (Platform.isIOS) {
            appleLogin(context);
          } else {
            bloc.add(AppleLoginEvent(type: 0));
          }
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.ic_sign_apple,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 16),
              Text(
                AppStrings.of(StringKey.continue_with_apple),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_large,
                    weight: TextWeight.semibold),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ));
  }

  neofectAccountLogin(context) {
    return GestureDetector(
      onTap: () {
        LoginPage.pushAndRemoveUntil(context);
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.of(StringKey.have_a_neofect_account),
              style: AppTextStyle.from(
                  color: AppColors.darkGrey, size: TextSize.caption_medium),
            ),
            emptySpaceW(width: 8),
            Text(
              "Login",
              style: AppTextStyle.from(
                  decoration: TextDecoration.underline,
                  size: TextSize.caption_medium,
                  color: AppColors.darkGrey,
                  weight: TextWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  signUpGoogle() {
    return ElevatedButton(
        onPressed: () {
          appsflyer.saveLog(googleSelect);
          googleLogin(context);
        },
        style: ElevatedButton.styleFrom(
            primary: AppColors.white,
            side: BorderSide(color: AppColors.lightGrey04, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 54,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.ic_sign_google,
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 16),
              Text(
                AppStrings.of(StringKey.continue_with_google),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_large,
                    weight: TextWeight.semibold),
                textAlign: TextAlign.left,
              )
            ],
          ),
        ));
  }

  _buildMain(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        emptySpaceH(height: 86),
        neofectLogo(context),
        emptySpaceH(height: 40),
        privacyContent(context),
        emptySpaceH(height: 24),
        signUpApple(context),
        emptySpaceH(height: 12),
        signUpGoogle(),
        emptySpaceH(height: 12),
        signUpFacebook(context),
        emptySpaceH(height: 12),
        signUpNeofectAccount(context),
        emptySpaceH(height: 100),
        neofectAccountLogin(context),
        emptySpaceH(height: 40)
      ],
    );
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    // TODO: implement blocBuilder
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () {
            if (bloc.appleWeb) {
              bloc.add(AppleLoginEvent(type: 1));
            } else {
              if (Platform.isAndroid) {
                SystemChannels.platform
                    .invokeMethod<void>('SystemNavigator.pop');
              }
            }
            return null;
          },
          child: SafeArea(
              top: false,
              child: AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                    statusBarColor: AppColors.transparent,
                    statusBarIconBrightness: Brightness.dark),
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: AppColors.lightGrey01,
                  body: Stack(
                    children: [
                      NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowGlow();
                          return true;
                        },
                        child: SingleChildScrollView(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.only(
                                left: resize(24), right: resize(24)),
                            child: _buildMain(context),
                          ),
                        ),
                      ),
                      bloc.appleWeb ? appleWebPage() : Container(),
                      buildProgress(context)
                    ],
                  ),
                ),
              )),
        );
      },
    );
  }

  buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  appleWebPage() {
    return WebView(
      javascriptMode: JavascriptMode.unrestricted,
      initialUrl:
          "https://appleid.apple.com/auth/authorize?response_type=code%20id_token&response_mode=form_post&client_id=com.neofect.connect.service&scope=name%20email&redirect_uri=${baseUrl}uaa/apple/callbacks/sign_in_with_apple",
      onPageStarted: (url) async {
        if (url !=
            "https://appleid.apple.com/auth/authorize?response_type=code%20id_token&response_mode=form_post&client_id=com.neofect.connect.service&scope=name%20email&redirect_uri=${baseUrl}uaa/apple/callbacks/sign_in_with_apple") {
          bloc.add(AppleLoginEvent(type: 1));
        }
        if (url.contains("intent")) {
          bloc.add(StartLoadingEvent());
          String idToken = url.split("&")[1].split('#')[0].split('=')[1];

          Map<String, dynamic> decodeToken = JwtDecoder.decode(idToken);

          String appleSid = 'ap' + decodeToken['sub'];

          if (await socialUserCheck(appleSid)) {
            var res = await UserRepository.socialLogin(appleSid);

            if (res) {
              String date =
                  "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
              await DurationRepository.durationRegist(date);
              UserLogger.logEventName(eventName: EventSign.LOGIN_COMPLETE);
              bloc.add(StopLoadingEvent());
              pushNamedAndRemoveUntil(
                  context, SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE);
            }
          } else {
            await socialSignUp(
                context: context,
                sid: appleSid,
                email: appleSid + "*" + decodeToken['email'],
                socialType: 'APPLE');
            bloc.add(StopLoadingEvent());
          }
        }
      },
    );
  }

  @override
  blocListener(BuildContext context, state) {}

  @override
  initBloc() {
    // TODO: implement initBloc
    return SignUpSelectBloc(context)..add(SignUpSelectInitEvent());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    appsflyer.saveLog(selectPage);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        appsflyer.saveLog(switchWindowSelect);
      }
      return null;
    });
  }
}
