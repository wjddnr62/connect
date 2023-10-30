import 'dart:io';

import 'package:connect/data/diary_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/myreport_repository.dart';
import 'package:connect/data/push_repository.dart';
import 'package:connect/data/tracking_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/current_status.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/utils/extensions.dart';

class MyReportBloc extends BaseBloc {
  MyReportBloc(BuildContext context) : super(BaseMyReportState());

  Profile profile;
  bool isLoading = false;
  bool unreadPushExist = false;

  int tapIndex = 0;

  CurrentStatus currentStatus;
  String advice = "";
  List<EvaluationGraph> evaluationGraph = List();
  List<Diary> diaryData = List();

  String userType = "";

  List<bool> viewOptions = List();
  List<bool> maxLines = List();
  List<bool> exceeded = List();

  bool diaryExist = false;

  TrackerGoal trackerGoal;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is MyReportInitEvent) {
      isLoading = true;
      yield LoadingState();

      trackerGoal =
          await TrackingRepository.trackerGetGoal(DateTime.now().yyyymm);

      if (Platform.isAndroid && trackerGoal.userId != null) {
        await requestActivityRecognition();
      }

      profile = await UserRepository.getProfile();
      userType = await AppDao.marketPlace;

      var getCurrentStatus =
          await MyReportRepository.myReportGetCurrentStatus();

      if (getCurrentStatus is ServiceError) {
        isLoading = false;
        yield LoadingState();
        return;
      }

      evaluationGraph = profile.evaluationGraph;

      currentStatus = CurrentStatus.fromJson(getCurrentStatus);

      advice = await MyReportRepository.myReportGetAdvice();

      bool unread = (await PushRepository.unreadCheck()) != 0;
      if (unread != this.unreadPushExist) {
        unreadPushExist = unread;
        yield NotifyRefreshState();
      }

      isLoading = false;
      yield LoadingState();
    }

    if (event is TapSelectEvent) {
      tapIndex = event.index;
      if (tapIndex == 0) {
        add(MyReportInitEvent());
      } else if (tapIndex == 2) {
        add(DiaryInitEvent());
      }
      yield TapSelectState();
    }

    if (event is DiaryInitEvent) {
      isLoading = true;
      yield LoadingState();

      diaryExist = await DiaryRepository.diaryUserWriteCheckService(
          DateTime.now().toIso8601String().substring(0, 10));

      diaryData = List();
      viewOptions = List();
      maxLines = List();

      diaryData = await DiaryRepository.diaryGetUserAllData();
      for (int i = 0; i < diaryData.length; i++) {
        viewOptions.add(false);
        maxLines.add(true);
      }

      yield DiaryInitState();

      isLoading = false;
      yield LoadingState();
    }
  }
}

class DiaryInitEvent extends BaseBlocEvent {}

class DiaryInitState extends BaseBlocState {}

class TapSelectEvent extends BaseBlocEvent {
  final int index;

  TapSelectEvent({this.index});
}

class TapSelectState extends BaseBlocState {}

class NotifyRefreshState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class MyReportInitEvent extends BaseBlocEvent {}

class MyReportInitState extends BaseBlocState {}

class BaseMyReportState extends BaseBlocState {}
