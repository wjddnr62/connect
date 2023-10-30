import 'dart:io';

import 'package:connect/connect_config.dart';
import 'package:connect/feature/app/force_update_guide_page.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/splash/intro_page.dart';
import 'package:connect/feature/splash/splash_bloc.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/feature/user/sign/sign_email_input_page.dart';
import 'package:connect/feature/user/sign/sign_up_select_page.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/common_widgets.dart';
import 'package:connect/widgets/pages/error_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../base_bloc.dart';

enum SplashStep {
  BeforeIntro,
  BeforeLogin,
  AfterLoginBeforeProfile,
  AfterLoginAfterProfile,
  FirstLogin
}

class SplashPage extends BlocStatefulWidget {
  final SplashStep step;

  static const ROUTE_BEFORE_INTRO = '/';
  static const ROUTE_BEFORE_LOGIN = '/splash_before_login';
  static const ROUTE_AFTER_LOGIN_BEFORE_PROFILE =
      '/splash_after_login_before_profile_page';
  static const ROUTE_AFTER_LOGIN_AFTER_PROFILE =
      '/splash_after_login_after_profile_page';
  static const ROUTE_FIRST_LOGIN = '/splash_first_login';

  SplashPage({this.step});

  @override
  BlocState buildState() => _SplashPageState(step: step);

  static Future<Object> pushAndRemoveUntil(BuildContext context, String name,
      {String params}) {
    return Navigator.of(context)
        .pushNamedAndRemoveUntil(name, (route) => false, arguments: params);
  }
}

class _SplashPageState extends BlocState<SplashBloc, SplashPage> {
  final _tag = '_SplashPageState';
  final SplashStep step;

  _SplashPageState({this.step}) : assert(step != null);

  @override
  blocBuilder(BuildContext context, state) {
    Log.d(_tag, 'state = $state');
    if (state is ShowNotificationPermission) {
      appsflyer.saveLog(notificationPermission);
      return Scaffold(
          backgroundColor: AppColors.white,
          body: Container(
              margin: EdgeInsets.only(
                  left: resize(16),
                  right: resize(16),
                  bottom: resize(32),
                  top: resize(88)),
              child: Column(children: [
                Container(
                    margin: EdgeInsets.only(left: resize(8), right: resize(8)),
                    child: Text(
                        AppStrings.of(StringKey.title_notification_permission),
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_large,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Container(
                    margin: EdgeInsets.only(
                        top: resize(24), left: resize(8), right: resize(8)),
                    child: Text(
                        AppStrings.of(
                            StringKey.description_notification_permission),
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            size: TextSize.body_medium,
                            weight: TextWeight.medium,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE))),
                Expanded(child: Container()),
                Container(
                    child: BottomButton(
                        text: AppStrings.of(StringKey.word_continue),
                        onPressed: () {
                          appsflyer.saveLog(notificationPopup);
                          UserLogger.logEventName(
                              eventName: EventPermission
                                  .PERMISSION_NOTIFICATION_REQUEST);
                          bloc.add(HandleNotification());
                        }))
              ])));
    }

    List<Widget> list = [];
    list.add(Container(
        margin: EdgeInsets.only(
            top: resize(260), left: resize(80), right: resize(80)),
        child: Image.asset(AppImages.img_logo_rehabit_black)));

    if (gFlavor != Flavor.PROD) {
      list.add(Expanded(
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                  'Production: $gProduction\nVersion Name : $gVersion\nVersion Code : $gBuildNumber',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.from(
                      height: 1.8,
                      color: AppColors.grey,
                      size: TextSize.caption_small,
                      weight: TextWeight.extrabold)))));

      list.add(SizedBox(height: resize(32)));
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: AppColors.transparent,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
          backgroundColor: AppColors.white, body: Column(children: list)),
    );
  }

  @override
  blocListener(BuildContext context, state) async {
    if (state is GotoEmailInputPage) {
      SignInputEmailPage.pushAndRemoveUntil(context);
      return;
    }

    // if (state is GotoInputProfilePage) {
    //   InputNamePage.pushAndRemoveUntil(context);
    //   return;
    // }

    if (state is GoHome) {
      // if (!await AppDao.welcomePageSkip)
      //   PaymentDescriptionPage.pushAndRemoveUntil(context, false);
      // else
      // HomeCalendarPage.pushAndRemoveUntil(context);
      HomeNavigation.pushAndRemoveUntil(context);
      return;
    }

    if (state is GotoIntroPage) {
      IntroPage.pushAndRemoveUntil(context);
      return;
    }

    if (state is GotoSelectPage) {
      SignUpSelectPage.pushAndRemoveUntil(context);
      return;
    }

    if (state is GotoPayment) {
      PaymentNoticePage.pushAndRemoveUntil(context,
          isNewHomeUser: state.isNewHomeUser, closeable: Platform.isAndroid);
      return;
    }

    if (state is GotoPaymentDescription) {
      bloc.add(HomeUserPayment());
    }

    if (state is GotoPaymentView) {
      if (state.isNewHomeUser) {
        bloc.add(HomeUserPayment());
      } else {
        appsflyer.saveLog(accountStart);
        HomeNavigation.pushAndRemoveUntil(context);
      }
    }

    if (state is HomeUserPaymentSuccess) {
      HomeNavigation.pushAndRemoveUntil(context);
    }

    if (state is ShowError) {
      ErrorPage.push(context, params: {
        ErrorPage.PARAM_KEY_ERROR: state.error,
        ErrorPage.PARAM_KEY_RETRY: () {
          SplashPage.pushAndRemoveUntil(context, SplashPage.ROUTE_BEFORE_INTRO);
        }
      });
      return;
    }

    if (state is ShowTerms) {
      ShowTermsPage.pushAndRemoveUntil(context,
          params: state.terms, showAgree: true);
      return;
    }

    if (state is GotoUpdate) {
      ForceUpdateGuidePage.pushAndRemoveUntil(context);
    }

    if (state is InitState) {}
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        appsflyer.saveLog(switchWindowSplash);
      }
      return null;
    });
  }

  @override
  SplashBloc initBloc() {
    SplashBloc _splashBloc = SplashBloc();
    switch (step) {
      case SplashStep.BeforeIntro:
        _splashBloc.add(InitApp());
        break;
      case SplashStep.BeforeLogin:
        _splashBloc.add(CheckLogin());
        break;
      case SplashStep.AfterLoginBeforeProfile:
        _splashBloc.add(InitService());
        break;
      case SplashStep.AfterLoginAfterProfile:
        _splashBloc.add(InitPersonalize());
        break;
      case SplashStep.FirstLogin:
        _splashBloc.add(InitService(firstLogin: true));
    }
    return _splashBloc;
  }
}
