import 'dart:io';

import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/feature/tracker/tracker_achieve_calendar_page.dart';
import 'package:connect/feature/tracker/tracker_bloc.dart';
import 'package:connect/models/tracking.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/bottons/bottom_button.dart';
import 'package:connect/widgets/dialog/fullscreen_dialog.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:connect/utils/extensions.dart';

import 'tracker_setting_page.dart';

class TrackerPage extends BlocStatefulWidget {
  final DateTime date;
  final bool myReport;
  final HomeNavigationBloc bloc;
  final bool saveTrackerData;

  TrackerPage({this.date, this.myReport, this.bloc, this.saveTrackerData});

  static Future<Object> push(BuildContext context, DateTime date,
      {bool myReport, HomeNavigationBloc bloc, bool saveTrackerData}) {
    return Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TrackerPage(
              date: date,
              myReport: myReport ?? false,
              bloc: bloc ?? null,
              saveTrackerData: saveTrackerData ?? false,
            )));
  }

  @override
  TrackerState buildState() => TrackerState();
}

class TrackerState extends BlocState<TrackerBloc, TrackerPage> {
  List<String> items = ['step', 'upper', 'lower', 'whole', 'social'];

  List<String> trackingImages = [
    AppImages.ic_steps,
    AppImages.ic_upper_body,
    AppImages.ic_lower_body,
    AppImages.ic_whole_body,
    AppImages.ic_globe
  ];

  @override
  Widget blocBuilder(BuildContext context, state) {
    return BlocBuilder(
        cubit: bloc,
        builder: (context, state) {
          return GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Scaffold(
              backgroundColor: AppColors.white,
              appBar: widget.myReport
                  ? null
                  : baseAppBar(context,
                      automaticallyImplyLeading: false,
                      centerTitle: true,
                      title: AppStrings.of(StringKey.keep_your_body_moving),
                      leading: IconButton(
                          icon: Image.asset(
                            AppImages.ic_chevron_left,
                            width: resize(24),
                            height: resize(24),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          })),
              body: Stack(
                children: [
                  NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowGlow();
                      return;
                    },
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          emptySpaceH(height: 16),
                          Padding(
                            padding: EdgeInsets.only(
                                left: resize(24), right: resize(24)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title(),
                                emptySpaceH(height: 22),
                                recordIndicator(),
                                emptySpaceH(height: 20),
                                trackingData(),
                                widget.myReport
                                    ? Container()
                                    : emptySpaceH(height: 2),
                                Padding(
                                  padding: EdgeInsets.only(left: resize(46)),
                                  child: GestureDetector(
                                    onTap: () {
                                      GoalTracking goalTracking = GoalTracking(
                                          goalStep: bloc
                                              .trackingData.goalInfo.goalStep,
                                          goalUpper: bloc
                                              .trackingData.goalInfo.goalUpper,
                                          goalLower: bloc
                                              .trackingData.goalInfo.goalLower,
                                          goalWhole: bloc
                                              .trackingData.goalInfo.goalWhole,
                                          goalSocial: bloc.trackingData.goalInfo
                                              .goalSocial);
                                      TrackerSettingPage.push(
                                              context, true, widget.date,
                                              id: bloc.trackingData.goalInfo.id,
                                              goalTracking: goalTracking)
                                          .then((value) {
                                        bloc.add(TrackerInitEvent(
                                            context: context,
                                            date: widget.date.isoYYYYMMDD));
                                      });
                                    },
                                    child: Container(
                                      child: Text(
                                        AppStrings.of(StringKey.goal_setting),
                                        style: AppTextStyle.from(
                                            color: AppColors.darkGrey,
                                            size: TextSize.caption_medium),
                                      ),
                                    ),
                                  ),
                                ),
                                emptySpaceH(height: 24)
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(12),
                            color: AppColors.lightGrey01,
                          ),
                          Padding(
                            padding: EdgeInsets.all(resize(24)),
                            child: trackingChart(),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: resize(12),
                            color: AppColors.lightGrey01,
                          ),
                          Padding(
                            padding: EdgeInsets.all(resize(24)),
                            child: footer(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildProgress(context)
                ],
              ),
            ),
          );
        });
  }

  title() {
    return Container(
      height: resize(32),
      child: Row(
        children: [
          Text(
            AppStrings.of(widget.myReport
                ? StringKey.activity_tracker
                : StringKey.record_activity),
            style: AppTextStyle.from(
                color: AppColors.black,
                size: TextSize.title_medium,
                weight: TextWeight.extrabold),
          ),
          Expanded(child: Container()),
          widget.myReport
              ? SizedBox(
                  width: resize(40),
                  height: resize(40),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      TrackerAchieveCalendarPage.push(context);
                    },
                    icon: Image.asset(
                      AppImages.btn_date,
                      width: resize(40),
                      height: resize(40),
                    ),
                  ),
                )
              : Container()
        ],
      ),
    );
  }

  recordIndicator() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            bloc.trackingData != null
                ? '${bloc.trackingData.activityAchievement.toStringAsFixed(0) ?? "0"}%'
                : "0%",
            style: AppTextStyle.from(
                color: AppColors.lightGrey03,
                size: TextSize.caption_small,
                weight: TextWeight.bold),
          ),
          emptySpaceH(height: 8),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            progressColor: AppColors.purple,
            backgroundColor: AppColors.lightGrey02,
            percent: bloc.trackingData != null
                ? bloc.trackingData.activityAchievement / 100
                : 0,
            lineHeight: resize(8),
          ),
          emptySpaceH(height: 30),
          Container(
            width: MediaQuery.of(context).size.width,
            height: resize(0.8),
            color: AppColors.lightGrey04,
          )
        ],
      ),
    );
  }

  trackingData() {
    return Stack(
      children: [
        ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, idx) {
              return Column(
                children: [
                  widget.myReport && idx == 0
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            width: resize(54),
                            height: resize(26),
                            child: RaisedButton(
                              onPressed: () {
                                TrackerPage.push(context, DateTime.now())
                                    .then((value) {
                                  bloc.add(TrackerInitEvent(
                                      context: context,
                                      date: widget.date.isoYYYYMMDD));
                                });
                              },
                              highlightElevation: 0,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                              color: AppColors.transparent,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.grey)),
                                child: Center(
                                  child: Text(
                                    AppStrings.of(StringKey.edit),
                                    style: AppTextStyle.from(
                                        color: AppColors.grey,
                                        size: TextSize.caption_small,
                                        weight: TextWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(),
                  widget.myReport && idx == 0
                      ? emptySpaceH(height: 16)
                      : Container(),
                  trackingItem(items[idx], idx),
                  emptySpaceH(height: 22)
                ],
              );
            },
            shrinkWrap: true,
            itemCount: items.length)
      ],
    );
  }

  trackingItem(String item, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            itemIcon(item),
            width: resize(32),
            height: resize(32),
          ),
          emptySpaceW(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: resize(156),
                child: Row(
                  children: [
                    Text(
                      itemTitle(item),
                      style: AppTextStyle.from(
                          color: AppColors.grey,
                          size: TextSize.caption_small,
                          weight: TextWeight.bold),
                    ),
                    Expanded(child: Container()),
                    widget.myReport
                        ? Container()
                        : GestureDetector(
                            onTap: () {
                              trakingInfoDialog(
                                  context,
                                  bloc.trackingNames[index],
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
              emptySpaceH(height: 12),
              Container(
                child: itemData(item),
              )
            ],
          )
        ],
      ),
    );
  }

  itemIcon(String item) {
    switch (item) {
      case 'step':
        return AppImages.ic_steps;
      case 'upper':
        return AppImages.ic_upper_body;
      case 'lower':
        return AppImages.ic_lower_body;
      case 'whole':
        return AppImages.ic_whole_body;
      case 'social':
        return AppImages.ic_globe;
    }
  }

  itemTitle(String item) {
    switch (item) {
      case 'step':
        return '${AppStrings.of(StringKey.steps)} (Steps)';
      case 'upper':
        return '${AppStrings.of(StringKey.upper_body)} (Mins)';
      case 'lower':
        return '${AppStrings.of(StringKey.lower_body)} (Mins)';
      case 'whole':
        return '${AppStrings.of(StringKey.whole_body)} (Mins)';
      case 'social':
        return '${AppStrings.of(StringKey.social_activity)} (Mins)';
    }
  }

  itemData(String item) {
    if (bloc.trackingData != null) {
      switch (item) {
        case 'step':
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: resize(160),
                height: resize(30),
                padding:
                    EdgeInsets.only(left: resize(widget.myReport ? 0 : 16)),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    Platform.isIOS
                        ? bloc.step == null
                            ? 0.toString()
                            : bloc.step.toString()
                        : bloc.trackingData.step.toString(),
                    style: AppTextStyle.from(
                        color: Platform.isIOS
                            ? bloc.step == null
                                ? AppColors.grey
                                : AppColors.black
                            : bloc.trackingData == null
                                ? AppColors.grey
                                : AppColors.black,
                        size: TextSize.title_medium,
                        weight: TextWeight.extrabold),
                  ),
                ),
              ),
              emptySpaceW(width: 12),
              Padding(
                padding: EdgeInsets.only(top: resize(12)),
                child: Text(
                  "/ ${bloc.trackingData.goalInfo.goalStep} steps",
                  style: AppTextStyle.from(
                      size: TextSize.caption_medium,
                      weight: TextWeight.semibold,
                      color: Platform.isIOS
                          ? bloc.step == null
                              ? 0 >= bloc.trackingData.goalInfo.goalStep
                                  ? AppColors.green
                                  : AppColors.grey
                              : bloc.step >= bloc.trackingData.goalInfo.goalStep
                                  ? AppColors.green
                                  : AppColors.grey
                          : bloc.trackingData.step >=
                                  bloc.trackingData.goalInfo.goalStep
                              ? AppColors.green
                              : AppColors.grey),
                ),
              )
            ],
          );
        default:
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: resize(160),
                height: resize(48),
                child: TextFormField(
                    controller: controllerSetting(item),
                    cursorColor: AppColors.black,
                    maxLines: 1,
                    readOnly: widget.myReport,
                    style: AppTextStyle.from(
                        size: TextSize.title_medium,
                        color: AppColors.black,
                        weight: TextWeight.extrabold),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                        border: widget.myReport
                            ? InputBorder.none
                            : OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: resize(1),
                                    color: AppColors.lightGrey04)),
                        enabledBorder: widget.myReport
                            ? InputBorder.none
                            : OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: resize(1),
                                    color: AppColors.lightGrey04)),
                        focusedBorder: widget.myReport
                            ? InputBorder.none
                            : OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: resize(1), color: AppColors.purple)),
                        contentPadding: EdgeInsets.only(
                          left: resize(widget.myReport ? 0 : 16),
                          right: resize(8),
                        ))),
              ),
              emptySpaceW(width: 12),
              Padding(
                padding: EdgeInsets.only(top: resize(12)),
                child: Text(
                  goalSetting(item),
                  style: AppTextStyle.from(
                      size: TextSize.caption_medium,
                      weight: TextWeight.semibold,
                      color:
                          goalColor(item) ? AppColors.green : AppColors.grey),
                ),
              )
            ],
          );
      }
    } else {
      return Container();
    }
  }

  controllerSetting(String item) {
    switch (item) {
      case 'upper':
        return bloc.trackingControllers[0];
      case 'lower':
        return bloc.trackingControllers[1];
      case 'whole':
        return bloc.trackingControllers[2];
      case 'social':
        return bloc.trackingControllers[3];
    }
  }

  goalSetting(String item) {
    switch (item) {
      case 'upper':
        return '/ ${bloc.trackingData.goalInfo.goalUpper} Mins';
      case 'lower':
        return '/ ${bloc.trackingData.goalInfo.goalLower} Mins';
      case 'whole':
        return '/ ${bloc.trackingData.goalInfo.goalWhole} Mins';
      case 'social':
        return '/ ${bloc.trackingData.goalInfo.goalSocial} Mins';
    }
  }

  goalColor(String item) {
    switch (item) {
      case 'upper':
        return bloc.trackingData.upper >= bloc.trackingData.goalInfo.goalUpper;
      case 'lower':
        return bloc.trackingData.lower >= bloc.trackingData.goalInfo.goalLower;
      case 'whole':
        return bloc.trackingData.whole >= bloc.trackingData.goalInfo.goalWhole;
      case 'social':
        return bloc.trackingData.social >=
            bloc.trackingData.goalInfo.goalSocial;
    }
  }

  footer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              AppImages.ic_flag,
              width: resize(24),
              height: resize(24),
            ),
            emptySpaceW(width: 12),
            Text(
              AppStrings.of(StringKey.goal),
              style: AppTextStyle.from(
                  color: AppColors.darkGrey,
                  size: TextSize.caption_medium,
                  weight: TextWeight.extrabold),
            )
          ],
        ),
        emptySpaceH(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppImages.smail1,
              width: resize(16),
              height: resize(16),
            ),
            emptySpaceW(width: 8),
            Flexible(
              child: Text(
                bloc.trackingData != null
                    ? bloc
                        .trackingData.goalInfo.goalSettingScale.goalDescription
                    : "",
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_medium,
                    weight: TextWeight.semibold,
                    height: 1.4),
              ),
            )
          ],
        ),
        emptySpaceH(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AppImages.smail2,
              width: resize(16),
              height: resize(16),
            ),
            emptySpaceW(width: 8),
            Flexible(
              child: Text(
                bloc.trackingData != null
                    ? bloc
                        .trackingData.goalInfo.goalSettingScale2.goalDescription
                    : "",
                style: AppTextStyle.from(
                    color: AppColors.black,
                    size: TextSize.caption_medium,
                    weight: TextWeight.semibold,
                    height: 1.4),
              ),
            ),
          ],
        ),
        widget.myReport ? Container() : emptySpaceH(height: 32),
        widget.myReport
            ? Container()
            : BottomButton(
                onPressed: () {
                  Tracking tracking = Tracking(
                      upper: int.parse(bloc.trackingControllers[0].text),
                      lower: int.parse(bloc.trackingControllers[1].text),
                      whole: int.parse(bloc.trackingControllers[2].text),
                      social: int.parse(bloc.trackingControllers[3].text));
                  bloc.add(SaveTrackingDataEvent(
                      tracking: tracking, date: widget.date));
                },
                text: AppStrings.of(StringKey.save),
              ),
        emptySpaceH(height: 24)
      ],
    );
  }

  trackingChart() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.of(StringKey.last_30_days),
            style: AppTextStyle.from(
                color: AppColors.darkGrey,
                size: TextSize.caption_medium,
                weight: TextWeight.extrabold),
          ),
          emptySpaceH(height: 12),
          Container(
            width: MediaQuery.of(context).size.width,
            height: resize(0.8),
            color: AppColors.lightGrey04,
          ),
          emptySpaceH(height: 12),
          ListView.builder(
            itemBuilder: (context, idx) {
              return Column(
                children: [chartItem(items[idx], idx), emptySpaceH(height: 24)],
              );
            },
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: items.length,
          )
        ],
      ),
    );
  }

  chartItem(String item, int idx) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            children: [
              Image.asset(
                trackingImages[idx],
                width: resize(24),
                height: resize(24),
              ),
              emptySpaceW(width: 12),
              Text(
                itemTitle(item),
                style: AppTextStyle.from(
                    color: AppColors.darkGrey,
                    size: TextSize.caption_medium,
                    weight: TextWeight.bold),
              ),
              Expanded(child: Container()),
              Text(
                bloc.graphSumData[idx].toString(),
                style: AppTextStyle.from(
                    color: AppColors.black,
                    weight: TextWeight.bold,
                    size: TextSize.caption_medium),
              )
            ],
          ),
        ),
        emptySpaceH(height: 12),
        bloc.trackingData != null
            ? Container(
                width: MediaQuery.of(context).size.width,
                height: resize(80),
                child: LineChart(LineChartData(
                  lineTouchData: LineTouchData(
                      enabled: true,
                      touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppColors.orange,
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              final flSpot = barSpot;

                              return LineTooltipItem(
                                  "${flSpot.y.toStringAsFixed(0)} ${item == 'step' ? 'Steps' : 'Mins'}",
                                  AppTextStyle.from(
                                      size: TextSize.caption_very_small,
                                      color: AppColors.white,
                                      weight: TextWeight.bold));
                            }).toList();
                          })),
                  gridData: FlGridData(
                    show: true,
                    drawHorizontalLine: false,
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                          color: AppColors.lightGrey02, strokeWidth: 1);
                    },
                  ),
                  minX: 0,
                  maxX: bloc.trackingGraph.dates.length + 1.toDouble(),
                  minY: 0,
                  // maxY: graphMaxXSetting(item),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: linesBarData(item),
                )),
              )
            : Container()
      ],
    );
  }

  List<LineChartBarData> linesBarData(String item) {
    List<FlSpot> flSpots = List();
    for (int i = 0; i < bloc.trackingGraph.dates.length; i++) {
      if (item == "step") {
        flSpots.add(
            FlSpot(i + 1.toDouble(), bloc.trackingGraph.steps[i].toDouble()));
      } else if (item == "upper") {
        flSpots.add(
            FlSpot(i + 1.toDouble(), bloc.trackingGraph.uppers[i].toDouble()));
      } else if (item == "lower") {
        flSpots.add(
            FlSpot(i + 1.toDouble(), bloc.trackingGraph.lowers[i].toDouble()));
      } else if (item == "whole") {
        flSpots.add(
            FlSpot(i + 1.toDouble(), bloc.trackingGraph.wholes[i].toDouble()));
      } else if (item == "social") {
        flSpots.add(
            FlSpot(i + 1.toDouble(), bloc.trackingGraph.socials[i].toDouble()));
      }
    }

    return [
      LineChartBarData(
          spots: flSpots,
          isCurved: false,
          colors: [
            graphColor(item),
          ],
          isStepLineChart: false,
          isStrokeCapRound: false,
          dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  color: graphColor(item),
                  strokeWidth: 0,
                  radius: 3,
                  strokeColor: graphColor(item),
                );
              },
              checkToShowDot: (spot, barData) {
                return spot.x == flSpots.length;
              }),
          belowBarData: BarAreaData(
            show: true,
            colors: [graphColor(item), AppColors.white],
            gradientTo: Offset(0, 1.3),
          ))
    ];
  }

  graphColor(String item) {
    switch (item) {
      case 'step':
        return AppColors.missionReading;
      case 'upper':
        return AppColors.missionVideo;
      case 'lower':
        return AppColors.missionExerciseBasic;
      case 'whole':
        return AppColors.missionActivity;
      case 'social':
        return AppColors.missionDiary;
    }
  }

  graphMaxXSetting(String item) {
    switch (item) {
      case 'step':
        return bloc.trackingData.goalInfo.goalStep.toDouble();
      case 'upper':
        return bloc.trackingData.goalInfo.goalUpper.toDouble();
      case 'lower':
        return bloc.trackingData.goalInfo.goalLower.toDouble();
      case 'whole':
        return bloc.trackingData.goalInfo.goalWhole.toDouble();
      case 'social':
        return bloc.trackingData.goalInfo.goalSocial.toDouble();
    }
  }

  _buildProgress(BuildContext context) {
    if (!bloc.isLoading) return Container();

    return FullscreenDialog();
  }

  @override
  blocListener(BuildContext context, state) {
    if (state is SaveTrackingDataState) {
      Navigator.of(context).pop(true);
    }

    if (state is TrackerInitState) {
      setState(() {});
    }
  }

  @override
  TrackerBloc initBloc() {
    return TrackerBloc(context)
      ..add(TrackerInitEvent(
          date: widget.date.isoYYYYMMDD,
          context: context,
          myReport: widget.myReport,
          homeNavigationBloc: widget.bloc,
          trackerSaveData: widget.saveTrackerData));
  }
}
