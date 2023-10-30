import 'dart:io';
import 'dart:math';

import 'dart:async';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/mission/mission_service.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bookmark/bookmark_page.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/diary/diary_page.dart';
import 'package:connect/feature/evaluation/evaluation_page.dart';
import 'package:connect/feature/home/MissionProvider.dart';
import 'package:connect/feature/home/home_bloc.dart';
import 'package:connect/feature/mission/card_reading_mission_page.dart';
import 'package:connect/feature/mission/common_mission_bloc.dart';
import 'package:connect/feature/mission/common_mission_item.dart';
import 'package:connect/feature/mission/mission_list_footer_item.dart';
import 'package:connect/feature/mission/mission_title_item.dart';
import 'package:connect/feature/notification/notification_list_page.dart';
import 'package:connect/feature/tracker/tracker_page.dart';
import 'package:connect/feature/tracker/tracker_setting_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/feature/user/profile/user_profile_page.dart';
import 'package:connect/models/diary.dart';

import 'package:connect/models/missions.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/models/trackerChecks.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';

import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/utils/extensions.dart';
import 'package:connect/utils/push/push_notification_handler.dart';

import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:connect/widgets/dialog/start_evaluation_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:provider/provider.dart';
import 'home_calendar_day_item.dart';

class HomeCalendarPage extends BasicStatefulWidget {
  static const String ROUTE_NAME = '/home_page';

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

  final HomeNavigationBloc bloc;
  final List<MissionRenewal> missions;
  final List<DiaryChecks> diaryChecks;
  final List<String> diaryRemove;
  final List<TrackerChecks> trackerCheck;

  HomeCalendarPage(
      {this.bloc,
      this.missions,
      this.diaryChecks,
      this.diaryRemove,
      this.trackerCheck});

  @override
  BasicState<BasicStatefulWidget> buildState() => _State();
}

class _State extends BasicState<HomeCalendarPage> with RouteAware {
  HomeBloc bloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  StreamSubscription<PushNotification> _notificationClickActionSubscription;

  final missionListController = ScrollController();

  @override
  void initState() {
    super.initState();

    _notificationClickActionSubscription = PushNotificationHandler()
        .notificationClickReceiver
        .listen((pushNotification) {
      _onPushNotificationClicked(context, pushNotification);
    });
  }

  Timer gestureTimer;
  bool inGestureAnimation = false;

  gestureAnimation() async {
    if (!inGestureAnimation) {
      inGestureAnimation = true;
      // if (!await AppDao.tutorialGesture)
      gestureTimer = Timer.periodic(Duration(milliseconds: 1200), (timer) {
        bloc.add(GestureChangeEvent());
      });
    }
  }

  tutorialTap() {
    return GestureDetector(
      onTap: () async {
        Mission mission = bloc.firstMission;
        bloc.isLoadingView = true;
        bloc.add(LoadingEvent());
        MissionDetail missionDetail =
            await GetMissionDetailService(missionId: mission.id).start();
        gestureTimer.cancel();

        await AppDao.setTutorialGesture(true);
        bloc.tutorialGesture = true;
        bloc.isLoadingView = false;
        setState(() {});
        appsflyer.saveLog(tutorialMission);

        CardReadingMissionPage.push(context,
                bloc: CommonMissionBloc(context,
                    date: bloc.getDate(bloc.pageIndex),
                    mission: mission,
                    missionDetail: missionDetail))
            .then((value) {
          bloc.completed = value;
          if (value ?? false) {
            appsflyer.saveLog(additionalMissionComplete);
          }
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColors.blackA80,
        padding: EdgeInsets.only(left: resize(24), right: resize(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            emptySpaceH(height: 68),
            Text(
              "The first step\nto change your life!",
              style: AppTextStyle.from(
                  size: TextSize.title_medium,
                  height: 1.7,
                  color: AppColors.white,
                  decoration: TextDecoration.none),
              textAlign: TextAlign.center,
            ),
            emptySpaceH(height: 44),
            Container(
              width: MediaQuery.of(context).size.width,
              height: resize(90),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey04),
                  boxShadow: [
                    BoxShadow(
                        color: Color(0xFF000000),
                        blurRadius: 20,
                        offset: Offset(0, 0))
                  ]),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  emptySpaceW(width: 10),
                  Image.asset(
                    AppImages.illust_reading,
                    width: resize(70),
                    height: resize(76),
                  ),
                  emptySpaceW(width: 8),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      emptySpaceH(height: 15),
                      Text(
                        "Click here to start!",
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            size: TextSize.caption_medium,
                            weight: TextWeight.extrabold,
                            height: 1.4,
                            decoration: TextDecoration.none),
                      ),
                      emptySpaceH(height: 4),
                      Text(
                        "Reading",
                        style: AppTextStyle.from(
                            color: AppColors.grey,
                            size: TextSize.caption_small,
                            weight: TextWeight.bold,
                            decoration: TextDecoration.none),
                      ),
                      emptySpaceH(height: 15)
                    ],
                  )
                ],
              ),
            ),
            emptySpaceH(height: 16),
            Container(
              width: MediaQuery.of(context).size.width,
              height: resize(90),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    top: resize(bloc.gestureUpDown ? 0 : 20),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: resize(70),
                      child: Image.asset(
                        AppImages.hand_gesture,
                        color: AppColors.white,
                      ),
                    ),
                    duration: Duration(milliseconds: 1200),
                    curve: Curves.easeInOut,
                  )
                ],
              ),
            ),
            emptySpaceH(height: 12),
            Text(
              "Tap here to start the mission.",
              style: AppTextStyle.from(
                  color: AppColors.white,
                  size: TextSize.caption_small,
                  decoration: TextDecoration.none),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    bloc ??= HomeBloc(context)
      ..add(CalendarInitEvent(
          missions: widget.missions,
          diaryChecks: widget.diaryChecks,
          diaryRemove: widget.diaryRemove,
          trackerChecks: widget.trackerCheck));
    return BlocListener(
      cubit: bloc,
      listener: blocListener,
      child: Stack(
        children: <Widget>[
          _buildMainWidget(context),
          (bloc.loadData && !bloc.tutorialGesture)
              ? tutorialTap()
              : Container(),
          // _buildProgress(context),
          _buildProgressViewOnly(context),
        ],
      ),
    );
  }

  Widget _buildMainWidget(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            child: BaseAlertDialog(
              content: AppStrings.of(StringKey.are_you_sure_you_want_to_exit),
              cancelable: true,
              onConfirm: () {
                if (bloc.checkTime < 180) {
                  appsflyer.saveLog(threeMin);
                }
                SystemNavigator.pop();
              },
            ));
        return false;
      },
      child: Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(context),
          backgroundColor: AppColors.white,
          // floatingActionButton: _buildFAB(context),
          // drawer: HomeDrawerPage(
          //   bloc: bloc,
          //   navigationBloc: widget.bloc,
          // ),
          body: SafeArea(
              child: Consumer<MissionProvider>(
            builder: (ctx, provider, _) => Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Positioned(
                        top: resize(78),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: resize(1),
                          color: AppColors.lightGrey04,
                        )),
                    Positioned.fill(
                        top: resize(79), child: _buildMissionList(ctx)),
                    _buildCalendar(ctx),
                  ],
                )
              ],
            ),
          ))),
    );
  }

  setProfileImage(name) {
    if (name == "EMPATHY") {
      return AppImages.img_sympathy;
    } else if (name == "LOVE") {
      return AppImages.img_love;
    } else if (name == "HAPPINESS") {
      return AppImages.img_happiness;
    } else if (name == "HOPE") {
      return AppImages.img_hope;
    } else if (name == "AUTONOMY") {
      return AppImages.img_autonomy;
    }
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return baseAppBar(context,
        title: bloc.title,
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            padding: EdgeInsets.zero,
            icon: bloc.profile == null
                ? Container()
                : bloc.profile.profileImageName == null
                    ? Image.asset(
                        AppImages.img_sympathy,
                        width: resize(24),
                        height: resize(24),
                      )
                    : bloc.profile.profileImageName != "IMAGE"
                        ? Image.asset(
                            setProfileImage(bloc.profile.profileImageName),
                            width: resize(24),
                            height: resize(24),
                          )
                        : ClipOval(
                            child: Image.network(
                              bloc.profile.image,
                              width: resize(24),
                              height: resize(24),
                              fit: BoxFit.cover,
                            ),
                          ),
            onPressed: () {
              UserProfilePage.push(context, bloc.profile).then((value) {
                setState(() {
                  bloc.profile = value;
                });
              });
            }),
        actions: [
          IconButton(
              icon: Image.asset(AppImages.ic_bookmark,
                  width: resize(24), height: resize(24)),
              onPressed: () {
                BookmarkPage.push(context);
              }),
          BlocBuilder(
            cubit: bloc,
            builder: (ctx, _) => IconButton(
                icon: Image.asset(
                    bloc.unreadPushExist
                        ? AppImages.ic_bell_reddot
                        : AppImages.ic_bell,
                    width: resize(24),
                    height: resize(24)),
                onPressed: () {
                  NotificationListPage.push(ctx, widget.bloc).then((obj) {
                    bloc.add(ArrivedFromNotificationList(obj));
                  });
                }),
          )
        ]);
  }

  Widget _buildCalendar(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                topRight: Radius.circular(0))),
        color: AppColors.white,
        margin: EdgeInsets.only(top: 0, right: 0, left: 0, bottom: 0),
        elevation: 0,
        child: Container(
            height: resize(78),
            width: MediaQuery.of(context).size.width,
            child: PageView.builder(
                controller: bloc.calendarPageController,
                itemCount: (bloc.dateCount / 7).floor(),
                scrollDirection: Axis.horizontal,
                onPageChanged: (i) {
                  if (bloc.getDiaryCheck) {
                    bloc.getDiaryCheck = false;
                  }
                  bloc.add(CalendarWeekChangeEvent(i));
                },
                itemBuilder: (context, index) {
                  List<Widget> widgets = [];
                  for (int i = 0; i < 7; i++) {
                    int dateIndex = (index * 7) + i;

                    DateTime date = bloc.getDate(dateIndex);
                    double progressed = 0;

                    if (bloc.calendarProgress.indexWhere(
                            (element) => element.date == date.isoYYYYMMDD) !=
                        -1) {
                      int missionCount = bloc
                          .calendarProgress[bloc.calendarProgress.indexWhere(
                              (element) => element.date == date.isoYYYYMMDD)]
                          .missionCount;
                      int completedCount = bloc
                          .calendarProgress[bloc.calendarProgress.indexWhere(
                              (element) => element.date == date.isoYYYYMMDD)]
                          .completedCount;

                      if (bloc.profile != null) {
                        if (DateTime.now().isoYYYYMMDD ==
                            bloc.profile.createdDate.isoYYYYMMDD) {
                          missionCount -= 1;
                          completedCount -= 1;
                        }

                        progressed = missionCount <= 0
                            ? 0
                            : completedCount / missionCount;
                      }
                    }

                    widgets.add(HomeCalendarDayItem(
                      bloc.getDate(dateIndex),
                      onPressed: () =>
                          bloc.add(CalendarDatePressEvent(dateIndex)),
                      isSelected: bloc.isSameSelectedDay(dateIndex),
                      progressed: (progressed > 1
                          ? 1
                          : progressed < 0
                              ? 0
                              : progressed),
                      joinedDate: bloc.profile != null
                          ? bloc.profile.createdDate ?? DateTime.now()
                          : DateTime.now(),
                    ));
                  }

                  return Container(
                      margin:
                          EdgeInsets.only(left: resize(8), right: resize(8)),
                      child: Row(children: widgets));
                })));
  }

  Widget _buildMissionList(BuildContext context) {
    return Container(
        color: AppColors.white,
        child: PageView.builder(
            controller: bloc.missionPageController,
            onPageChanged: (i) {
              if (bloc.getDiaryCheck) {
                bloc.getDiaryCheck = false;
              }
              bloc.currentIndex = i;
              bloc.add(MissionPageChangeEvent(i));
            },
            itemCount: bloc.dateCount,
            itemBuilder: ((context, final pageIndex) {
              // 환자의 상태 정보가 없을경우 true 로 하여 진단 페이지로 이동하는 뷰 띄움
              evaluationRenewalOpenDialog();

              if (bloc.userType != "" && !bloc.completedEvaluation) {
                startEvaluation(context);
              }
              DateTime getSelectDate = bloc.getDate(pageIndex);
              DateTime startDate = bloc.startTime;

              List<Mission> dailyMissions = bloc.getMission(getSelectDate);
              if (bloc.currentIndex != null) {
                if (bloc.currentIndex == pageIndex) {
                  if (dailyMissions != null && dailyMissions.isNotEmpty) {
                    String selectDateString = getSelectDate.isoYYYYMMDD;
                    String startDateString = bloc.startTime.isoYYYYMMDD;

                    if (selectDateString == startDateString) {
                      if (!bloc.saveLogCheck) {
                        appsflyer.saveLog(missionLoad);
                        bloc.saveLogCheck = true;
                      }
                      bloc.loadData = true;
                      gestureAnimation();

                      if (bloc.tutorialGesture) {
                        gestureTimer.cancel();
                      }
                      bloc.pageIndex = pageIndex;
                      bloc.firstMission =
                          bloc.getMissionByPageIndex(pageIndex).missions[0];
                    }
                    bloc.getPerformHistoryByPageIndex(
                        pageIndex, dailyMissions.length, context);
                  }
                }
              }

              return RefreshIndicator(
                  displacement: resize(40),
                  color: AppColors.orange,
                  backgroundColor: AppColors.white,
                  onRefresh: () async {
                    if (bloc.getDiaryCheck) {
                      bloc.getDiaryCheck = false;
                    }
                    bloc.add(
                        RefreshIndicatorCallEvent(selectDate: getSelectDate));
                  },
                  child: bloc.profile == null ||
                          dailyMissions == null ||
                          dailyMissions.length == 0
                      ? startDate == null
                          ? _buildMissionEmpty(context)
                          : (getSelectDate.difference(startDate).inDays >= 0 &&
                                  DateTime.now().compareTo(getSelectDate) >= 0)
                              ? NotificationListener<ScrollUpdateNotification>(
                                  onNotification: (notification) {
                                    if (!bloc.scrollCheck) {
                                      appsflyer.saveLog(useScroll);
                                      bloc.scrollCheck = true;
                                    }
                                    return null;
                                  },
                                  child: ListView.builder(
                                      itemCount: 1,
                                      controller: missionListController,
                                      itemBuilder: (context, listIndex) {
                                        DateTime getSelectDate =
                                            bloc.getDate(pageIndex);

                                        bool enableTracking = false;
                                        if (getSelectDate.compareTo(
                                                DateTime(2021, 04, 29)) >=
                                            0) {
                                          enableTracking = true;
                                        }

                                        DateTime now = DateTime.now();
                                        DateTime selectDate =
                                            bloc.getDate(pageIndex);

                                        if (listIndex == 0) {
                                          return Column(
                                            children: [
                                              (now.isoYYYYMMDD ==
                                                      selectDate.isoYYYYMMDD)
                                                  ? MissionTitleItem(
                                                      dateNow: true,
                                                      userType: bloc.userType,
                                                      enableBanner: false,
                                                    )
                                                  : MissionTitleItem(
                                                      dateNow: false,
                                                    ),
                                              enableTracking
                                                  ? trackerUi(
                                                      getSelectDate, pageIndex)
                                                  : Container(),
                                              enableTracking
                                                  ? emptySpaceH(height: 12)
                                                  : Container(),
                                              diaryUi(getSelectDate, pageIndex),
                                              emptySpaceH(height: 12),
                                              FooterItem()
                                            ],
                                          );
                                        } else {
                                          return Container();
                                        }
                                      }),
                                )
                              : _buildMissionEmpty(context)
                      : getSelectDate.difference(startDate).inDays >= 0 &&
                              DateTime.now().compareTo(getSelectDate) >= 0
                          ? NotificationListener<ScrollUpdateNotification>(
                              onNotification: (notification) {
                                if (!bloc.scrollCheck) {
                                  appsflyer.saveLog(useScroll);
                                  bloc.scrollCheck = true;
                                }
                                return null;
                              },
                              child: ListView.builder(
                                  itemCount: 1 +
                                      (dailyMissions == null
                                          ? 0
                                          : dailyMissions.length) +
                                      1,
                                  controller: missionListController,
                                  itemBuilder: (context, listIndex) {
                                    DateTime getSelectDate =
                                        bloc.getDate(pageIndex);

                                    String selectDateString =
                                        getSelectDate.isoYYYYMMDD;
                                    String startDateString =
                                        bloc.startTime.isoYYYYMMDD;
                                    bool enableTracking = false;
                                    if (getSelectDate.compareTo(
                                            DateTime(2021, 04, 29)) >=
                                        0) {
                                      enableTracking = true;
                                    }
                                    if (listIndex == 0) {
                                      DateTime now = DateTime.now();
                                      DateTime selectDate =
                                          bloc.getDate(pageIndex);

                                      bool enableBanner = false;
                                      // if (now.difference(bloc.startTime).inDays !=
                                      //         0 &&
                                      //     now.difference(bloc.startTime).inDays %
                                      //             7 ==
                                      //         0) {
                                      //   enableBanner = true;
                                      // }

                                      return Column(
                                        children: [
                                          (now.isoYYYYMMDD ==
                                                  selectDate.isoYYYYMMDD)
                                              ? MissionTitleItem(
                                                  dateNow: true,
                                                  userType: bloc.userType,
                                                  enableBanner: enableBanner,
                                                )
                                              : MissionTitleItem(
                                                  dateNow: false,
                                                ),
                                          (dailyMissions.length == 0)
                                              ? Container()
                                              : selectDateString !=
                                                      startDateString
                                                  ? Container()
                                                  : _buildMission(
                                                      bloc.getDate(pageIndex),
                                                      dailyMissions[0],
                                                      bloc,
                                                      true),
                                          enableTracking
                                              ? trackerUi(
                                                  getSelectDate, pageIndex)
                                              : Container(),
                                          enableTracking
                                              ? emptySpaceH(height: 8)
                                              : Container(),
                                        ],
                                      );
                                    }

                                    if (selectDateString != startDateString) {
                                      if (listIndex ==
                                          (dailyMissions == null
                                                  ? 0
                                                  : dailyMissions.length) +
                                              1) {
                                        return Column(
                                          children: [
                                            diaryUi(getSelectDate, pageIndex),
                                            FooterItem()
                                          ],
                                        );
                                      }
                                    } else {
                                      if (listIndex ==
                                          dailyMissions.length + 1) {
                                        return Column(
                                          children: [
                                            FooterItem(),
                                          ],
                                        );
                                      }
                                    }

                                    if (selectDateString != startDateString) {
                                      return _buildMission(
                                          bloc.getDate(pageIndex),
                                          dailyMissions[
                                              dailyMissions.length == listIndex
                                                  ? listIndex - 1
                                                  : listIndex - 1],
                                          bloc,
                                          false);
                                    } else {
                                      return dailyMissions.length <= listIndex
                                          ? Container()
                                          : _buildMission(
                                              bloc.getDate(pageIndex),
                                              dailyMissions[listIndex],
                                              bloc,
                                              true);
                                    }
                                  }),
                            )
                          : _buildMissionEmpty(context));
            })));
  }

  diaryUi(DateTime selectTime, int pageIndex) {
    return bloc.getDiaryCheckCalendar(pageIndex) &&
            selectTime == bloc.getDate(pageIndex)
        ? GestureDetector(
            onTap: () {
              appsflyer.saveLog(diary);
              widget.bloc.add(ChangeViewEvent(changeIndex: 3));
            },
            child: Container(
              height: resize(98),
              child: Stack(
                children: [
                  Positioned(
                    top: resize(8),
                    left: resize(24),
                    right: resize(24),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 90,
                      decoration: BoxDecoration(
                          color: AppColors.diaryColor,
                          border: Border.all(
                              color: AppColors.lightGrey04, width: 1),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            emptySpaceW(width: 18),
                            Image.asset(
                              AppImages.ic_mission_diary,
                              width: resize(32),
                              height: resize(32),
                            ),
                            emptySpaceW(width: 12),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppStrings.of(StringKey
                                        .how_was_your_day_today_write_a_diary),
                                    style: AppTextStyle.from(
                                        color: AppColors.black,
                                        size: TextSize.caption_medium,
                                        weight: TextWeight.bold,
                                        height: 1.4),
                                  ),
                                  emptySpaceH(height: 4),
                                  Text(
                                    "Diary",
                                    style: AppTextStyle.from(
                                        color: AppColors.darkGrey,
                                        size: TextSize.caption_small,
                                        weight: TextWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            emptySpaceW(width: 4),
                            Image.asset(
                              AppImages.img_diary,
                              width: resize(70),
                              height: resize(76),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 16,
                    child: Image.asset(AppImages.ic_check_circle_mission),
                    width: resize(30),
                    height: resize(30),
                  )
                ],
              ),
            ))
        : Padding(
            padding: EdgeInsets.only(left: resize(24), right: resize(24)),
            child: GestureDetector(
                onTap: () {
                  appsflyer.saveLog(diary);
                  DiaryPage.push(context, selectTime, false).then((value) {
                    bloc.getDiaryCheck = false;
                    bloc.add(RefreshIndicatorCallEvent(selectDate: selectTime));
                    if (value != null) {
                      missionCompleteCheck(value, pageIndex, selectTime);
                    } else {
                      missionCompleteCheck(false, pageIndex, selectTime);
                    }
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 90,
                  decoration: BoxDecoration(
                      color: AppColors.diaryColor,
                      border:
                          Border.all(color: AppColors.lightGrey04, width: 1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        emptySpaceW(width: 18),
                        Image.asset(
                          AppImages.ic_mission_diary,
                          width: resize(32),
                          height: resize(32),
                        ),
                        emptySpaceW(width: 12),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.of(StringKey
                                    .how_was_your_day_today_write_a_diary),
                                style: AppTextStyle.from(
                                    color: AppColors.black,
                                    size: TextSize.caption_medium,
                                    weight: TextWeight.bold,
                                    height: 1.4),
                              ),
                              emptySpaceH(height: 4),
                              Text(
                                "Diary",
                                style: AppTextStyle.from(
                                    color: AppColors.darkGrey,
                                    size: TextSize.caption_small,
                                    weight: TextWeight.bold),
                              )
                            ],
                          ),
                        ),
                        emptySpaceW(width: 4),
                        Image.asset(
                          AppImages.img_diary,
                          width: resize(70),
                          height: resize(76),
                        ),
                      ],
                    ),
                  ),
                )),
          );
  }

  trackerUi(DateTime getSelectDate, int pageIndex) {
    return Padding(
      padding: EdgeInsets.only(left: resize(16), right: resize(16)),
      child: GestureDetector(
          onTap: () async {
            if (bloc.trackerChecks != null &&
                bloc.getTrackerCheckData(pageIndex) &&
                getSelectDate == bloc.getDate(pageIndex)) {
              if (Platform.isAndroid &&
                  bloc.trackerChecks.indexWhere(
                          (element) => element.trackingData.userId != null) !=
                      -1) {
                if (await requestActivityRecognition()) {
                  TrackerPage.push(context, getSelectDate).then((value) {
                    bloc.add(
                        RefreshIndicatorCallEvent(selectDate: getSelectDate));
                    if (value != null) {
                      missionCompleteCheck(value, pageIndex, getSelectDate);
                    } else {
                      missionCompleteCheck(false, pageIndex, getSelectDate);
                    }
                  });
                }
              } else {
                TrackerPage.push(context, getSelectDate).then((value) {
                  bloc.add(
                      RefreshIndicatorCallEvent(selectDate: getSelectDate));
                  if (value != null) {
                    missionCompleteCheck(value, pageIndex, getSelectDate);
                  } else {
                    missionCompleteCheck(false, pageIndex, getSelectDate);
                  }
                });
              }
            } else {
              TrackerSettingPage.push(context, false, getSelectDate)
                  .then((value) {
                if (value != null && value) {
                  bloc.add(
                      RefreshIndicatorCallEvent(selectDate: getSelectDate));
                }
              });
            }
          },
          child: Container(
            height: resize(98),
            child: Stack(
              children: [
                Positioned(
                  top: resize(8),
                  left: resize(8),
                  right: resize(8),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: resize(90),
                    decoration: BoxDecoration(
                        color: AppColors.trackingColor,
                        borderRadius: BorderRadius.circular(16)),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          emptySpaceW(width: 18),
                          Image.asset(
                            AppImages.ic_mission_tracker,
                            width: resize(32),
                            height: resize(32),
                          ),
                          emptySpaceW(width: 12),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bloc.getTrackerCheckCalendar(pageIndex) &&
                                          getSelectDate ==
                                              bloc.getDate(pageIndex)
                                      ? AppStrings.of(StringKey
                                          .keep_your_body_moving_track_your_movement)
                                      : AppStrings.of(
                                          StringKey.keep_your_body_moving),
                                  style: AppTextStyle.from(
                                      color: AppColors.black,
                                      size: TextSize.caption_medium,
                                      weight: TextWeight.bold,
                                      height: 1.4),
                                ),
                                emptySpaceH(height: 4),
                                Text(
                                  AppStrings.of(StringKey.activity_tracker),
                                  style: AppTextStyle.from(
                                      color: AppColors.darkGrey,
                                      size: TextSize.caption_small,
                                      weight: TextWeight.bold),
                                )
                              ],
                            ),
                          ),
                          emptySpaceW(width: 4),
                          Image.asset(
                            AppImages.img_tracker,
                            width: resize(70),
                            height: resize(76),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                bloc.getTrackerCheckCalendar(pageIndex) &&
                        getSelectDate == bloc.getDate(pageIndex)
                    ? Positioned(
                        top: 0,
                        right: 0,
                        child: Image.asset(AppImages.ic_check_circle_mission),
                        width: resize(30),
                        height: resize(30),
                      )
                    : Container()
              ],
            ),
          )),
    );
  }

  missionCompleteCheck(bool value, int pageIndex, DateTime selectTime) {
    if (value != null) {
      bloc.completed = value;
    }
    List<Mission> dailyMissions = bloc.getMission(selectTime);
    bloc.getPerformHistoryByPageIndex(pageIndex, dailyMissions.length, context);
  }

  Widget _buildEvaluation(BuildContext context) {
    return ListView(
      children: <Widget>[
        emptySpaceH(height: 16),
        Image.asset(
          AppImages.img_therapist,
          width: resize(136),
          height: resize(120),
        ),
        emptySpaceH(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Text(
            bloc.completedTitle,
            style: AppTextStyle.from(
                color: AppColors.blueGrey,
                size: TextSize.title_medium,
                weight: TextWeight.extrabold,
                height: AppTextStyle.LINE_HEIGHT_MULTI_LINE),
            textAlign: TextAlign.center,
          ),
        ),
        emptySpaceH(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24),
          child: Text(
            bloc.completedDescription,
            style: AppTextStyle.from(
                color: AppColors.grey, size: TextSize.caption_medium),
            strutStyle: StrutStyle(leading: 0.5),
          ),
        ),
        emptySpaceH(height: 32),
        Padding(
          padding: EdgeInsets.only(left: 16, right: 16),
          child: Container(
            width: resize(MediaQuery.of(context).size.width),
            height: resize(54),
            child: RaisedButton(
              onPressed: () {
                EvaluationPage.push(context, 0);
              },
              color: AppColors.purple,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              child: Center(
                child: Text(
                  AppStrings.of(StringKey.start),
                  style: AppTextStyle.from(
                      size: TextSize.body_small,
                      color: AppColors.white,
                      height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                      weight: TextWeight.semibold),
                ),
              ),
            ),
          ),
        ),
        emptySpaceH(height: 20)
      ],
    );
  }

  void evaluationRenewalOpenDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool evaluationRenewal = bloc.validEvaluation;
      if (evaluationRenewal != null && !bloc.open) {
        // 환자의 상태 정보를 갱신할 날짜가 된 경우 true 로 하여 진단 페이지로 이동하는 다이얼로그 띄움
        if (!evaluationRenewal && (!bloc.completedEvaluation == false)) {
          bloc.open = true;
          showDialog(
              barrierDismissible: true,
              context: (context),
              builder: (_) {
                return _buildEvaluationRenewal(context);
              });
        }
      }
    });
  }

  startEvaluation(context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bloc.userType == "VIP" && !bloc.evaluationOpen) {
        bloc.evaluationOpen = true;
        startEvaluationDialog(context);
      }
    });
  }

  Widget _buildEvaluationRenewal(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(true);
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        elevation: 0,
        backgroundColor: AppColors.white,
        child: Container(
          width: resize(312),
          height: resize(418),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    top: resize(20), right: resize(24), left: resize(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        child: Image.asset(
                          AppImages.ic_delete,
                          width: resize(24),
                          height: resize(24),
                        ),
                      ),
                    ),
                    Image.asset(
                      AppImages.img_ic_evaluation,
                      width: resize(90),
                      height: resize(90),
                    ),
                    emptySpaceH(height: 20),
                    Container(
                      height: resize(32),
                      child: Text(
                        bloc.validTitle,
                        style: AppTextStyle.from(
                            color: AppColors.blueGrey,
                            size: TextSize.title_medium,
                            weight: TextWeight.extrabold,
                            height: AppTextStyle.LINE_HEIGHT_MULTI_LINE),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    emptySpaceH(height: 16),
                    Container(
                      height: resize(104),
                      child: Text(
                        bloc.validDescription,
                        style: AppTextStyle.from(
                            color: AppColors.grey,
                            size: TextSize.caption_medium),
                        strutStyle: StrutStyle(leading: 0.5),
                      ),
                    ),
                    emptySpaceH(height: 40),
                  ],
                ),
              ),
              Container(
                width: resize(MediaQuery.of(context).size.width),
                height: resize(72),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    EvaluationPage.push(context, 1);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32))),
                  elevation: 0,
                  color: AppColors.lightPurple,
                  child: Center(
                    child: Text(
                      AppStrings.of(StringKey.start),
                      style: AppTextStyle.from(
                          size: TextSize.body_small,
                          color: AppColors.white,
                          height: AppTextStyle.LINE_HEIGHT_MULTI_LINE,
                          weight: TextWeight.semibold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ListView _buildMissionEmpty(BuildContext context) {
    return ListView(children: [
      Container(
          height: resize(360),
          width: MediaQuery.of(context).size.width,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                margin: EdgeInsets.only(bottom: resize(24)),
                child: Image.asset(AppImages.illust_no_mission,
                    height: resize(132), width: resize(220))),
          ])),
      FooterItem()
    ]);
  }

  _buildMission(DateTime date, Mission mission, HomeBloc bloc, bool day1Check) {
    // debugPrint('_mission - ${mission.tags}');

    return mission == null
        ? null
        : CommonMissionItem(
            date: date,
            mission: mission,
            homeBloc: bloc,
            userType: bloc.userType,
            day1Check: day1Check,
            profile: bloc.profile,
          );
  }

  Widget _buildProgressViewOnly(BuildContext context) {
    if (!bloc.isLoadingView) return Container();

    return FullscreenDialog();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<RouteObserver<PageRoute>>(context, listen: false)
        .subscribe(this, ModalRoute.of(context));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      bloc.add(NotifyCheck());
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) bloc.add(NotifyCheck());
    });
  }

  void blocListener(BuildContext context, BaseBlocState state) async {
    if (state is CalendarInitializedState) {
      widget.bloc.add(SaveMissionEvent(
          missions: bloc.missions,
          diaryChecks: bloc.diaryChecks,
          trackerChecks: bloc.trackerChecks));
      bloc.missionPageController.jumpToPage(max(0, bloc.dateCount - 1));
      bloc.calendarPageController
          .jumpToPage(max(0, bloc.calendarPageCount - 1));
      setState(() {});
      var pushNotificationOnLaunch =
          PushNotificationHandler().getAndRemovePushNotificationOnLaunch();
      if (pushNotificationOnLaunch != null) {
        _onPushNotificationClicked(context, pushNotificationOnLaunch);
      }
      if (Platform.isAndroid &&
          bloc.trackerChecks != null &&
          bloc.trackerChecks.length != 0 &&
          bloc.trackerChecks.indexWhere(
                  (element) => element.trackingData.userId != null) !=
              -1) {
        await requestActivityRecognition();
      }
      bloc.isLoadingView = false;
      bloc.add(LoadingEvent());
    }

    if (state is DiaryCheck) {
      setState(() {});
    }

    if (state is GestureChangeState) {
      setState(() {});
    }

    if (state is LoadingState) {
      widget.bloc.add(SaveMissionEvent(
          missions: bloc.missions,
          diaryChecks: bloc.diaryChecks,
          trackerChecks: bloc.trackerChecks));
      setState(() {});
    }
  }

  void _onPushNotificationClicked(
      BuildContext context, PushNotification pushNotification) {
    if (pushNotification?.type?.isNotEmpty == true) {
      switch (pushNotification.type) {
        case NotificationType.connect_advice_msg_arrive:
        case NotificationType.connect_mission_advice_daily:
        case NotificationType.connect_mission_current_status_daily:
          widget.bloc.add(ChangeViewEvent(changeIndex: 1));
          break;
        case NotificationType.connect_mission_arrived_daily:
        case NotificationType.connect_recommend_diary:
          HomeNavigation.popUntil(context);
          break;
        case NotificationType.portal_patient_assign:
          ProfilePage.push(context);
          break;
        case NotificationType.sendbird_messasing:
          widget.bloc.add(ChangeViewEvent(changeIndex: 2));
          break;
      }
    }
  }

  @override
  void dispose() {
    bloc?.close();
    bloc = null;
    _notificationClickActionSubscription?.cancel();
    super.dispose();
  }
}

completeDialog(context) {
  var random = Random();
  int imgNum = random.nextInt(2);
  String completeImage;

  if (imgNum == 0) {
    completeImage = AppImages.img_congratulation;
  } else {
    completeImage = AppImages.img_congratulation_2;
  }

  return showDialog(
      barrierDismissible: false,
      context: (context),
      builder: (_) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Dialog(
            elevation: 0,
            insetPadding: EdgeInsets.zero,
            backgroundColor: AppColors.transparent,
            child: Container(
              width: resize(328),
              height: resize(590),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: resize(46),
                    bottom: resize(29),
                    child: Container(
                      width: resize(328),
                      height: resize(590),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.all(Radius.circular(resize(32))),
                      ),
                    ),
                  ),
                  Positioned(
                    left: resize(24),
                    right: resize(24),
                    child: Image.asset(
                      completeImage,
                      width: resize(280),
                      height: resize(280),
                    ),
                  ),
                  Positioned(
                    top: resize(300),
                    left: resize(0),
                    right: resize(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: resize(280),
                          height: resize(44),
                          color: AppColors.white,
                          child: Text(
                            AppStrings.of(StringKey.congratulations),
                            style: AppTextStyle.from(
                                color: AppColors.blueGrey,
                                size: TextSize.title_medium_bigger_than,
                                weight: TextWeight.extrabold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        emptySpaceH(height: 20),
                        Container(
                          width: resize(280),
                          height: resize(58),
                          color: AppColors.white,
                          child: Center(
                            child: Text(
                              AppStrings.of(
                                  StringKey.congratulation_description),
                              style: AppTextStyle.from(
                                color: AppColors.grey,
                                size: TextSize.body_medium,
                                weight: TextWeight.semibold,
                              ),
                              strutStyle: StrutStyle(leading: 0.65),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    left: resize(0),
                    right: resize(0),
                    bottom: resize(24),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: resize(72),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(resize(32)),
                            bottomRight: Radius.circular(resize(32))),
                        child: RaisedButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                          elevation: 0.0,
                          color: AppColors.lightPurple,
                          child: Center(
                            child: Container(
                              width: resize(160),
                              height: resize(23.6),
                              child: Center(
                                child: Text(
                                  AppStrings.of(StringKey.confirm),
                                  style: AppTextStyle.from(
                                      color: AppColors.white,
                                      size: TextSize.body_small,
                                      weight: TextWeight.semibold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      });
}
