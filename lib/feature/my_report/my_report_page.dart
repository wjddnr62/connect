import 'dart:async';
import 'dart:io';

import 'package:connect/data/diary_repository.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/diary/diary_page.dart';
import 'package:connect/feature/my_report/my_report_bloc.dart';
import 'package:connect/feature/notification/notification_list_page.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/feature/tracker/tracker_page.dart';
import 'package:connect/feature/tracker/tracker_setting_page.dart';
import 'package:connect/feature/user/profile/profile_page.dart';
import 'package:connect/feature/user/profile/user_profile_page.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/push/push_notification_handler.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/utils/extensions.dart';

import 'package:multiscreen/multiscreen.dart';

class MyReportPage extends BlocStatefulWidget {
  final HomeNavigationBloc bloc;
  final bool diary;

  MyReportPage({this.bloc, this.diary});

  @override
  MyReportState buildState() => MyReportState();
}

class MyReportState extends BlocState<MyReportBloc, MyReportPage> {
  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return Stack(
            children: <Widget>[
              Scaffold(
                backgroundColor: AppColors.white,
                floatingActionButton: bloc.tapIndex != 2 ||
                        (bloc.diaryData == null || bloc.diaryData.length == 0)
                    ? Container()
                    : bloc.diaryData.indexWhere((element) =>
                                DateTime.parse(element.writeDateTime)
                                    .isoYYYYMMDD ==
                                DateTime.now().isoYYYYMMDD) ==
                            -1
                        ? Container(
                            width: resize(164),
                            height: resize(64),
                            child: ElevatedButton(
                              onPressed: () {
                                DiaryPage.push(context, DateTime.now(), false)
                                    .then((value) {
                                  bloc.add(DiaryInitEvent());
                                  if (value != null && value) {
                                    diaryWrite();
                                  }
                                });
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: resize(24),
                                      height: resize(24),
                                      child: Center(
                                          child: Image.asset(AppImages.ic_add)),
                                    ),
                                    Center(
                                      child: Text(
                                        "Write a Diary",
                                        style: AppTextStyle.from(
                                            color: AppColors.white,
                                            size: TextSize.caption_large,
                                            weight: TextWeight.bold),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: AppColors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  padding: EdgeInsets.zero,
                                  elevation: 2),
                            ),
                          )
                        : Container(),
                appBar: _buildAppBar(context),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [emptySpaceH(height: 48), mainView()],
                      ),
                    ),
                    tapBar(),
                  ],
                ),
              ),
              _buildProgress(context)
            ],
          );
        });
  }

  Widget tapBar() {
    return Container(
      height: resize(48),
      child: Row(
        children: [tapBarChild(0), tapBarChild(1), tapBarChild(2)],
      ),
    );
  }

  Widget mainView() {
    if (bloc.tapIndex == 0) {
      return summary();
    } else if (bloc.tapIndex == 1) {
      return activity();
    } else if (bloc.tapIndex == 2) {
      return diary();
    } else {
      return Container();
    }
  }

  Widget summary() {
    return bloc.currentStatus == null
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width,
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: resize(280),
                  child: Stack(
                    children: [
                      Image.network(
                        bloc.currentStatus.imageUrl,
                        width: MediaQuery.of(context).size.width,
                        height: resize(280),
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: resize(24),
                        left: resize(24),
                        right: resize(24),
                        child: Text(
                          bloc.currentStatus.message,
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.title_medium,
                              height: 1.5),
                        ),
                      )
                    ],
                  ),
                ),
                emptySpaceH(height: 16),
                Padding(
                  padding: EdgeInsets.only(left: resize(24)),
                  child: Text(
                    AppStrings.of(StringKey.last_30_days),
                    style: AppTextStyle.from(
                        color: AppColors.darkGrey,
                        size: TextSize.caption_medium,
                        weight: TextWeight.extrabold),
                  ),
                ),
                emptySpaceH(height: 16),
                Padding(
                  padding: EdgeInsets.only(left: resize(16), right: resize(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: userStatus(
                              AppStrings.of(StringKey.practice_time))),
                      emptySpaceW(width: 12),
                      Expanded(
                          child: userStatus(
                              AppStrings.of(StringKey.mission_achievement)))
                    ],
                  ),
                ),
                emptySpaceH(height: 12),
                Padding(
                  padding: EdgeInsets.only(left: resize(16), right: resize(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: userStatus(
                              AppStrings.of(StringKey.activity_achievement))),
                      emptySpaceW(width: 12),
                      Expanded(
                          child: userStatus(AppStrings.of(StringKey.diary)))
                    ],
                  ),
                ),
                emptySpaceH(height: 24),
                bloc.profile.therapist == null
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: resize(12),
                        color: AppColors.lightGrey01,
                      ),
                therapistInformation(),
                advice(),
                bloc.userType == "VIP"
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: resize(12),
                        color: AppColors.lightGrey01,
                      ),
                bloc.userType == "VIP"
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          PaymentNoticePage.push(context,
                              closeable: true,
                              isNewHomeUser: false,
                              back: true,
                              focusImg: 5,
                              logSet: 'geteval');
                        },
                        child: Image.asset(
                          AppImages.img_get_evaluation,
                          width: MediaQuery.of(context).size.width,
                          height: resize(90),
                        ),
                      ),
                evaluationTrend(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: resize(24),
                  color: AppColors.lightGrey01,
                ),
              ],
            ),
          );
  }

  Widget activity() {
    return bloc.trackerGoal.id != null
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                resize(98 +
                    AppBar().preferredSize.height +
                    MediaQuery.of(context).padding.top +
                    MediaQuery.of(context).padding.bottom) +
                13,
            child: TrackerPage(
              date: DateTime.now(),
              myReport: true,
            ),
          )
        : Container(
            width: MediaQuery.of(context).size.width,
            height: resize(MediaQuery.of(context).size.height -
                (Platform.isAndroid ? 85 : 120) -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height),
            padding: EdgeInsets.only(left: resize(24), right: resize(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  AppImages.img_set_activity_goal,
                  width: resize(130),
                  height: resize(107),
                ),
                emptySpaceH(height: 33),
                Text(
                  AppStrings.of(
                      StringKey.set_your_activity_goal_and_achieve_it),
                  style: AppTextStyle.from(
                      color: AppColors.darkGrey,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                ),
                emptySpaceH(height: 44),
                Padding(
                  padding: EdgeInsets.only(left: resize(70), right: resize(70)),
                  child: BottomButton(
                    onPressed: () {
                      TrackerSettingPage.push(context, false, DateTime.now(),
                              myReport: true, homeNavigationBloc: widget.bloc)
                          .then((value) {
                        bloc.add(MyReportInitEvent());
                      });
                    },
                    text: AppStrings.of(StringKey.set_activity_goal),
                  ),
                )
              ],
            ),
          );
  }

  weather(weather) {
    switch (weather) {
      case "SUNNY":
        return AppImages.weather_sunny;
      case "CLOUDY":
        return AppImages.weather_cloudy;
      case "CLEAR":
        return AppImages.weather_clear;
      case "RAIN":
        return AppImages.weather_rain;
      case "THUNDER":
        return AppImages.weather_thunder;
      case "RAINBOW":
        return AppImages.weather_rainbow;
      case "SNOW":
        return AppImages.weather_snow;
      case "WIND":
        return AppImages.weather_wind;
    }
  }

  feeling(feeling) {
    switch (feeling) {
      case "GOOD":
        return AppImages.feeling_good;
      case "NORMAL":
        return AppImages.feeling_normal;
      case "ANGRY":
        return AppImages.feeling_angry;
      case "DEPRESSED":
        return AppImages.feeling_depressed;
      case "LOVELY":
        return AppImages.feeling_lovely;
      case "WINK":
        return AppImages.feeling_wink;
      case "JOY":
        return AppImages.feeling_joy;
      case "SADNESS":
        return AppImages.feeling_sadness;
      case "HEADACHE":
        return AppImages.feeling_headache;
      case "SURPRISE":
        return AppImages.feeling_surprise;
      case "HAPPINESS":
        return AppImages.feeling_happiness;
      case "MENTALBREAKDOWN":
        return AppImages.feeling_mentalbreakdown;
    }
  }

  bool loadDiary = false;

  diaryWrite() {
    if (widget.bloc.diaryChecks == null ||
        widget.bloc.diaryChecks.length == 0) {
      widget.bloc.diaryChecks = List();
    }
    if (widget.bloc.diaryChecks.indexWhere(
            (element) => element.date == DateTime.now().isoYYYYMMDD) !=
        -1) {
      widget.bloc.diaryChecks.removeAt(widget.bloc.diaryChecks
          .indexWhere((element) => element.date == DateTime.now().isoYYYYMMDD));
    }
    widget.bloc.diaryChecks
        .add(DiaryChecks(date: DateTime.now().isoYYYYMMDD, check: true));
  }

  Widget diary() {
    return bloc.diaryData == null || bloc.diaryData.length == 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height -
                resize(100) -
                MediaQuery.of(context).padding.top -
                AppBar().preferredSize.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppImages.img_diary,
                    width: resize(110), height: resize(120)),
                emptySpaceH(height: 12),
                Text(
                  AppStrings.of(StringKey.how_was_your_day_today),
                  style: AppTextStyle.from(
                      color: AppColors.darkGrey,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                ),
                emptySpaceH(height: 44),
                Container(
                  width: resize(176),
                  height: resize(54),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(4)),
                  child: ElevatedButton(
                      onPressed: () {
                        DiaryPage.push(context, DateTime.now(), false)
                            .then((value) {
                          bloc.add(DiaryInitEvent());
                          if (value != null && value) {
                            diaryWrite();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          primary: AppColors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0),
                      child: Center(
                        child: Text(
                          AppStrings.of(StringKey.write_a_diary),
                          style: AppTextStyle.from(
                              color: AppColors.white,
                              size: TextSize.caption_large,
                              weight: TextWeight.semibold),
                        ),
                      )),
                )
              ],
            ),
          )
        : GestureDetector(
            onTap: () {
              for (int i = 0; i < bloc.viewOptions.length; i++) {
                bloc.viewOptions[i] = false;
              }
              setState(() {});
            },
            child: Container(
              height: MediaQuery.of(context).size.height -
                  resize(100) -
                  AppBar().preferredSize.height,
              color: AppColors.white,
              child: ListView.builder(
                addAutomaticKeepAlives: true,
                itemBuilder: (context, idx) {
                  DateTime writeDateTime =
                      DateTime.parse(bloc.diaryData[idx].writeDateTime);

                  DateTime wakeUpDateTime =
                      DateTime.parse(bloc.diaryData[idx].wakeDateTime);
                  DateTime sleepDateTime =
                      DateTime.parse(bloc.diaryData[idx].sleepDateTime);
                  int sleepTime =
                      wakeUpDateTime.difference(sleepDateTime).inHours;
                  if (sleepTime > 24) {
                    sleepTime = sleepTime - 24;
                  }

                  String writeDate = DateFormat.formatDiaryDate(
                      "MMM. dd, yyyy", writeDateTime);

                  return Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(60),
                            color: AppColors.white,
                            padding: EdgeInsets.only(
                                left: resize(24), right: resize(24)),
                            child: Row(
                              children: [
                                Text(
                                  writeDate,
                                  style: AppTextStyle.from(
                                      color: AppColors.darkGrey,
                                      size: TextSize.caption_large,
                                      weight: TextWeight.semibold),
                                ),
                                Expanded(child: Container()),
                                Image.asset(
                                  weather(bloc.diaryData[idx].weatherType),
                                  width: resize(36),
                                  height: resize(36),
                                ),
                                emptySpaceW(width: 4),
                                Image.asset(
                                  feeling(bloc.diaryData[idx].feelingType),
                                  width: resize(36),
                                  height: resize(36),
                                ),
                                emptySpaceW(width: 16),
                                IconButton(
                                    onPressed: () {
                                      if (bloc.viewOptions[idx]) {
                                        bloc.viewOptions[idx] = false;
                                      } else {
                                        for (int i = 0;
                                            i < bloc.viewOptions.length;
                                            i++) {
                                          bloc.viewOptions[i] = false;
                                        }
                                        bloc.viewOptions[idx] = true;
                                      }
                                      setState(() {});
                                    },
                                    icon: Image.asset(
                                      AppImages.ic_more,
                                      width: resize(24),
                                      height: resize(24),
                                    ))
                              ],
                            ),
                          ),
                          bloc.diaryData[idx].contentImages == null
                              ? Container()
                              : Image.network(bloc
                                  .diaryData[idx].contentImages[0].imagePath),
                          bloc.diaryData[idx].contentImages == null
                              ? Container()
                              : emptySpaceH(height: 12),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(36),
                            color: AppColors.white,
                            padding: EdgeInsets.only(
                                left: resize(24), right: resize(24)),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppImages.ic_moon,
                                  width: resize(24),
                                  height: resize(24),
                                ),
                                emptySpaceW(width: 8),
                                Text(
                                  "Sleep time: ${sleepTime}hours",
                                  style: AppTextStyle.from(
                                    color: AppColors.grey,
                                    size: TextSize.caption_medium,
                                  ),
                                ),
                                Expanded(child: Container()),
                                bloc.diaryData[idx].isPrivate
                                    ? Image.asset(
                                        AppImages.img_lock,
                                        width: resize(36),
                                        height: resize(36),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                          emptySpaceH(height: 8),
                          LayoutBuilder(builder: (context, size) {
                            var textCheck = TextPainter(
                                maxLines: 3,
                                textDirection: TextDirection.ltr,
                                text: TextSpan(
                                    text: bloc.diaryData[idx].contentMessage,
                                    style: AppTextStyle.from(
                                        color: AppColors.darkGrey,
                                        size: TextSize.caption_large,
                                        height: 1.6)));

                            textCheck.layout(maxWidth: size.maxWidth);

                            var exceeded = textCheck.didExceedMaxLines;

                            return Column(
                              children: [
                                bloc.diaryData[idx].contentMessage == ""
                                    ? Container()
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: resize(24),
                                            right: resize(24),
                                          ),
                                          child: Container(
                                            child: Text(
                                              bloc.diaryData[idx]
                                                  .contentMessage,
                                              maxLines:
                                                  bloc.maxLines[idx] ? 3 : null,
                                              overflow: bloc.maxLines[idx]
                                                  ? TextOverflow.ellipsis
                                                  : null,
                                              style: AppTextStyle.from(
                                                  color: AppColors.darkGrey,
                                                  size: TextSize.caption_large,
                                                  height: 1.6),
                                            ),
                                          ),
                                        ),
                                      ),
                                bloc.maxLines[idx] == true && exceeded
                                    ? emptySpaceH(height: 4)
                                    : Container(),
                                bloc.maxLines[idx] == true && exceeded
                                    ? Padding(
                                        padding:
                                            EdgeInsets.only(right: resize(24)),
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                bloc.maxLines[idx] = false;
                                              });
                                            },
                                            child: Text(
                                              AppStrings.of(StringKey.more)
                                                  .toLowerCase(),
                                              style: AppTextStyle.from(
                                                  color: AppColors.grey,
                                                  size: TextSize.caption_large),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            );
                          }),
                          bloc.diaryData[idx].contentMessage == ""
                              ? Container()
                              : emptySpaceH(height: 24),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(60),
                            color: AppColors.white,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(12),
                            color: AppColors.lightGrey01,
                          )
                        ],
                      ),
                      Positioned(
                        top: resize(48),
                        right: resize(16),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 100),
                          width: bloc.viewOptions[idx] ? 130 : 0,
                          height: bloc.viewOptions[idx] ? 100 : 0,
                          curve: Curves.linear,
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(
                                color: AppColors.lightGrey04,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: AppColors.grey,
                                    blurRadius: 1,
                                    offset: Offset(2, 2))
                              ]),
                          child: Column(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    DiaryPage.push(
                                            context,
                                            DateTime.parse(bloc
                                                .diaryData[idx].writeDateTime),
                                            true)
                                        .then((value) {
                                      bloc.add(DiaryInitEvent());
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      AppStrings.of(StringKey.edit),
                                      style: AppTextStyle.from(
                                          color: AppColors.darkGrey,
                                          weight: TextWeight.semibold,
                                          size: TextSize.caption_medium),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16)),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height: 1,
                                color: AppColors.lightGrey04,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    DiaryRepository.diaryDeleteService(
                                        bloc.diaryData[idx].id);
                                    widget.bloc.add(DiaryRemoveDateEvent(
                                        date:
                                            bloc.diaryData[idx].writeDateTime));
                                    bloc.add(DiaryInitEvent());
                                  },
                                  child: Center(
                                    child: Text(
                                      AppStrings.of(StringKey.delete),
                                      style: AppTextStyle.from(
                                          color: AppColors.darkGrey,
                                          weight: TextWeight.semibold,
                                          size: TextSize.caption_medium),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      primary: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(16),
                                            bottomRight: Radius.circular(16)),
                                      ),
                                      padding: EdgeInsets.zero,
                                      elevation: 0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                },
                itemCount: bloc.diaryData.length,
                shrinkWrap: true,
              ),
            ),
          );
  }

  Widget userStatus(String type) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(110),
      decoration: BoxDecoration(
          color: type == AppStrings.of(StringKey.practice_time)
              ? AppColors.practiceTimeColor
              : type == AppStrings.of(StringKey.mission_achievement)
                  ? AppColors.missionAchievementColor
                  : type == AppStrings.of(StringKey.activity_achievement)
                      ? AppColors.activityAchievementColor
                      : AppColors.diaryColor,
          borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.only(
          top: resize(12),
          left: resize(16),
          right: resize(16),
          bottom: resize(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: AppTextStyle.from(
                color: AppColors.white,
                size: TextSize.caption_very_small,
                weight: TextWeight.extrabold,
                letterSpacing: 0.09,
                wordSpacing: 3,
                height: 1.4),
          ),
          Expanded(child: Container()),
          Text(
            statusValue(type) ?? "",
            style: AppTextStyle.from(
                color: AppColors.white,
                size: TextSize.title_medium,
                weight: TextWeight.extrabold),
          )
        ],
      ),
    );
  }

  statusValue(String type) {
    if (type == AppStrings.of(StringKey.practice_time)) {
      String hour = "";

      if (bloc.currentStatus.practiceTimes.toInt() < 60) {
        hour = "0";
      } else if (int.parse((bloc.currentStatus.practiceTimes / 60)
              .toStringAsFixed(1)
              .substring(
                  ((bloc.currentStatus.practiceTimes / 60)
                          .toStringAsFixed(1)
                          .length -
                      1),
                  (bloc.currentStatus.practiceTimes / 60)
                      .toStringAsFixed(1)
                      .length)) >=
          5) {
        hour = ((bloc.currentStatus.practiceTimes / 60) - 1).toStringAsFixed(0);
      } else {
        hour = (bloc.currentStatus.practiceTimes / 60).toStringAsFixed(0);
      }
      String minute =
          (bloc.currentStatus.practiceTimes % 60).toStringAsFixed(0);
      return '${hour}h ${minute}m';
    } else if (type == AppStrings.of(StringKey.mission_achievement)) {
      return '${bloc.currentStatus.missionAchievement}%';
    } else if (type == AppStrings.of(StringKey.activity_achievement)) {
      return '${bloc.currentStatus.activityAchievement}%';
    } else if (type == AppStrings.of(StringKey.diary)) {
      return '${bloc.currentStatus.diary}days';
    }
  }

  Widget tapBarChild(int index) {
    return Expanded(
        child: Container(
      width: MediaQuery.of(context).size.width,
      color: AppColors.white,
      child: RaisedButton(
        onPressed: () {
          bloc.add(TapSelectEvent(index: index));
        },
        highlightElevation: 0,
        elevation: 0,
        color: AppColors.white,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
                child: Container(
              child: Center(
                child: Text(
                  index == 0
                      ? AppStrings.of(StringKey.summary)
                      : index == 1
                          ? AppStrings.of(StringKey.activity)
                          : AppStrings.of(StringKey.diary),
                  style: AppTextStyle.from(
                      color: index == bloc.tapIndex
                          ? AppColors.orange
                          : AppColors.grey,
                      size: TextSize.caption_medium,
                      weight: TextWeight.extrabold),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
            Container(
              width: MediaQuery.of(context).size.width,
              height: resize(4),
              color: index == bloc.tapIndex
                  ? AppColors.orange
                  : AppColors.transparent,
            )
          ],
        ),
      ),
    ));
  }

  Widget therapistInformation() {
    return bloc.profile.therapist == null
        ? Container()
        : Container(
            width: MediaQuery.of(context).size.width,
            height: resize(158),
            padding: EdgeInsets.all(resize(24)),
            child: Row(
              children: [
                bloc.profile.therapist.image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: Image.network(
                          bloc.profile.therapist.image,
                          width: resize(80),
                          height: resize(80),
                          fit: BoxFit.cover,
                        ),
                      )
                    : ClipOval(
                        child: Container(
                          color: AppColors.grey,
                          child: Image.asset(
                            AppImages.img_therapist_deafult,
                            width: resize(80),
                            height: resize(80),
                          ),
                        ),
                      ),
                emptySpaceW(width: 24),
                Column(
                  children: [
                    Text(
                      AppStrings.of(StringKey.your_dedicated_specialist),
                      style: AppTextStyle.from(
                          color: AppColors.grey,
                          size: TextSize.caption_small,
                          weight: TextWeight.semibold),
                    ),
                    emptySpaceH(height: 4),
                    Container(
                      height: resize(26),
                      child: Text(
                        bloc.profile.therapist.name,
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.title_small,
                            weight: TextWeight.extrabold),
                      ),
                    ),
                    emptySpaceH(height: 24),
                    Container(
                      width: resize(136),
                      height: resize(32),
                      child: RaisedButton(
                        onPressed: () {
                          widget.bloc.add(ChangeViewEvent(changeIndex: 2));
                        },
                        elevation: 0,
                        color: AppColors.lightGrey01,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Text(
                            AppStrings.of(StringKey.send_message),
                            style: AppTextStyle.from(
                                color: AppColors.darkGrey,
                                size: TextSize.caption_medium,
                                weight: TextWeight.semibold),
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          );
  }

  Widget advice() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: resize(12),
          color: AppColors.lightGrey01,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
              left: resize(24),
              right: resize(24),
              top: resize(16),
              bottom: resize(24)),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.img_sun_advice,
                    width: resize(64),
                    height: resize(64),
                  ),
                  emptySpaceW(width: 16),
                  Text(
                    AppStrings.of(StringKey.advice),
                    style: AppTextStyle.from(
                        color: AppColors.darkGrey,
                        size: TextSize.caption_large,
                        weight: TextWeight.extrabold),
                  )
                ],
              ),
              emptySpaceH(height: 16),
              Text(
                bloc.userType == "VIP"
                    ? bloc.advice
                    : AppStrings.of(StringKey.you_can_get_personalized_advice),
                style: AppTextStyle.from(
                    color: AppColors.darkGrey,
                    size: TextSize.caption_large,
                    weight: TextWeight.medium,
                    height: 1.6),
              ),
              bloc.userType == "VIP" ? Container() : emptySpaceH(height: 24),
              bloc.userType == "VIP"
                  ? Container()
                  : BottomButton(
                      onPressed: () {
                        PaymentNoticePage.push(context,
                            closeable: true,
                            isNewHomeUser: false,
                            back: true,
                            focusImg: 5,
                            logSet: 'advice');
                      },
                      text: AppStrings.of(StringKey.be_vip_member),
                    ),
            ],
          ),
        )
      ],
    );
  }

  Widget evaluationTrend() {
    return bloc.profile != null && bloc.profile.evaluationGraph != null
        ? bloc.profile.evaluationGraph[0].chartLabels.length != 0 &&
                bloc.userType == "VIP"
            ? Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: resize(12),
                    color: AppColors.lightGrey01,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: resize(24),
                        right: resize(24),
                        top: resize(16),
                        bottom: resize(16)),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppStrings.of(StringKey.evaluation_trend),
                              style: AppTextStyle.from(
                                  color: AppColors.black,
                                  size: TextSize.body_medium,
                                  weight: TextWeight.extrabold)),
                          emptySpaceH(height: 24),
                          chartData(),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: resize(12),
                    color: AppColors.lightGrey01,
                  ),
                  Image.asset(AppImages.img_trend),
                  emptySpaceH(height: 16),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding:
                        EdgeInsets.only(left: resize(24), right: resize(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.of(StringKey.evaluation_trend_vip_member),
                          style: AppTextStyle.from(
                              color: AppColors.grey,
                              size: TextSize.caption_very_small,
                              weight: TextWeight.semibold,
                              height: 1.3),
                        ),
                        emptySpaceH(height: 16),
                        BottomButton(
                          onPressed: () {
                            PaymentNoticePage.push(context,
                                closeable: true,
                                isNewHomeUser: false,
                                back: true,
                                focusImg: 5,
                                logSet: 'evaltrend');
                          },
                          text: AppStrings.of(StringKey.be_vip_member),
                        ),
                        emptySpaceH(height: 16)
                      ],
                    ),
                  )
                ],
              )
        : Container();
  }

  Widget chartData() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: resize(0.8),
              color: AppColors.lightGrey04,
            ),
            emptySpaceH(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  AppStrings.of(bloc.evaluationGraph[idx].type == "FUNCTION"
                      ? StringKey.function
                      : bloc.evaluationGraph[idx].type == "GENERAL_HEALTHCARE"
                          ? StringKey.general_healthcare
                          : bloc.evaluationGraph[idx].type == "LIFE_STYLE"
                              ? StringKey.life_style
                              : StringKey.social_activity),
                  style: AppTextStyle.from(
                      color: AppColors.darkGrey,
                      size: TextSize.caption_medium,
                      weight: TextWeight.bold),
                ),
                Expanded(child: Container()),
                Text(
                  AppStrings.of(bloc.evaluationGraph[idx].type == "FUNCTION"
                      ? StringKey.the_last_four_months
                      : StringKey.the_last_three_months),
                  style: AppTextStyle.from(
                    color: AppColors.grey,
                    size: TextSize.caption_small,
                  ),
                ),
              ],
            ),
            emptySpaceH(height: 24),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bloc
                        .evaluationGraph[idx]
                        .chartValues[
                            bloc.evaluationGraph[idx].chartValues.length - 1]
                        .y
                        .toStringAsFixed(2),
                    style: AppTextStyle.from(
                        color: AppColors.black,
                        size: TextSize.title_medium,
                        weight: TextWeight.bold),
                  ),
                  Expanded(child: Container()),
                  bloc.evaluationGraph[idx].chartValues.length > 1
                      ? Text(
                          (bloc
                                          .evaluationGraph[idx]
                                          .chartValues[bloc.evaluationGraph[idx]
                                                  .chartValues.length -
                                              1]
                                          .y -
                                      bloc
                                          .evaluationGraph[idx]
                                          .chartValues[bloc.evaluationGraph[idx]
                                                  .chartValues.length -
                                              2]
                                          .y) >
                                  0
                              ? "+${(bloc.evaluationGraph[idx].chartValues[bloc.evaluationGraph[idx].chartValues.length - 1].y - bloc.evaluationGraph[idx].chartValues[bloc.evaluationGraph[idx].chartValues.length - 2].y).toStringAsFixed(2)}"
                              : "${(bloc.evaluationGraph[idx].chartValues[bloc.evaluationGraph[idx].chartValues.length - 1].y - bloc.evaluationGraph[idx].chartValues[bloc.evaluationGraph[idx].chartValues.length - 2].y).toStringAsFixed(2)}",
                          style: AppTextStyle.from(
                              size: TextSize.caption_small,
                              weight: TextWeight.semibold,
                              color: (bloc
                                              .evaluationGraph[idx]
                                              .chartValues[bloc
                                                      .evaluationGraph[idx]
                                                      .chartValues
                                                      .length -
                                                  1]
                                              .y -
                                          bloc
                                              .evaluationGraph[idx]
                                              .chartValues[bloc
                                                      .evaluationGraph[idx]
                                                      .chartValues
                                                      .length -
                                                  2]
                                              .y) >
                                      0
                                  ? AppColors.mediumPink
                                  : AppColors.mediumBlue),
                        )
                      : Text(
                          "+0.00",
                          style: AppTextStyle.from(
                              color: AppColors.mediumPink,
                              size: TextSize.caption_small,
                              weight: TextWeight.semibold),
                        ),
                  Expanded(child: Container()),
                  Container(
                    width: resize(120),
                    height: resize(26),
                    child: LineChart(
                      linesData(
                          chartValue: bloc.evaluationGraph[idx].chartValues,
                          color:
                              bloc.evaluationGraph[idx].chartValues.length > 1
                                  ? (bloc
                                                  .evaluationGraph[idx]
                                                  .chartValues[bloc
                                                          .evaluationGraph[idx]
                                                          .chartValues
                                                          .length -
                                                      1]
                                                  .y -
                                              bloc
                                                  .evaluationGraph[idx]
                                                  .chartValues[bloc
                                                          .evaluationGraph[idx]
                                                          .chartValues
                                                          .length -
                                                      2]
                                                  .y) >
                                          0
                                      ? true
                                      : false
                                  : true),
                      swapAnimationDuration: Duration(milliseconds: 250),
                    ),
                  )
                ],
              ),
            ),
            emptySpaceH(height: 24)
          ],
        );
      },
      itemCount: bloc.evaluationGraph.length,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
    );
  }

  LineChartData linesData({List<ChartValues> chartValue, bool color}) {
    return LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        minY: 0,
        maxY: 5,
        lineBarsData: linesBarData(chartValue: chartValue, color: color));
  }

  List<LineChartBarData> linesBarData(
      {List<ChartValues> chartValue, bool color}) {
    List<FlSpot> flSpots = List();
    if (chartValue.length == 1) {
      flSpots.add(FlSpot(0, 0));
    }
    for (int i = 0; i < chartValue.length; i++) {
      if (chartValue.length == 1) {
        flSpots.add(FlSpot(i + 1.toDouble(),
            double.parse(chartValue[i].y.toStringAsFixed(2))));
      } else {
        flSpots.add(FlSpot(
            i.toDouble(), double.parse(chartValue[i].y.toStringAsFixed(2))));
      }
    }
    return [
      LineChartBarData(
          spots: flSpots,
          isCurved: true,
          colors: [color ? AppColors.mediumPink : AppColors.mediumBlue],
          isStrokeCapRound: true,
          barWidth: 4,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: false))
    ];
  }

  Widget _buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  PreferredSize _buildAppBar(BuildContext context) {
    return baseAppBar(context,
        title: AppStrings.of(StringKey.my_report),
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
                  NotificationListPage.push(ctx, widget.bloc);
                }),
          )
        ]);
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

  @override
  blocListener(BuildContext context, state) {
    if (state is LoadingState) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.diary != null && widget.diary) {
      bloc.tapIndex = 2;
      bloc.add(DiaryInitEvent());
    }
  }

  @override
  MyReportBloc initBloc() {
    return MyReportBloc(context)..add(MyReportInitEvent());
  }
}
