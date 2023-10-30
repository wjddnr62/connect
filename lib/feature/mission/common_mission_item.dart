import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/bookmark/bookmark_bloc.dart';
import 'package:connect/feature/home/home_bloc.dart';
import 'package:connect/feature/mission/activity_mission_page.dart';
import 'package:connect/feature/mission/card_reading_mission_page.dart';
import 'package:connect/feature/mission/common_mission_bloc.dart';
import 'package:connect/feature/mission/exercise_basics_mission_page.dart';
import 'package:connect/feature/mission/quiz_mission_page.dart';
import 'package:connect/feature/mission/video_mission_page.dart';
import 'package:connect/feature/payment/payment_description_page.dart';
import 'package:connect/feature/payment/payment_notice_page.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class CommonMissionItem extends BlocStatefulWidget {
  final Mission mission;
  final DateTime date;
  final HomeBloc homeBloc;
  final String userType;
  final bool day1Check;
  final Profile profile;
  final bool bookmark;
  final BookmarkBloc bookmarkBloc;

  CommonMissionItem(
      {this.date,
      this.mission,
      this.homeBloc,
      this.userType,
      this.day1Check,
      this.profile,
      this.bookmark,
      this.bookmarkBloc});

  @override
  _CommonMissionItemState buildState() => _CommonMissionItemState(
      date: date,
      mission: mission,
      homeBloc: homeBloc,
      userType: userType,
      day1Check: day1Check,
      profile: profile,
      bookmark: bookmark ?? false,
      bookmarkBloc: bookmarkBloc);
}

class _CommonMissionItemState
    extends BlocState<CommonMissionBloc, CommonMissionItem> {
  final Mission mission;
  final DateTime date;
  final HomeBloc homeBloc;
  final String userType;
  final bool day1Check;
  final Profile profile;
  final bool bookmark;
  final BookmarkBloc bookmarkBloc;

  _CommonMissionItemState(
      {this.date,
      this.mission,
      this.homeBloc,
      this.userType,
      this.day1Check,
      this.profile,
      this.bookmark,
      this.bookmarkBloc});

  @override
  blocListener(BuildContext context, state) {
    if (state is MissionTouchState) {
      bool missionCheck = bloc.mission.completed;
      if (state.mission == "CARD") {
        CardReadingMissionPage.push(context, bloc: bloc, bookmark: bookmark)
            .then((value) {
          inMission = false;
          if (bookmark && (bookmark != bloc.missionDetail.isBookmark)) {
            bookmarkBloc.add(BookmarkInitEvent());
          }
          homeBloc.completed = value ?? false;
          if ((missionCheck != bloc.mission.completed) && !bookmark) {
            homeBloc.add(RefreshIndicatorCallEvent(selectDate: bloc.date));
          }
        });
      } else if (state.mission == "VIDEO") {
        VideoMissionPage.push(context, bloc: bloc, bookmark: bookmark)
            .then((value) {
          inMission = false;
          if (bookmark && (bookmark != bloc.missionDetail.isBookmark)) {
            bookmarkBloc.add(BookmarkInitEvent());
          }
          homeBloc.completed = value;
          if ((missionCheck != bloc.mission.completed) && !bookmark) {
            homeBloc.add(RefreshIndicatorCallEvent(selectDate: bloc.date));
          }
        });
      } else if (state.mission == "EXERCISE") {
        ExerciseBasicsMissionPage.push(context, bloc: bloc, bookmark: bookmark)
            .then((value) {
          inMission = false;
          if (bookmark && (bookmark != bloc.missionDetail.isBookmark)) {
            bookmarkBloc.add(BookmarkInitEvent());
          }
          homeBloc.completed = value;
          if ((missionCheck != bloc.mission.completed) && !bookmark) {
            homeBloc.add(RefreshIndicatorCallEvent(selectDate: bloc.date));
          }
        });
      } else if (state.mission == "ACTIVITY") {
        ActivityMissionPage.push(context, bloc: bloc).then((value) {
          homeBloc.completed = value;
          inMission = false;

          if ((missionCheck != bloc.mission.completed) && !bookmark) {
            homeBloc.add(RefreshIndicatorCallEvent(selectDate: bloc.date));
          }
        });
      } else if (state.mission == "QUIZ") {
        QuizMissionPage.push(context, bloc: bloc, date: date).then((value) {
          homeBloc.completed = value;
          inMission = false;
          if ((missionCheck != bloc.mission.completed) && !bookmark) {
            homeBloc.add(RefreshIndicatorCallEvent(selectDate: bloc.date));
          }
        });
      }
    }
  }

  @override
  CommonMissionBloc initBloc() =>
      CommonMissionBloc(context, date: date, mission: mission, profile: profile)
        ..add(InitEvent());

  showMissionType(type) {
    if (type == "QUIZ") {
      return "Quiz";
    } else if (type == "ACTIVITY") {
      return "Activity";
    } else if (type == "BASICS") {
      return "Exercise";
    } else if (type == "VIDEO") {
      return "Video";
    } else if (type == "READING") {
      return "Reading";
    }
  }

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          Widget container = Container(
              height: resize(90),
              width: resize(360),
              decoration: BoxDecoration(
                  color: _colorMission(bloc.mission),
                  borderRadius: BorderRadius.all(Radius.circular(resize(16)))),
              child: Container(
                child: Row(children: <Widget>[
                  Container(
                    margin:
                        EdgeInsets.only(left: resize(18), right: resize(12)),
                    height: resize(32),
                    width: resize(32),
                    child: _getMainIcon(bloc.mission),
                  ),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(top: resize(6), bottom: resize(0)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bloc.mission.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.from(
                              height: 1.4,
                              color: AppColors.black,
                              size: TextSize.caption_medium,
                              weight: TextWeight.bold),
                        ),
                        emptySpaceH(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: resize(16),
                              child: Text(
                                showMissionType(bloc.mission.type) ?? "",
                                style: AppTextStyle.from(
                                    size: TextSize.caption_small,
                                    color: AppColors.darkGrey,
                                    weight: TextWeight.bold),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )),
                  Container(
                    margin: EdgeInsets.only(right: resize(8)),
                    height: resize(76),
                    width: resize(70),
                    child: _getIcon(bloc.mission),
                  ),
                ]),
              ));

          return Container(
              margin: EdgeInsets.only(
                  bottom: resize(8), left: resize(16), right: resize(16)),
              child: GestureDetector(
                  onTap: () => _onPress(),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding:
                            EdgeInsets.only(left: resize(8), right: resize(8)),
                        child: Container(
                            height: resize(98),
                            padding: EdgeInsets.only(top: resize(8)),
                            child: container),
                      ),
                      bloc.mission.completed ?? false
                          ? Container()
                          : vipMissionLogo(mission),
                      bloc.mission.completed ?? false
                          ? completeIcon()
                          : Container()
                      // _buildMissionIconWhenComplete(mission)
                    ],
                  )));
        });
  }

  completeIcon() {
    return Positioned(
      top: 0,
      right: 0,
      child: Image.asset(AppImages.ic_check_circle_mission),
      width: resize(30),
      height: resize(30),
    );
  }

  vipMissionLogo(Mission mission) {
    if (mission.isFree != null && !mission.isFree) {
      return Positioned(
        bottom: resize(8),
        right: resize(16),
        child: Image.asset(AppImages.img_vip),
        width: resize(32),
        height: resize(18),
      );
    } else {
      return Container();
    }
  }

  Widget _buildMissionIconWhenComplete(Mission mission) {
    if (!mission.completed) return Container();
    var bgColor = AppColors.transparent;
    var icon = '';

    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
        bgColor = AppColors.ic_activity_bg;
        icon = AppImages.ic_activity_white;
        break;
      case MISSION_TYPE_CARD_READING:
        bgColor = AppColors.ic_reading_bg;
        icon = AppImages.ic_reading_white;
        break;
      case MISSION_TYPE_EXERCISE_BASICS:
        bgColor = AppColors.ic_exercise_bg;
        icon = AppImages.ic_exercise_white;
        break;
      case MISSION_TYPE_VIDEO:
        bgColor = AppColors.ic_video_bg;
        icon = AppImages.ic_video_white;
        break;
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: resize(44),
        height: resize(44),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
            color: bgColor),
        alignment: Alignment.center,
        child: Image.asset(
          icon,
          width: resize(28),
          height: resize(28),
        ),
      ),
    );
  }

  Color _colorMission(Mission mission) {
    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
        return AppColors.missionActivity;
      case MISSION_TYPE_EXERCISE_BASICS:
        return AppColors.missionExerciseBasic;
      case MISSION_TYPE_VIDEO:
        return AppColors.missionVideo;
      case MISSION_TYPE_CARD_READING:
        return AppColors.missionReading;
      case MISSION_TYPE_QUIZ:
        return AppColors.missionQuiz;
      default:
        return AppColors.lightGrey04;
    }
  }

  Widget _getMainIcon(Mission mission) {
    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
        return Image.asset(AppImages.ic_mission_activity);
      case MISSION_TYPE_EXERCISE_BASICS:
        return Image.asset(AppImages.ic_mission_exercise_basic);
      case MISSION_TYPE_VIDEO:
        return Image.asset(AppImages.ic_mission_video);
      case MISSION_TYPE_CARD_READING:
        return Image.asset(AppImages.ic_mission_reading);
      case MISSION_TYPE_QUIZ:
        return Image.asset(AppImages.img_quiz);
      default:
        return Image.asset(AppImages.illust_no_mission);
    }
  }

  Widget _getIcon(Mission mission) {
    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
        return Image.asset(AppImages.img_activity);
      case MISSION_TYPE_EXERCISE_BASICS:
        return Image.asset(AppImages.img_exercise_basic);
      case MISSION_TYPE_VIDEO:
        return Image.asset(AppImages.img_video);
      case MISSION_TYPE_CARD_READING:
        return Image.asset(AppImages.img_reading);
      case MISSION_TYPE_QUIZ:
        return Image.asset(AppImages.img_quiz);
      default:
        return Image.asset(AppImages.illust_no_mission);
    }
  }

  bool inMission = false;

  _onPress() async {
    print("CHECK : $inMission");
    if (!inMission) {
      if (bloc.mission.type == MISSION_TYPE_CARD_READING && !inMission) {
        _logStart();
        if (userType == "" && !bloc.mission.isFree) {
          inMission = true;
          PaymentNoticePage.push(context,
                  back: true,
                  closeable: true,
                  focusImg: 3,
                  logSet: 'vip_content')
              .then((value) {
            inMission = false;
          });
        } else {
          inMission = true;
          bloc.add(MissionTouchEvent(mission: "CARD"));
        }
        return;
      }

      if (bloc.mission.type == MISSION_TYPE_VIDEO && !inMission) {
        _logStart();
        if (userType == "" && !bloc.mission.isFree) {
          inMission = true;
          PaymentNoticePage.push(context,
                  back: true,
                  closeable: true,
                  focusImg: 3,
                  logSet: 'vip_content')
              .then((value) {
            inMission = false;
          });
        } else {
          inMission = true;
          bloc.add(MissionTouchEvent(mission: "VIDEO"));
        }
        return;
      }

      if (bloc.mission.type == MISSION_TYPE_EXERCISE_BASICS && !inMission) {
        _logStart();
        if (userType == "" && !bloc.mission.isFree) {
          inMission = true;
          PaymentNoticePage.push(context,
                  back: true,
                  closeable: true,
                  focusImg: 3,
                  logSet: 'vip_content')
              .then((value) {
            inMission = false;
          });
        } else {
          inMission = true;
          bloc.add(MissionTouchEvent(mission: "EXERCISE"));
        }
        return;
      }

      if (bloc.mission.type == MISSION_TYPE_ACTIVITY && !inMission) {
        _logStart();
        if (userType == "" &&
            (bloc.mission.isFree != null && !bloc.mission.isFree)) {
          inMission = true;
          PaymentNoticePage.push(context,
                  back: true,
                  closeable: true,
                  focusImg: 3,
                  logSet: 'vip_content')
              .then((value) {
            inMission = false;
          });
        } else {
          inMission = true;
          bloc.add(MissionTouchEvent(mission: "ACTIVITY"));
        }
        return;
      }

      if (bloc.mission.type == MISSION_TYPE_QUIZ && !inMission) {
        _logStart();
        if (userType == "" && !bloc.mission.isFree) {
          inMission = true;
          PaymentNoticePage.push(context,
                  back: true,
                  closeable: true,
                  focusImg: 3,
                  logSet: 'vip_content')
              .then((value) {
            inMission = false;
          });
        } else {
          inMission = true;
          bloc.add(MissionTouchEvent(mission: "QUIZ"));
        }
        return;
      }
    }
  }

  _logStart() {
    String tag = "mission_start_";
    switch (mission.type) {
      case MISSION_TYPE_ACTIVITY:
        tag = tag + 'activity';
        break;
      case MISSION_TYPE_CARD_READING:
        tag = tag + 'reading';
        break;
      case MISSION_TYPE_EXERCISE_BASICS:
        tag = tag + 'exercise_basic';
        break;
      case MISSION_TYPE_VIDEO:
        tag = tag + 'video';
        break;
      case MISSION_TYPE_QUIZ:
        tag = tag + 'quiz';
        break;
    }

    UserLogger.logEventName(eventName: tag, param: {"id": mission.id});
  }

  String _getType() {
    switch (bloc.mission.type) {
      case MISSION_TYPE_ACTIVITY:
        return AppStrings.of(StringKey.mission_activity);
      case MISSION_TYPE_EXERCISE_BASICS:
        return AppStrings.of(StringKey.exercise_basics);
      case MISSION_TYPE_VIDEO:
        return AppStrings.of(StringKey.video);
      case MISSION_TYPE_CARD_READING:
        return AppStrings.of(StringKey.card_reading);
      case MISSION_TYPE_QUIZ:
        return AppStrings.of(StringKey.quiz);
      default:
    }
    return '';
  }
}
