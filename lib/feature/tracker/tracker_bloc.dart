import 'dart:io';

import 'package:connect/data/tracking_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/bottom_navigation/home_navigation_bloc.dart';
import 'package:connect/models/trackerChecks.dart';
import 'package:connect/models/tracking.dart';
import 'package:connect/models/tracking_data.dart';
import 'package:connect/models/tracking_graph.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/empty_space.dart';
import 'package:connect/utils/extensions.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:connect/utils/extensions.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

class TrackerBloc extends BaseBloc {
  TrackerBloc(BuildContext context) : super(BaseTrackerState());

  int step;
  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;
  bool isLoading = false;
  TrackingData trackingData;
  HomeNavigationBloc homeNavigationBloc;
  bool trackerSaveData = false;
  SharedPreferences sharedPreferences;

  List<String> trackingNames = [
    AppStrings.of(StringKey.steps) + " (Steps)",
    AppStrings.of(StringKey.upper_body) + " (Mins)",
    AppStrings.of(StringKey.lower_body) + " (Mins)",
    AppStrings.of(StringKey.whole_body) + " (Mins)",
    AppStrings.of(StringKey.social_activity) + " (Mins)"
  ];

  List<String> trackingDescriptions = [
    AppStrings.of(StringKey.total_daily_steps),
    AppStrings.of(StringKey.total_amount_of_upper_body_exercise),
    AppStrings.of(StringKey.total_amount_of_lower_body_exercise),
    AppStrings.of(StringKey.total_amount_of_whole_body_exercise),
    AppStrings.of(StringKey.total_amount_of_social_activities)
  ];

  List<TextEditingController> trackingControllers =
      List.generate(4, (index) => TextEditingController());

  TrackingGraph trackingGraph;

  List<int> graphSumData = [0, 0, 0, 0, 0];

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is TrackerInitEvent) {
      isLoading = true;
      yield LoadingState();
      sharedPreferences = await SharedPreferences.getInstance();
      homeNavigationBloc = event.homeNavigationBloc;
      trackerSaveData = event.trackerSaveData;

      if (Platform.isIOS && (event.myReport == null || !event.myReport)) {
        await healthKeySetting(event.context, event.date, event.myReport);
      }

      trackingData = await TrackingRepository.trackerGetTracking(event.date);
      trackingControllers[0].text = trackingData.upper.toString();
      trackingControllers[1].text = trackingData.lower.toString();
      trackingControllers[2].text = trackingData.whole.toString();
      trackingControllers[3].text = trackingData.social.toString();

      trackingGraph = await TrackingRepository.trackerGetGraph(event.date);

      graphSumData = [0, 0, 0, 0, 0];

      for (int i = 0; i < trackingGraph.dates.length; i++) {
        graphSumData[0] += trackingGraph.steps[i];
        graphSumData[1] += trackingGraph.uppers[i];
        graphSumData[2] += trackingGraph.lowers[i];
        graphSumData[3] += trackingGraph.wholes[i];
        graphSumData[4] += trackingGraph.socials[i];
      }

      // if (Platform.isIOS && graphSumData[0] == 0) {
      //   graphSumData[0] = step ?? 0;
      // }

      isLoading = false;
      yield TrackerInitState();
    }

    if (event is SaveTrackingDataEvent) {
      isLoading = true;
      yield LoadingState();

      await TrackingRepository.trackerPut(
          event.tracking, event.date.isoYYYYMMDD);

      if (trackerSaveData) {
        homeNavigationBloc.trackerChecks.add(TrackerChecks(
            date: event.date.isoYYYYMMDD,
            check: true,
            trackingData: await TrackingRepository.trackerGetTracking(
                event.date.isoYYYYMMDD)));
      }

      isLoading = false;
      yield SaveTrackingDataState();
    }
  }

  healthKeySetting(context, date, myReport) async {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    HealthFactory health = HealthFactory();

    List<HealthDataType> types = [HealthDataType.STEPS];

    _state = AppState.FETCHING_DATA;

    bool accessWasGranted = await health.requestAuthorization(types);

    step = 0;

    if (accessWasGranted) {
      try {
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(startDate, endDate, types);

        _healthDataList.addAll(healthData);
      } catch (e) {
        print("Caught exception in getHealthDataFromTypes: $e");
      }

      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      _healthDataList.forEach((element) {
        step += element.value.round();
      });

      _state = _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      if (_state == AppState.DATA_READY) {
        await TrackingRepository.trackerGetTracking(date);
        if (date == DateTime.now().isoYYYYMMDD) {
          await TrackingRepository.trackerPut(Tracking(step: step), date)
              .then((value) async {
            trackingData = await TrackingRepository.trackerGetTracking(date);
            trackingControllers[0].text = trackingData.upper.toString();
            trackingControllers[1].text = trackingData.lower.toString();
            trackingControllers[2].text = trackingData.whole.toString();
            trackingControllers[3].text = trackingData.social.toString();

            trackingGraph = await TrackingRepository.trackerGetGraph(date);

            graphSumData = [0, 0, 0, 0, 0];

            for (int i = 0; i < trackingGraph.dates.length; i++) {
              graphSumData[0] += trackingGraph.steps[i];
              graphSumData[1] += trackingGraph.uppers[i];
              graphSumData[2] += trackingGraph.lowers[i];
              graphSumData[3] += trackingGraph.wholes[i];
              graphSumData[4] += trackingGraph.socials[i];
            }
          });
        }
      }

      if (_state == AppState.NO_DATA &&
          sharedPreferences.getString("healthDate") !=
              DateTime.now().isoYYYYMMDD) {
        await sharedPreferences.setString(
            "healthDate", DateTime.now().isoYYYYMMDD);
        healthDialog(context, myReport);
      }
    } else {
      print("Authorization not granted");
      _state = AppState.DATA_NOT_FETCHED;
    }
  }
}

class SaveTrackingDataEvent extends BaseBlocEvent {
  final Tracking tracking;
  final DateTime date;

  SaveTrackingDataEvent({this.tracking, this.date});
}

class SaveTrackingDataState extends BaseBlocState {}

class LoadingEvent extends BaseBlocEvent {}

class LoadingState extends BaseBlocState {}

class TrackerInitEvent extends BaseBlocEvent {
  final String date;
  final BuildContext context;
  final bool myReport;
  final HomeNavigationBloc homeNavigationBloc;
  final bool trackerSaveData;

  TrackerInitEvent(
      {this.date,
      this.context,
      this.myReport,
      this.homeNavigationBloc,
      this.trackerSaveData});
}

class TrackerInitState extends BaseBlocState {}

class BaseTrackerState extends BaseBlocState {}

healthDialog(BuildContext context, bool myReport) {
  showDialog(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(resize(24)),
                  topRight: Radius.circular(resize(24)),
                  bottomLeft: Radius.circular(resize(24)),
                  bottomRight: Radius.circular(resize(24))),
            ),
            backgroundColor: AppColors.white,
            child: Container(
              width: resize(312),
              height: resize(270),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  emptySpaceH(height: 28),
                  Container(
                    height: resize(26),
                    child: Text(
                      AppStrings.of(StringKey.allow_to_read_data),
                      style: AppTextStyle.from(
                          color: AppColors.black,
                          weight: TextWeight.extrabold,
                          size: TextSize.title_small),
                    ),
                  ),
                  emptySpaceH(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding:
                          EdgeInsets.only(left: resize(20), right: resize(20)),
                      height: resize(102),
                      child: Text(
                        AppStrings.of(StringKey.ios_health_app_setting),
                        style: AppTextStyle.from(
                            color: AppColors.black,
                            size: TextSize.caption_large,
                            weight: TextWeight.medium,
                            height: 1.6),
                      ),
                    ),
                  ),
                  emptySpaceH(height: 24),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: resize(1),
                    color: AppColors.lightGrey04,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: resize(73),
                          child: ElevatedButton(
                            onPressed: () {
                              if (myReport) {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              } else {
                                Navigator.of(context, rootNavigator: true)
                                    .pop();
                              }
                            },
                            child: Center(
                              child: Text(
                                AppStrings.of(StringKey.cancel),
                                style: AppTextStyle.from(
                                    size: TextSize.caption_large,
                                    weight: TextWeight.semibold,
                                    color: AppColors.darkGrey),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(24)),
                                ),
                                elevation: 0),
                          ),
                        ),
                      ),
                      Container(
                        width: resize(1),
                        height: resize(73),
                        color: AppColors.lightGrey04,
                      ),
                      Expanded(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: resize(73),
                          child: ElevatedButton(
                            onPressed: () async {
                              await launch("x-apple-health://").then((value) {
                                if (myReport) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                } else {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  Navigator.of(context).pop();
                                }
                              });
                            },
                            child: Center(
                              child: Text(
                                AppStrings.of(StringKey.run_the_app),
                                style: AppTextStyle.from(
                                    size: TextSize.caption_large,
                                    weight: TextWeight.semibold,
                                    color: AppColors.purple),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                primary: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(24)),
                                ),
                                elevation: 0),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      });
}
