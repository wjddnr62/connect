import 'package:connect/data/remote/base_service.dart';
import 'package:flutter/services.dart';

class Appsflyer {
  factory Appsflyer() => _instance;

  static final Appsflyer _instance =
      Appsflyer.init(const MethodChannel('appsflyer/method_channel'));

  final MethodChannel _methodChannel;

  Appsflyer.init(MethodChannel methodChannel) : _methodChannel = methodChannel;

  Future<void> saveLog(String saveLog) async {
    if (gProduction == "prod-release" && kReleaseMode) {
      await _methodChannel.invokeMethod('saveLog', <String, dynamic>{
        'saveLog': saveLog,
      });
    }
  }
}

final appStart = "INTRO_SELECT_START";
final survey = "SURVEY_COMPLETE";
final accountStart = "SIGNUP_COMPLETE_TOTAL";
final evalStart = "EVAL_START_AFTERPAYMENT";
final evalDone = "EVAL_COMPLETE";
final getEvaluation = "7_get_evaluation";
final diary = "MAIN_SELECT_DIARY";
final chatting = "CHAT_VIEW";
final threeMin = "MAIN_EXIT_3MIN";
final useScroll = "MAIN_SCROLL_MISSION";
final missionLoad = "1ST_MISSION_LOAD";
final tutorialMission = "TUTORIAL_SELECT_MISSION";

final splashPage = "SPLASH_VIEW";
final notificationPermission = "NOTI-PERMISSION_VIEW";
final notificationPopup = "NOTI-POPUP_SELECT_PERMIT";
final introPage = "INTRO_VIEW";
final selectPage = "SIGNUP_VIEW";
final loginPage = "LOGIN_VIEW";
final facebookSelect = "SELECT_FB";
final appleSelect = "SELECT_AP";
final googleSelect = "SELECT_GG";
final signNeofect = "SELECT_NF";
final facebookLoginLog = "LOGIN_COMPLETE_FB";
final appleLoginLog = "LOGIN_COMPLETE_AP";
final googleLoginLog = "LOGIN_COMPLETE_GG";
final facebookSign = "SIGNUP_COMPLETE_FB";
final appleSign = "SIGNUP_COMPLETE_AP";
final googleSign = "SIGNUP_COMPLETE_GG";
final mainHomePage = "MAIN_VIEW";

final neofectSelect = "LOGIN_SELECT_NF";
final neofectLogin = "LOGIN_COMPLETE_NF";
final neofectSign = "SIGNUP_COMPLETE_NF";
final additionalMissionComplete = "COMPLETE_ADDITIONALMS";

final switchWindowSplash = "SPLASH_SWITCH_BG";
final switchWindowIntro = "INTRO_SWITCH_BG";
final switchWindowSelect = "SIGNUP_SWITCH_BG";
final switchWindowLogin = "LOGIN_SWITCH_BG";
final switchWindowHome = "MAIN_SWITCH_BG";

final paymentVipcontents = "PAYMENT_VIPCONTENTS";
final paymentProfile = "PAYMENT_PROFILE";
final paymentEmoji = "PAYMENT_EMOJI";
final paymentAdvice = "PAYMENT_REPORT_ADVICE";
final paymentGeteval = "PAYMENT_REPORT_GETEVAL";
final paymentEvalutaion = "PAYMENT_REPORT_EVALTREND";

final appsflyer = Appsflyer();
