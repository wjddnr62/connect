import 'dart:io';

import 'package:connect/data/tracking_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/sample.dart';
import 'package:connect/models/setting_list.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:connect/models/tracking.dart';
import 'package:connect/resources/app_images.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/widgets/base_widget.dart';

class TrackerSettingBloc extends BaseBloc {
  TrackerSettingBloc(BuildContext context) : super(BaseTrackerSettingState());

  bool isLoading = false;

  int pageNum = 0;
  int selectIndex;

  List<String> titles = [
    AppStrings.of(StringKey.lets_set_your_goal),
    AppStrings.of(StringKey.lets_set_a_more_specific_goal),
    AppStrings.of(StringKey.lets_set_your_activity_goal_to_improve_your_health)
  ];

  List<String> subTitles = [
    AppStrings.of(
        StringKey.what_is_your_health_goal_to_achieve_through_rehabit),
    "",
    AppStrings.of(StringKey.we_suggest_your_daily)
  ];

  List<dynamic> goalTexts = List();

  List<dynamic> specificGoalTexts = List();

  List<bool> selectGoal = List();
  String selectGoalText = "";

  List<bool> selectSpecificGoal = List();
  String selectSpecificGoalText = "";

  List<String> trackingImages = [
    AppImages.ic_steps,
    AppImages.ic_upper_body,
    AppImages.ic_lower_body,
    AppImages.ic_whole_body,
    AppImages.ic_globe
  ];

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
      List.generate(5, (index) => TextEditingController(text: "0"));

  setTrackingValue(int index, Sample sample) {
    switch (index) {
      case 0:
        return sample.goalStep.toString();
      case 1:
        return sample.goalUpper.toString();
      case 2:
        return sample.goalLower.toString();
      case 3:
        return sample.goalWhole.toString();
      case 4:
        return sample.goalSocial.toString();
    }
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is TrackerSettingInitEvent) {
      isLoading = true;
      yield LoadingState();

      if (event.reset) {
        pageNum = 2;
        trackingControllers[0].text = event.goalTracking.goalStep.toString();
        trackingControllers[1].text = event.goalTracking.goalUpper.toString();
        trackingControllers[2].text = event.goalTracking.goalLower.toString();
        trackingControllers[3].text = event.goalTracking.goalWhole.toString();
        trackingControllers[4].text = event.goalTracking.goalSocial.toString();
      } else {
        SettingList settingList =
            await TrackingRepository.trackerGetSettingList();
        goalTexts = settingList.settingScaleInfo;
        specificGoalTexts = settingList.settingScaleDetailInfo;

        for (int i = 0; i < goalTexts.length; i++) {
          selectGoal.add(false);
        }
        for (int i = 0; i < specificGoalTexts.length; i++) {
          selectSpecificGoal.add(false);
        }
      }
      isLoading = false;
      yield TrackerSettingInitState();
    }

    if (event is PageNumChangeEvent) {
      pageNum = event.pageNum;
      if (pageNum == 2) {
        isLoading = true;
        yield LoadingState();

        Sample sample = await TrackingRepository.trackerGetSample(
            selectGoal.indexOf(true), selectSpecificGoal.indexOf(true));

        for (int i = 0; i < trackingControllers.length; i++) {
          trackingControllers[i].text = setTrackingValue(i, sample);
        }
        isLoading = false;
        yield LoadingState();
      }
      yield PageNumChangeState();
    }

    if (event is SelectGoalEvent) {
      selectGoal = List();
      for (int i = 0; i < goalTexts.length; i++) {
        selectGoal.add(false);
      }
      selectGoalText = goalTexts[event.selectIndex];
      selectGoal[event.selectIndex] = true;
      yield SelectGoalState();
    }

    if (event is SelectSpecificGoalEvent) {
      selectSpecificGoal = List();
      for (int i = 0; i < specificGoalTexts.length; i++) {
        selectSpecificGoal.add(false);
      }
      if (event.selectIndex != specificGoalTexts.length - 1) {
        selectSpecificGoalText = specificGoalTexts[event.selectIndex];
      }
      selectSpecificGoal[event.selectIndex] = true;
      yield SelectSpecificGoalState();
    }

    if (event is FinishSettingEvent) {
      isLoading = true;
      yield LoadingState();

      var res = await TrackingRepository.trackerPostGoal(event.trackerGoal);

      if (res is ServiceError) {
        isLoading = false;
        yield FinishSettingErrorState();
        return;
      }

      if (Platform.isAndroid) {
        startForegroundService();
      }
      isLoading = false;
      yield FinishSettingState();
    }

    if (event is LoadingEvent) {
      yield LoadingState();
    }

    if (event is FinishReSettingEvent) {
      isLoading = true;
      yield LoadingState();

      var res =
          await TrackingRepository.trackerPutGoal(event.goalTracking, event.id);

      if (res is ServiceError) {
        isLoading = false;
        yield FinishSettingErrorState();
        return;
      }

      isLoading = false;
      yield FinishReSettingState();
    }
  }
}

class FinishReSettingEvent extends BaseBlocEvent {
  final GoalTracking goalTracking;
  final String id;

  FinishReSettingEvent({this.goalTracking, this.id});
}

class FinishReSettingState extends BaseBlocState {}

class FinishSettingEvent extends BaseBlocEvent {
  final TrackerGoal trackerGoal;

  FinishSettingEvent({this.trackerGoal});
}

class FinishSettingState extends BaseBlocState {}

class FinishSettingErrorState extends BaseBlocState {}

class SelectSpecificGoalEvent extends BaseBlocEvent {
  final int selectIndex;

  SelectSpecificGoalEvent({this.selectIndex});
}

class SelectSpecificGoalState extends BaseBlocState {}

class SelectGoalEvent extends BaseBlocEvent {
  final int selectIndex;

  SelectGoalEvent({this.selectIndex});
}

class SelectGoalState extends BaseBlocState {}

class PageNumChangeEvent extends BaseBlocEvent {
  final int pageNum;

  PageNumChangeEvent({this.pageNum});
}

class PageNumChangeState extends BaseBlocState {}

class LoadingEvent extends BaseBlocEvent {}

class LoadingState extends BaseBlocState {}

class TrackerSettingInitEvent extends BaseBlocEvent {
  final bool reset;
  final GoalTracking goalTracking;

  TrackerSettingInitEvent({this.reset, this.goalTracking});
}

class TrackerSettingInitState extends BaseBlocState {}

class BaseTrackerSettingState extends BaseBlocState {}
