import 'dart:io';

import 'package:connect/feature/app/force_update_guide_page.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/chat/text/stroke_coach_info_page.dart';
import 'package:connect/feature/chat/text/text_chat_page.dart';
import 'package:connect/feature/current_status/current_status_page.dart';
import 'package:connect/feature/diary/diary_page.dart';
import 'package:connect/feature/evaluation/evaluation_page.dart';
import 'package:connect/feature/mission/activity_mission_page.dart';
import 'package:connect/feature/mission/card_reading_mission_page.dart';
import 'package:connect/feature/mission/exercise_basics_mission_page.dart';
import 'package:connect/feature/mission/video_mission_page.dart';
import 'package:connect/feature/payment/payment_description_page.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/settings/contributor_page.dart';
import 'package:connect/feature/settings/settings_page.dart';
import 'package:connect/feature/splash/intro_animation_page.dart';
import 'package:connect/feature/splash/intro_page.dart';
import 'package:connect/feature/splash/splash_page.dart';
import 'package:connect/feature/user/account/account_page.dart';
import 'package:connect/feature/user/account/connect_clinic_page.dart';
import 'package:connect/feature/user/account/show_terms_page.dart';
import 'package:connect/feature/user/goal/goal_page.dart';
import 'package:connect/feature/user/login/login_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/feature/user/sign/password_create_page.dart';
import 'package:connect/feature/user/sign/password_input_page.dart';
import 'package:connect/feature/user/sign/sign_email_input_page.dart';
import 'package:connect/feature/user/sign/sign_up_select_page.dart';
import 'package:connect/utils/system_ui_overlay.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'feature/home/home_calendar.dart';
import 'feature/notification/notification_list_page.dart';
import 'feature/user/password/forgot_password_page.dart';
import 'feature/user/password/password_reset_guide_page.dart';
import 'feature/user/sign/password_confirm_page.dart';
import 'feature/user/sign/sign_up_page.dart';
import 'feature/user/sign/sign_verifying_email_page.dart';
import 'widgets/pages/error_page.dart';

Map<String, WidgetBuilder> routes(BuildContext context) => {
      SplashPage.ROUTE_BEFORE_INTRO: (context) =>
          SplashPage(step: SplashStep.BeforeIntro),
      SplashPage.ROUTE_BEFORE_LOGIN: (context) =>
          AnnotatedRegion<SystemUiOverlayStyle>(
              value: Platform.isAndroid
                  ? videoSystemUIOverlay
                  : commonSystemUIOverlay,
              child: SplashPage(step: SplashStep.BeforeLogin)),
      SplashPage.ROUTE_AFTER_LOGIN_BEFORE_PROFILE: (context) =>
          SplashPage(step: SplashStep.AfterLoginBeforeProfile),
      SplashPage.ROUTE_AFTER_LOGIN_AFTER_PROFILE: (context) =>
          SplashPage(step: SplashStep.AfterLoginAfterProfile),
      SplashPage.ROUTE_FIRST_LOGIN: (context) => SplashPage(
            step: SplashStep.FirstLogin,
          ),
      IntroPage.ROUTE_NAME: (context) => IntroPage(),
      IntroAnimationPage.ROUTE_NAME: (context) => IntroAnimationPage(),
      SignUpSelectPage.ROUTE_NAME: (context) => SignUpSelectPage(),
      SignUpPage.ROUTE_NAME: (context) => SignUpPage(),
      SignInputEmailPage.ROUTE_NAME: (context) => SignInputEmailPage(),
      HomeCalendarPage.ROUTE_NAME: (context) => HomeCalendarPage(),
      ForceUpdateGuidePage.ROUTE_NAME: (context) => ForceUpdateGuidePage(),
      ErrorPage.ROUTE_NAME: (context) => ErrorPage(),
      PasswordInputPage.ROUTE_NAME: (context) => PasswordInputPage(),
      SignVerifyingEmailPage.ROUTE_NAME: (context) => SignVerifyingEmailPage(),
      ConnectClinicPage.ROUTE_NAME: (context) => ConnectClinicPage(),
      SettingsPage.ROUTE_NAME: (context) => SettingsPage(),
      ShowTermsPage.ROUTE_NAME: (context) => ShowTermsPage(),
      PasswordResetGuidePage.ROUTE_NAME: (context) => PasswordResetGuidePage(),
      PasswordConfirmPage.ROUTE_NAME: (context) => PasswordConfirmPage(),
      PasswordCreatePage.ROUTE_NAME: (context) => PasswordCreatePage(),
      ProfilePage.ROUTE_NAME: (context) => ProfilePage(),
      StrokeCoachInfoPage.ROUTE_NAME: (context) => StrokeCoachInfoPage(),
      NotificationListPage.ROUTE_NAME: (context) => NotificationListPage(),
      TextChatPage.ROUTE_NAME: (context) => TextChatPage(),
      CurrentStatusPage.ROUTE_NAME: (context) => CurrentStatusPage(),
      AccountPage.ROUTE_NAME: (context) => AccountPage(),
      ActivityMissionPage.ROUTE_NAME: (context) => ActivityMissionPage(),
      ExerciseBasicsMissionPage.ROUTE_NAME: (context) =>
          ExerciseBasicsMissionPage(),
      VideoMissionPage.ROUTE_NAME: (context) => VideoMissionPage(),
      CardReadingMissionPage.ROUTE_NAME: (context) => CardReadingMissionPage(),
      PaymentNoticePage.ROUTE_NAME: (context) => PaymentNoticePage(),
      EvaluationPage.ROUTE_NAME: (context) => EvaluationPage(),
      ContributorPage.ROUTE_NAME: (context) => ContributorPage(),
      LoginPage.ROUTE_NAME: (context) => LoginPage(),
      PaymentDescriptionPage.ROUTE_NAME: (context) => PaymentDescriptionPage(),
      ForgotPasswordPage.ROUTE_NAME: (context) => ForgotPasswordPage(),
      GoalPage.ROUTE_NAME: (context) => GoalPage(),
      DiaryPage.ROUTE_NAME: (context) => DiaryPage(),
      HomeNavigation.ROUTE_NAME: (context) => HomeNavigation(),
    };
