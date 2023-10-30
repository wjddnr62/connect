import 'dart:async';
import 'dart:io';

import 'package:connect/data/app_repository.dart';
import 'package:connect/data/chat_repository.dart';
import 'package:connect/data/duration_repository.dart';
import 'package:connect/data/goal_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/remote/payment/payment_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/chat/sendbird_messaging_controller.dart';
import 'package:connect/feature/user/profile_info.dart';
import 'package:connect/models/chat.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/payment.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/user_log/events.dart';
import 'package:connect/user_log/user_properties.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/push/push_notification_handler.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:package_info/package_info.dart';
import 'package:pedometer/pedometer.dart';
import 'package:unique_ids/unique_ids.dart';

import '../../connect_config.dart';
import '../../connect_firebase.dart';

final gSendBirdMessagingController = SendBirdMessagingController();

class SplashBloc extends BaseBloc {
  final _tag = 'SplashBloc';

  SplashBloc() : super(_InitState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    /// 1. 앱이 launch 될 때,
    if (event is InitApp) {
      yield InitState();
      gBuildNumber = await _buildNumber;
      gVersion = await _appVersion;
      gAdId = await _adId;
      gPlatform = _platformType;
      gUuid = await AppDao.uuid;
      gFcmId = await _fcmId;

      // 심사 중 endpoint 변경.
      await AppRepository.onReview();

      await Future.wait([AppRepository.init(), UserProperties.userId()]);

      yield RefreshScreen();

      var shouldUpdate = await AppRepository.shouldUpdateApp();
      if (shouldUpdate is bool && shouldUpdate) {
        yield GotoUpdate();
        return;
      }

      /// 2. iOS 인 경우는 notification 사용을 위해서 permission 이 필요하다.
      if (Platform.isIOS) {
        add(CheckPermission());
      } else {
        add(HandleNotification());
      }
      return;
    }

    /// 2-1. iOS only
    if (event is CheckPermission) {
      PermissionStatus permissionStatus =
          await NotificationPermissions.getNotificationPermissionStatus();

      if (permissionStatus == PermissionStatus.unknown) {
        yield ShowNotificationPermission();
        return;
      }
      add(HandleNotification());
      return;
    }

    /// 3. notification 초기화 (push, in-app notification.)
    if (event is HandleNotification) {
      //알림 권한창 이후에 fcmId를 가져오도록 한다. 이전에 호출시에 잘못된 fcmId 정보를 가져온다.
      gFcmId = await _fcmId;
      PushNotificationHandler pushNotificationHandler =
          PushNotificationHandler();

      await pushNotificationHandler.initializeLocalNotification();
      pushNotificationHandler.configurePushMessaging();

      yield RefreshScreen();
      add(_CheckIntroSkip());
      return;
    }

    if (event is _CheckIntroSkip) {
      if (await AppDao.introSkip) {
        add(CheckLogin());
      } else {
        // yield GotoIntroAnimationPage();
        appsflyer.saveLog(splashPage);
        yield GotoIntroPage();
        return;
      }
    }

    /// 4. 토큰으로 로그인 가능한 유저인지 확인한다.
    if (event is CheckLogin) {
      String accessToken = await AppDao.accessToken;
      if (accessToken == null || accessToken.isEmpty) {
        /// 앱이 로그아웃 되어 있는 상태
        /// Go to login screen.
        yield GotoSelectPage();
      } else {
        String date =
            "${DateTime.now().year}-${DateTime.now().month.toString().length == 1 ? "0" + DateTime.now().month.toString() : DateTime.now().month}-${DateTime.now().day.toString().length == 1 ? "0" + DateTime.now().day.toString() : DateTime.now().day}";
        await DurationRepository.durationRegist(date);
        add(InitService());
      }
      return;
    }

    /// 5. 로그 인 후 서비스 초기화
    if (event is InitService) {
      /// TODO - 로그인 후 세팅되어야 하는 작업들.

      /// 기존에 로그인 되어 있는 상태
      var profile = await UserRepository.getProfile();

      if (profile is ServiceError) {
        yield ShowError(error: profile);
      }

      if (profile is Profile) {
        // if (profile.name == null || profile.name.isEmpty) {
        /// 케어기버와 환자의 프로파일 입력 과정이 다르므로....
        // SignInfo.instance.role = profile.type;
        // yield (GotoInputProfilePage());
        // } else {
        yield* initWithProfile(profile, firstLogin: event.firstLogin);
        // }
      } else {
        yield ShowError(
            error: ServiceError(code: 'unknown', message: 'unknow error'));
      }
    }

    /// 6. 로그인 후 프로파일 입력 후 서비스 초기화.
    if (event is InitPersonalize) {
      /// add residence, dominant hand, diagnostic name
      var profile = Profile(
        name: ProfileInfo.instance.name,
        gender: ProfileInfo.instance.gender,
        birthday: ProfileInfo.instance.birthday,
        onsetDate: ProfileInfo.instance.onsetDate,
        infectedSide: ProfileInfo.instance.affectedSide,
        usStateCode: ProfileInfo.instance.usStateCode,
        diagnosticName: ProfileInfo.instance.diagnosticName,
        dominantHand: ProfileInfo.instance.dominantHand,
      );

      var response = await UserRepository.updateProfile(profile);
      if (response is ServiceError) {
        yield ShowError(error: response);
        return;
      }
      //신규회원에게 무료서비스를 제공하는지 확인하기 위해 프로필 조회가 필요함
      add(InitService());
    }

    if (event is HomeUserPayment) {
      yield HomeUserPaymentSubscribing();

      dynamic response = await NeofectPaymentService().start();

      if (response is ServiceError) {
        ServiceError error = response;
        yield HomeUserPaymentFailure(message: error.message);
        return;
      }

      if (response is PaymentResult) {
        Log.d("paymentResult : ",
            "success to verify payment : " + response.toString());
      }

      appsflyer.saveLog(accountStart);
      await UserRepository.getProfile();
      yield HomeUserPaymentSuccess();
    }
  }

  Stream<BaseBlocState> initWithProfile(Profile profile,
      {bool firstLogin}) async* {
    UserProperties.userProperties(profile);

    /// TODO init something needing profile

    /// Send fcm id
    await AppRepository.updateFcm(uuid: gUuid, fcmToken: gFcmId);

    if (profile?.clinicStatus?.current?.id == -1) {
      ProfileInfo.chatEnable = true;
    } else {
      ProfileInfo.chatEnable = false;
    }

    /// init sendbird
    if (ProfileInfo.chatEnable) {
      gSendBirdMessagingController.init(gSendBirdAppId);

      var userId = await AppDao.userId;
      var strokeCoachId = await AppDao.strokeCoachId;
      var userName = await AppDao.nickname;
      if (gFcmId != null) {
        ChatRepository.getTextChatToken().then((token) async {
          final accessToken = (token as ChatToken).accessToken;
          if (strokeCoachId != null) {
            await gSendBirdMessagingController.connectAndJoin(userId.toString(),
                userName, accessToken, gFcmId, strokeCoachId.toString());
          } else {
            gSendBirdMessagingController.connectAndRegisterPushToken(
                userId.toString(), accessToken, gFcmId);
          }
        });
      }
    }

    if (profile?.isNewHomeUser == true) {
      var res = await GoalRepository.getGoalUserData();
      if (res != null) {
        yield GotoPaymentDescription();
      } else {
        yield GotoPaymentView(isNewHomeUser: true);
      }
    } else if (firstLogin != null && firstLogin) {
      yield GotoPaymentView(isNewHomeUser: false);
    } else {
      yield GoHome();
    }
  }
}

class _InitState extends BaseBlocState {
  @override
  String get tag => EventCommon.OPEN_APP;
}

/// 앱이 시작하면 수행되는 작업들 처리
class InitApp extends BaseBlocEvent {}

class InitState extends BaseBlocState {}

class RefreshScreen extends BaseBlocState {}

class CheckPermission extends BaseBlocEvent {}

class ShowNotificationPermission extends BaseBlocState {
  @override
  String get tag => EventPermission.PERMISSION_NOTIFICATION_SHOW_GUIDE;
}

class HandleNotification extends BaseBlocEvent {}

class CheckLogin extends BaseBlocEvent {}

class GotoEmailInputPage extends BaseBlocState {}

class GotoInputProfilePage extends BaseBlocState {}

class GotoIntroPage extends BaseBlocState {}

class GotoSelectPage extends BaseBlocState {}

class GotoIntroAnimationPage extends BaseBlocState {}

/// 로그인 후 프로파일 입력 전 수행되는 작업들 처리
class InitService extends BaseBlocEvent {
  final bool firstLogin;

  InitService({this.firstLogin});
}

/// 로그인 후 프로파일 입력 후 수행되는 작업들 처리
class InitPersonalize extends BaseBlocEvent {}

class SignupWithEmailId extends BaseBlocEvent {}

class LoginWithEmailId extends BaseBlocEvent {}

class ShowTerms extends BaseBlocState {
  final dynamic terms;

  ShowTerms({this.terms});
}

class GotoPayment extends BaseBlocState {
  final bool isNewHomeUser;

  GotoPayment({this.isNewHomeUser = false});
}

class GotoPaymentDescription extends BaseBlocState {}

class GotoPaymentView extends BaseBlocState {
  final bool isNewHomeUser;

  GotoPaymentView({this.isNewHomeUser = false});
}

class GotoUpdate extends BaseBlocState {}

// 인트로 출력 여부 확인
class _CheckIntroSkip extends BaseBlocEvent {}

class HomeUserPayment extends BaseBlocEvent {}

class HomeUserPaymentSubscribing extends BaseBlocState {}

class HomeUserPaymentFailure extends BaseBlocState {
  final String message;

  HomeUserPaymentFailure({this.message});
}

class HomeUserPaymentSuccess extends BaseBlocState {}

/* [START] Splash에서 Config 초기화 */
Future<String> get _versionName async {
  var packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<String> get _buildNumber async {
  var packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.buildNumber;
}

String get _platformType {
  String type = 'none';
  if (Platform.isAndroid) {
    type = 'android';
  } else if (Platform.isIOS) {
    type = 'ios';
  }
  return type;
}

Future<String> get _appVersion async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
}

Future<String> get _adId async => await UniqueIds.adId;

Future<String> get _fcmId async {
  String ret = await gFirebaseMessaging.getToken();
  Log.d('device', 'fcmId = $ret');
  return ret;
}
/* [END] Splash 에서 Config 초기화 */
