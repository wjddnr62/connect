import 'dart:async';
import 'dart:io';

import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/chat/sendbird_messaging_controller.dart';
import 'package:connect/feature/chat/text/text_chat_page.dart';
import 'package:connect/feature/current_status/current_status_page.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/feature/my_report/my_report_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/push/push_notification_handler.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../connect_app.dart';
import 'home_navigation_bloc.dart';

class HomeNavigation extends BlocStatefulWidget {
  static const String ROUTE_NAME = '/home_navigation';

  static Future<Object> pushAndRemoveUntil(BuildContext context) {
    return Navigator.of(context).pushNamedAndRemoveUntil(
      ROUTE_NAME,
      (route) => false,
    );
  }

  static void popUntil(BuildContext context) {
    Navigator.of(context).popUntil((predicate) {
      if (predicate.settings.name == ROUTE_NAME) {
        return true;
      }
      return false;
    });
  }

  @override
  _HomeNavigation buildState() => _HomeNavigation();
}

class _HomeNavigation extends BlocState<HomeNavigationBloc, HomeNavigation> {
  int checkTime = 0;
  Timer timer;
  final gSendBirdMessagingController = SendBirdMessagingController();
  StreamSubscription<PushNotification> _notificationClickActionSubscription;

  setView() {
    switch (bloc.selectedIndex) {
      case 0:
        return HomeCalendarPage(
          bloc: bloc,
          missions: bloc.missions,
          diaryChecks: bloc.diaryChecks,
          diaryRemove: bloc.diaryRemove,
          trackerCheck: bloc.trackerChecks,
        );
      case 1:
        return MyReportPage(bloc: bloc);
      case 2:
        appsflyer.saveLog(chatting);
        return TextChatPage(bloc: bloc);
      case 3:
        return MyReportPage(bloc: bloc, diary: true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _notificationClickActionSubscription = PushNotificationHandler()
        .notificationClickReceiver
        .listen((pushNotification) {
      _onPushNotificationClicked(context, pushNotification);
    });

    appsflyer.saveLog(mainHomePage);
    SystemChannels.lifecycle.setMessageHandler((msg) {
      if (msg == AppLifecycleState.paused.toString()) {
        appsflyer.saveLog(switchWindowHome);
      }
      return null;
    });
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (checkTime == 180) {
        timer.cancel();
      }
      checkTime += 1;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
    super.dispose();
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () async {
              showDialog(
                  context: context,
                  child: BaseAlertDialog(
                    content:
                        AppStrings.of(StringKey.are_you_sure_you_want_to_exit),
                    cancelable: true,
                    onConfirm: () {
                      if (checkTime < 180) {
                        appsflyer.saveLog(threeMin);
                        timer.cancel();
                      }
                      SystemNavigator.pop();
                    },
                  ));
              return false;
            },
            child: Container(
              color: AppColors.white,
              child: SafeArea(
                top: false,
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  backgroundColor: AppColors.white,
                  bottomNavigationBar: SizedBox(
                    height: resize(50),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1,
                          color: AppColors.grey40,
                        ),
                        SizedBox(
                          height: resize(49),
                          child: BottomNavigationBar(
                            type: BottomNavigationBarType.fixed,
                            backgroundColor: AppColors.white,
                            elevation: 0,
                            selectedItemColor: AppColors.black,
                            unselectedItemColor: AppColors.grey,
                            selectedLabelStyle: AppTextStyle.from(
                                weight: TextWeight.bold,
                                size: TextSize.bottom_navigation),
                            unselectedLabelStyle: AppTextStyle.from(
                                weight: TextWeight.bold,
                                size: TextSize.bottom_navigation),
                            currentIndex: bloc.selectedIndex == 3
                                ? 1
                                : bloc.selectedIndex,
                            onTap: (index) {
                              bloc.add(ChangeViewEvent(changeIndex: index));
                            },
                            items: [
                              BottomNavigationBarItem(
                                  icon: Image.asset(
                                    AppImages.ic_mission,
                                    width: resize(24),
                                    height: resize(24),
                                  ),
                                  activeIcon: Image.asset(
                                    AppImages.ic_mission_focus,
                                    width: resize(24),
                                    height: resize(24),
                                  ),
                                  label: AppStrings.of(StringKey.mission)
                                      .toString()),
                              BottomNavigationBarItem(
                                  icon: Image.asset(
                                    AppImages.ic_my_report,
                                    width: resize(24),
                                    height: resize(24),
                                  ),
                                  activeIcon: Image.asset(
                                    AppImages.ic_my_report_focus,
                                    width: resize(24),
                                    height: resize(24),
                                  ),
                                  label: AppStrings.of(StringKey.my_report)
                                      .toString()),
                              BottomNavigationBarItem(
                                  icon: StreamBuilder<int>(
                                      initialData: 0,
                                      stream: gSendBirdMessagingController
                                          .onUnreadMessageCountReceived,
                                      builder:
                                          (BuildContext context, snapshot) {
                                        return snapshot.data <= 0
                                            ? Image.asset(
                                                AppImages.ic_comment,
                                                width: resize(24),
                                                height: resize(24),
                                              )
                                            : Image.asset(
                                                AppImages.ic_comment_alarm,
                                                width: resize(24),
                                                height: resize(24),
                                              );
                                      }),
                                  activeIcon: Image.asset(
                                    AppImages.ic_comment_focus,
                                    width: resize(24),
                                    height: resize(24),
                                  ),
                                  label: AppStrings.of(StringKey.chatting)
                                      .toString())
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  body: SingleChildScrollView(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.bottom -
                          resize(50),
                      child: setView(),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is HomeNavigationInitState) {
      var pushNotificationOnLaunch =
          PushNotificationHandler().getAndRemovePushNotificationOnLaunch();
      if (pushNotificationOnLaunch != null) {
        _onPushNotificationClicked(context, pushNotificationOnLaunch);
      }
    }
  }

  void _onPushNotificationClicked(
      BuildContext context, PushNotification pushNotification) {
    if (pushNotification?.type?.isNotEmpty == true) {
      switch (pushNotification.type) {
        case NotificationType.connect_advice_msg_arrive:
        case NotificationType.connect_mission_advice_daily:
        case NotificationType.connect_mission_current_status_daily:
          // CurrentStatusPage.push(context);
          bloc.add(ChangeViewEvent(changeIndex: 1));
          break;
        case NotificationType.connect_mission_arrived_daily:
        case NotificationType.connect_recommend_diary:
          HomeNavigation.popUntil(context);
          break;
        case NotificationType.portal_patient_assign:
          ProfilePage.push(context);
          break;
        case NotificationType.sendbird_messasing:
          // TextChatPage.push(context);
          bloc.add(ChangeViewEvent(changeIndex: 2));
          break;
      }
    }
  }

  @override
  initBloc() {
    return HomeNavigationBloc(context)..add(HomeNavigationInitEvent());
  }
}
