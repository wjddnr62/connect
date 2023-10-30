import 'dart:io';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/tracker/tracker_page.dart';
import 'package:connect/feature/tracker/tracker_setting_bloc.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:connect/models/tracking.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:connect/utils/extensions.dart';

class TrackerSettingPage extends BlocStatefulWidget {
  final bool reset;
  final DateTime dateTime;
  final String id;
  final GoalTracking goalTracking;
  final bool myReport;
  final HomeNavigationBloc homeNavigationBloc;

  TrackerSettingPage(
      {this.reset,
      this.dateTime,
      this.id,
      this.goalTracking,
      this.myReport,
      this.homeNavigationBloc});

  static Future<Object> push(
      BuildContext context, bool reset, DateTime dateTime,
      {String id,
      GoalTracking goalTracking,
      bool myReport,
      HomeNavigationBloc homeNavigationBloc}) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TrackerSettingPage(
              reset: reset,
              dateTime: dateTime,
              id: id,
              goalTracking: goalTracking,
              myReport: myReport,
              homeNavigationBloc: homeNavigationBloc,
            )));
  }

  @override
  TrackerSettingState buildState() => TrackerSettingState();
}

class TrackerSettingState
    extends BlocState<TrackerSettingBloc, TrackerSettingPage> {
  final goalTextController = TextEditingController();

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
      cubit: bloc,
      builder: (context, state) {
        return SafeArea(
          top: false,
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: baseAppBar(context,
                automaticallyImplyLeading: false,
                leading: IconButton(
                    icon: Image.asset(
                      AppImages.ic_delete,
                      width: resize(24),
                      height: resize(24),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    })),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
              },
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: resize(24), right: resize(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          emptySpaceH(height: 8),
                          titleView(),
                          bloc.pageNum == 1
                              ? Container()
                              : emptySpaceH(height: 16),
                          bloc.pageNum == 1 ? Container() : subTitleView(),
                          emptySpaceH(height: 24),
                          viewItem(),
                          emptySpaceH(height: 4),
                          bloc.pageNum == 2
                              ? Container()
                              : Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: Text(
                                    AppStrings.of(StringKey.your_activity_goal),
                                    style: AppTextStyle.from(
                                        color: AppColors.grey,
                                        size: TextSize.caption_small,
                                        height: 1.3),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          emptySpaceH(
                              height: bloc.pageNum == 0
                                  ? 14
                                  : bloc.pageNum == 1
                                      ? 20
                                      : 20),
                          footerButton(),
                          emptySpaceH(height: 24)
                        ],
                      ),
                    ),
                  ),
                  _buildProgress(context)
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  viewItem() {
    if (bloc.pageNum == 0) {
      return goalSetting();
    } else if (bloc.pageNum == 1) {
      return specificGoalSetting();
    } else {
      return trackingSetting();
    }
  }

  footerButton() {
    if (bloc.pageNum == 0) {
      return BottomButton(
        onPressed: bloc.selectGoalText != ""
            ? () {
                bloc.add(PageNumChangeEvent(pageNum: bloc.pageNum + 1));
              }
            : null,
        text: AppStrings.of(StringKey.next),
        textColor: AppColors.white,
      );
    } else {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: resize(54),
        child: Row(
          children: [
            widget.reset
                ? Container()
                : Expanded(
                    child: ElevatedButton(
                    onPressed: () {
                      bloc.add(PageNumChangeEvent(pageNum: bloc.pageNum - 1));
                    },
                    child: Center(
                      child: Text(
                        AppStrings.of(StringKey.previous),
                        style: AppTextStyle.from(
                            color: AppColors.purple,
                            size: TextSize.caption_large,
                            weight: TextWeight.semibold),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        primary: AppColors.white,
                        side: BorderSide(color: AppColors.purple, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0),
                  )),
            widget.reset ? Container() : emptySpaceW(width: 8),
            Expanded(
                child: ElevatedButton(
              onPressed: bloc.pageNum == 2 ||
                      (bloc.pageNum == 1 && bloc.selectSpecificGoalText != "" ||
                          (bloc.selectSpecificGoal[
                                  bloc.specificGoalTexts.length - 1] &&
                              goalTextController.text != ""))
                  ? () async {
                      if (bloc.pageNum == 1) {
                        bloc.add(PageNumChangeEvent(pageNum: bloc.pageNum + 1));
                      } else {
                        if (widget.reset) {
                          GoalTracking goalTracking = GoalTracking(
                              goalStep:
                                  int.parse(bloc.trackingControllers[0].text),
                              goalUpper:
                                  int.parse(bloc.trackingControllers[1].text),
                              goalLower:
                                  int.parse(bloc.trackingControllers[2].text),
                              goalWhole:
                                  int.parse(bloc.trackingControllers[3].text),
                              goalSocial:
                                  int.parse(bloc.trackingControllers[4].text));
                          bloc.add(FinishReSettingEvent(
                              goalTracking: goalTracking, id: widget.id));
                        } else {
                          if (Platform.isAndroid) {
                            if (await requestActivityRecognition()) {
                              TrackerGoal trackerGoal = TrackerGoal(
                                userId: await AppDao.userId,
                                yearMonth: widget.dateTime.yyyymm,
                                goalScale: GoalScale(
                                    seq: bloc.selectGoal.indexOf(true),
                                    goalDescription: bloc.selectGoalText),
                                goalSpecificScale: GoalScale(
                                    seq: bloc.selectSpecificGoal.indexOf(true),
                                    goalDescription: bloc.selectSpecificGoal[
                                            bloc.specificGoalTexts.length - 1]
                                        ? goalTextController.text
                                        : bloc.selectSpecificGoalText),
                                goalStep:
                                    int.parse(bloc.trackingControllers[0].text),
                                goalUpper:
                                    int.parse(bloc.trackingControllers[1].text),
                                goalLower:
                                    int.parse(bloc.trackingControllers[2].text),
                                goalWhole:
                                    int.parse(bloc.trackingControllers[3].text),
                                goalSocial:
                                    int.parse(bloc.trackingControllers[4].text),
                              );
                              bloc.add(
                                  FinishSettingEvent(trackerGoal: trackerGoal));
                            }
                          } else {
                            TrackerGoal trackerGoal = TrackerGoal(
                              userId: await AppDao.userId,
                              yearMonth: widget.dateTime.yyyymm,
                              goalScale: GoalScale(
                                  seq: bloc.selectGoal.indexOf(true),
                                  goalDescription: bloc.selectGoalText),
                              goalSpecificScale: GoalScale(
                                  seq: bloc.selectSpecificGoal.indexOf(true),
                                  goalDescription: bloc.selectSpecificGoal[
                                          bloc.specificGoalTexts.length - 1]
                                      ? goalTextController.text
                                      : bloc.selectSpecificGoalText),
                              goalStep:
                                  int.parse(bloc.trackingControllers[0].text),
                              goalUpper:
                                  int.parse(bloc.trackingControllers[1].text),
                              goalLower:
                                  int.parse(bloc.trackingControllers[2].text),
                              goalWhole:
                                  int.parse(bloc.trackingControllers[3].text),
                              goalSocial:
                                  int.parse(bloc.trackingControllers[4].text),
                            );
                            bloc.add(
                                FinishSettingEvent(trackerGoal: trackerGoal));
                          }
                        }
                      }
                    }
                  : null,
              child: Center(
                child: Text(
                  AppStrings.of(
                      bloc.pageNum == 1 ? StringKey.next : StringKey.done),
                  style: AppTextStyle.from(
                      color: AppColors.white,
                      size: TextSize.caption_large,
                      weight: TextWeight.semibold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  primary: AppColors.purple,
                  side: bloc.pageNum == 2 ||
                          bloc.selectSpecificGoalText != "" ||
                          (bloc.selectSpecificGoal[
                                  bloc.specificGoalTexts.length - 1] &&
                              goalTextController.text != "")
                      ? BorderSide(color: AppColors.purple, width: 2)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0),
            )),
          ],
        ),
      );
    }
  }

  titleView() {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Text(
          (widget.reset && bloc.pageNum == 0)
              ? AppStrings.of(StringKey.lets_set_your_new_goal)
              : bloc.titles[bloc.pageNum],
          style: AppTextStyle.from(
              color: AppColors.black,
              size: TextSize.title_medium,
              weight: TextWeight.extrabold,
              height: 1.25),
        ));
  }

  subTitleView() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Text(
        bloc.subTitles[bloc.pageNum],
        style: AppTextStyle.from(
            color: AppColors.grey,
            weight: TextWeight.semibold,
            size: TextSize.caption_medium,
            letterSpacing: -0.1,
            height: 1.4),
      ),
    );
  }

  goalSetting() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Column(
          children: [
            settingItem(bloc.goalTexts[idx], idx, 0),
            emptySpaceH(height: 12)
          ],
        );
      },
      itemCount: bloc.goalTexts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  settingItem(String content, int index, int type) {
    return GestureDetector(
      onTap: () {
        if (type == 0) {
          bloc.add(SelectGoalEvent(selectIndex: index));
        } else if (type == 1) {
          bloc.selectSpecificGoalText = "";
          bloc.selectIndex = index;
          if (index != bloc.specificGoalTexts.length - 1) {
            goalTextController.text = "";
          }
          bloc.add(SelectSpecificGoalEvent(selectIndex: index));
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: resize(54),
        decoration: BoxDecoration(
            color: AppColors.lightGrey01,
            borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.only(left: resize(16), right: resize(16)),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              child: ClipOval(
                child: bloc.selectGoal.length != 0 && bloc.selectGoal.isNotEmpty
                    ? Image.asset(
                        (type == 0
                                ? bloc.selectGoal[index]
                                : bloc.selectSpecificGoal[index])
                            ? AppImages.tracker_radio_select
                            : AppImages.tracker_radio_default,
                        width: resize(24),
                        height: resize(24),
                      )
                    : Container(),
              ),
            ),
            emptySpaceW(width: 12),
            Flexible(
              child: Text(
                type == 0
                    ? bloc.goalTexts[index]
                    : bloc.specificGoalTexts[index],
                style: AppTextStyle.from(
                    color: AppColors.darkGrey,
                    size: TextSize.caption_medium,
                    weight: TextWeight.semibold,
                    height: 1.3),
              ),
            )
          ],
        ),
      ),
    );
  }

  specificGoalSetting() {
    return ListView.builder(
      itemBuilder: (context, idx) {
        return Column(
          children: [
            settingItem(bloc.specificGoalTexts[idx], idx, 1),
            emptySpaceH(height: 12),
            (idx == bloc.specificGoalTexts.length - 1)
                ? Padding(
                    padding: EdgeInsets.only(top: resize(4)),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: resize(100),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.lightGrey04),
                        color: bloc.selectSpecificGoal[
                                bloc.specificGoalTexts.length - 1]
                            ? AppColors.white
                            : AppColors.lightGrey02,
                      ),
                      child: TextFormField(
                          controller: goalTextController,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.done,
                          maxLines: null,
                          onChanged: (text) {
                            setState(() {});
                          },
                          enabled: bloc.selectSpecificGoal[
                                  bloc.specificGoalTexts.length - 1]
                              ? true
                              : false,
                          style: AppTextStyle.from(
                              size: TextSize.caption_medium,
                              color: AppColors.black),
                          cursorColor: AppColors.purple,
                          decoration: InputDecoration(
                              hintText: AppStrings.of(
                                  StringKey.enter_your_details_here),
                              hintStyle: AppTextStyle.from(
                                  size: TextSize.caption_medium,
                                  color: AppColors.lightGrey03),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: resize(16),
                                  right: resize(16),
                                  top: resize(8),
                                  bottom: resize(8)))),
                    ),
                  )
                : Container()
          ],
        );
      },
      itemCount: bloc.specificGoalTexts.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
    );
  }

  trackingItem(int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: resize(78),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              bloc.trackingImages[index],
              width: resize(32),
              height: resize(32),
            ),
          ),
          emptySpaceW(width: 14),
          Column(
            children: [
              Container(
                width: resize(160),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      height: resize(16),
                      child: Text(
                        bloc.trackingNames[index],
                        style: AppTextStyle.from(
                            color: AppColors.grey,
                            size: TextSize.caption_small,
                            weight: TextWeight.bold),
                      ),
                    ),
                    Expanded(child: Container()),
                    GestureDetector(
                      onTap: () {
                        trakingInfoDialog(context, bloc.trackingNames[index],
                            bloc.trackingDescriptions[index]);
                      },
                      child: Image.asset(
                        AppImages.ic_info_circle,
                        width: resize(20),
                        height: resize(20),
                        color: AppColors.grey,
                      ),
                    )
                  ],
                ),
              ),
              emptySpaceH(height: 10),
              Container(
                width: resize(160),
                height: resize(48),
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.lightGrey04),
                    borderRadius: BorderRadius.circular(4)),
                child: TextFormField(
                  controller: bloc.trackingControllers[index],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  style: AppTextStyle.from(
                      weight: TextWeight.extrabold,
                      size: TextSize.title_medium,
                      color: AppColors.black),
                  cursorColor: AppColors.black,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: false,
                      contentPadding: EdgeInsets.only(
                          left: resize(16),
                          right: resize(16),
                          top: resize(9),
                          bottom: resize(9))),
                ),
              )
            ],
          ),
          emptySpaceW(width: 16),
          Container(
            width: resize(40),
            height: resize(40),
            child: ElevatedButton(
              onPressed: () {
                if (int.parse(bloc.trackingControllers[index].text) != 0) {
                  if (index == 0) {
                    bloc.trackingControllers[index].text =
                        (int.parse(bloc.trackingControllers[index].text) - 100)
                            .toString();
                  } else {
                    bloc.trackingControllers[index].text =
                        (int.parse(bloc.trackingControllers[index].text) - 1)
                            .toString();
                  }
                }
              },
              child: Container(
                width: resize(40),
                height: resize(40),
                child: Center(
                  child: Image.asset(
                    AppImages.ic_tracker_minus,
                    width: resize(24),
                    height: resize(24),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  primary: AppColors.lightGrey01,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0),
            ),
          ),
          emptySpaceW(width: 10),
          Container(
            width: resize(40),
            height: resize(40),
            child: ElevatedButton(
              onPressed: () {
                if (index == 0) {
                  bloc.trackingControllers[index].text =
                      (int.parse(bloc.trackingControllers[index].text) + 100)
                          .toString();
                } else {
                  bloc.trackingControllers[index].text =
                      (int.parse(bloc.trackingControllers[index].text) + 1)
                          .toString();
                }
              },
              child: Container(
                width: resize(40),
                height: resize(40),
                child: Center(
                  child: Image.asset(
                    AppImages.ic_tracker_add,
                    width: resize(24),
                    height: resize(24),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  primary: AppColors.lightGrey01,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0),
            ),
          )
        ],
      ),
    );
  }

  trackingSetting() {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, idx) {
        return Column(
          children: [trackingItem(idx), emptySpaceH(height: 22)],
        );
      },
      shrinkWrap: true,
      itemCount: bloc.trackingImages.length,
    );
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is FinishSettingState) {
      TrackerPage.push(context, widget.dateTime,
              bloc: widget.homeNavigationBloc, saveTrackerData: widget.myReport)
          .then((value) {
        Navigator.of(context).pop(true);
      });
    }

    if (state is FinishReSettingState) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  TrackerSettingBloc initBloc() {
    return TrackerSettingBloc(context)
      ..add(TrackerSettingInitEvent(
          reset: widget.reset, goalTracking: widget.goalTracking));
  }
}

trakingInfoDialog(context, String title, String content) {
  showDialog(
      barrierDismissible: true,
      barrierColor: AppColors.transparent,
      context: (context),
      builder: (_) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
          child: Dialog(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
            backgroundColor: AppColors.white,
            child: Padding(
              padding: EdgeInsets.only(
                  top: resize(24),
                  bottom: resize(24),
                  left: resize(20),
                  right: resize(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListView(
                    shrinkWrap: true,
                    children: [
                      Text(
                        title.split("(")[0],
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.caption_medium,
                            weight: TextWeight.bold),
                      ),
                      emptySpaceH(height: 12),
                      Text(
                        content,
                        style: AppTextStyle.from(
                            color: AppColors.darkGrey,
                            size: TextSize.caption_medium,
                            weight: TextWeight.semibold,
                            height: 1.4),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
}
