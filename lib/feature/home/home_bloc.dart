import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connect/data/evaluation_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/mission_repository.dart';
import 'package:connect/data/push_repository.dart';
import 'package:connect/data/tracking_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/home/MissionProvider.dart';
import 'package:connect/feature/notification/notification_bloc.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/mission_historys.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/models/trackerChecks.dart';
import 'package:connect/models/tracker_goal.dart';
import 'package:connect/models/tracking_data.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/utils/extensions.dart';
import 'package:connect/utils/foreground_service.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_calendar.dart';

class HomeBloc extends BaseBloc {
  final MissionProvider _missionProvider;
  PageController calendarPageController = PageController();
  PageController missionPageController = PageController();

  String get title =>
      DateFormat.formatIntl('MMM, yyyy', _missionProvider.selectedDate);

  int get dateCount => _missionProvider.dateCount;

  int get calendarPageCount => (dateCount / 7).floor();

  bool get isLoading => _missionProvider.loading;
  bool isLoadingView = false;
  bool unreadPushExist = false;

  bool get completedEvaluation => _missionProvider.completedEvaluation;

  String get completedTitle => _missionProvider.completedTitle;

  String get completedDescription => _missionProvider.completedDescription;

  bool validEvaluation = true;

  String validTitle = "";

  String validDescription = "";

  List<dynamic> performList = List();

  int missionRemain;

  int currentIndex;

  bool completed = false;

  bool open = false;

  bool evaluationOpen = false;

  String userType = "";

  bool getDiaryCheck = false;
  bool diaryCheck = false;
  bool trackerCheck = false;

  bool evaluationPayment = false;

  int serviceDate = 0;
  DateTime startTime;

  List<bool> get diaryCheckList => _missionProvider.diaryCheckList;

  int checkTime = 0;

  Timer timer;

  bool scrollCheck = false;

  bool loadData = false;
  Mission firstMission;
  int pageIndex;
  bool gestureUpDown = false;
  bool tutorialGesture = false;

  List<MissionRenewal> missions = List();
  List<DiaryChecks> diaryChecks = List();
  List<String> diaryRemove = List();
  List<TrackerChecks> trackerChecks = List();

  Profile profile;

  bool saveLogCheck = false;

  DateTime selectMonth;
  TrackingData trackingData;
  PermissionStatus status;
  bool permissionCheck = false;
  SharedPreferences sharedPreferences;

  List<PerformHistory> calendarProgress = List();

  HomeBloc(BuildContext context)
      : _missionProvider = MissionProvider.of(context),
        super(BaseHomeCalendarState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield CheckState();
    if (event is CalendarInitEvent) {
      isLoadingView = true;
      yield LoadingState();
      sharedPreferences = await SharedPreferences.getInstance();

      status = await Permission.activityRecognition.status;
      permissionCheck = status.isGranted;

      selectMonth = _missionProvider.selectedDate;

      profile = await UserRepository.getProfile();
      serviceDate = profile.subscription.daysLeft;
      startTime = profile.createdDate;

      tutorialGesture = await AppDao.tutorialGesture;

      checkEvaluation();

      var valid = await EvaluationRepository.isValidEvaluation();

      if (valid is ServiceError) {
        yield CheckState();
        isLoadingView = false;
        yield LoadingState();
        return;
      }

      if (valid != null) {
        validEvaluation = valid.isValid;
        validTitle = valid.title;
        validDescription = valid.description;
      }

      userType = await AppDao.marketPlace;

      var res = await _missionProvider.needToUpdateSeverity();

      if (res != null) {
        if (res is ServiceError) {
          yield CheckState();
          isLoadingView = false;
          yield LoadingState();
          return;
        }
      }

      missionPageController.jumpToPage(max(0, dateCount - 1));
      calendarPageController.jumpToPage(max(0, calendarPageCount - 1));

      diaryRemove = event.diaryRemove;

      if (event.missions == null || event.missions.isEmpty) {
        var missionRes =
            await MissionRepository.getMissions(date: DateTime.now());

        if (missionRes is ServiceError) {
          yield CheckState();
          isLoadingView = false;
          yield LoadingState();
          return;
        } else {
          if (missionRes != null) {
            missions.add(missionRes);
            if (missionRes is MissionRenewal) {
              diaryChecks.add(DiaryChecks(
                  date: missionRes.date,
                  check: await _missionProvider.diaryCheck(
                      date: missionRes.date)));
              trackingData =
                  await TrackingRepository.trackerGetTracking(missionRes.date);
              if (trackingData.id != null) {
                trackerChecks.add(TrackerChecks(
                    date: missionRes.date,
                    trackingData: trackingData,
                    check: trackingData.isSave));
              }
            }
          }
          yield CheckState();
          isLoadingView = false;
          yield LoadingState();
        }
      } else {
        missions = event.missions;
        diaryChecks = event.diaryChecks;
        trackerChecks = event.trackerChecks ?? List();
        yield CheckState();
        isLoadingView = false;
        yield LoadingState();
      }

      if (diaryChecks != null && diaryChecks.length != 0) {
        add(RefreshIndicatorCallEvent(selectDate: DateTime.now()));
      }
      yield CheckState();
      isLoadingView = false;
      yield CalendarInitializedState();
    }

    if (event is MissionPageChangeEvent) {
      if (event.pageIndex != null) {
        if (diaryCheck) {
          diaryCheck = false;
        }
        if (trackerCheck) {
          trackerCheck = false;
        }
        int page = event.pageIndex ~/ 7;
        calendarPageController.jumpToPage(page);
        yield DiaryCheck();
        _missionProvider
            .missionDateChanged(_missionProvider.dates[event.pageIndex]);

        DateTime date = _missionProvider.dates[event.pageIndex];

        bool getMission = false;

        for (int i = 0; i < missions.length; i++) {
          if (missions[i].date == date.isoYYYYMMDD) {
            getMission = false;
            break;
          } else {
            getMission = true;
          }
        }

        if (missions.length == 0) {
          getMission = true;
        }

        if (date.isAfter(DateTime.now())) {
          getMission = false;
        }

        if (date.add(Duration(days: 1)).isBefore(profile.createdDate)) {
          getMission = false;
        }

        if (getMission) {
          yield CheckState();
          isLoadingView = true;
          yield LoadingState();

          var missionRes = await MissionRepository.getMissions(date: date);

          if (missionRes is ServiceError) {
            yield CheckState();
            isLoadingView = false;
            yield LoadingState();
            return;
          } else {
            if (missionRes != null) {
              missions.add(missionRes);
              bool checks =
                  await _missionProvider.diaryCheck(date: missionRes.date);
              if (missionRes is MissionRenewal) {
                diaryChecks
                    .add(DiaryChecks(date: missionRes.date, check: checks));
                trackingData = await TrackingRepository.trackerGetTracking(
                    missionRes.date);
                if (trackingData.id != null) {
                  trackerChecks.add(TrackerChecks(
                      date: missionRes.date,
                      trackingData: trackingData,
                      check: trackingData.isSave));
                  trackerCheck = trackingData.isSave;
                }
                if (Platform.isAndroid &&
                    trackerChecks != null &&
                    trackerChecks.length != 0 &&
                    trackerChecks.indexWhere(
                            (element) => element.trackingData.userId != null) !=
                        -1) {
                  await requestActivityRecognition();
                }
              }

              getDiaryCheck = false;
              if (!getDiaryCheck) {
                diaryCheck = checks;
              }
              getDiaryCheck = true;
            }
            yield CheckState();
            isLoadingView = false;
            yield LoadingState();
          }
        } else {
          DateTime date = _missionProvider.dates[event.pageIndex];
          if (!date.isAfter(DateTime.now()) &&
              !date.add(Duration(days: 1)).isBefore(profile.createdDate)) {
            yield CheckState();
            isLoadingView = true;
            yield LoadingState();
            bool checks = false;
            if (diaryChecks.isNotEmpty && diaryChecks.length != 0) {
              checks = diaryChecks[diaryChecks.indexWhere(
                      (element) => element.date == date.isoYYYYMMDD)]
                  .check;
            }

            if (trackerChecks.isNotEmpty && trackerChecks.length != 0) {
              trackerCheck = trackerChecks[trackerChecks.indexWhere(
                      (element) => element.date == date.isoYYYYMMDD)]
                  .check;
            }

            getDiaryCheck = false;
            if (!getDiaryCheck) {
              diaryCheck = checks;
            }
            getDiaryCheck = true;

            yield CheckState();
            isLoadingView = false;
            yield LoadingState();
          }
        }

        if (diaryRemove.length != 0) {
          if (diaryRemove.contains(date.isoYYYYMMDD)) {
            isLoadingView = true;
            yield LoadingState();
            if (diaryChecks.indexWhere((element) =>
                    element.date ==
                    diaryRemove[diaryRemove.indexWhere(
                        (element) => element == date.isoYYYYMMDD)]) !=
                -1) {
              diaryChecks.removeAt(diaryChecks.indexWhere((element) =>
                  element.date ==
                  diaryRemove[diaryRemove
                      .indexWhere((element) => element == date.isoYYYYMMDD)]));
              bool checks = await _missionProvider.diaryCheck(
                  date: diaryRemove[diaryRemove
                      .indexWhere((element) => element == date.isoYYYYMMDD)]);
              diaryChecks.add(DiaryChecks(
                  date: diaryRemove[diaryRemove
                      .indexWhere((element) => element == date.isoYYYYMMDD)],
                  check: checks));
              diaryRemove.removeAt(diaryRemove
                  .indexWhere((element) => element == date.isoYYYYMMDD));
              getDiaryCheck = false;
              if (!getDiaryCheck) {
                diaryCheck = checks;
              }
              getDiaryCheck = true;
            }
            yield CheckState();
            isLoadingView = false;
            yield LoadingState();
          }
        }
      }
    }

    if (event is CalendarWeekChangeEvent) {
      missionPageController
          .jumpToPage(_missionProvider.getValidMissionIndex(event.pageIndex));

      int calendarPageIndex = calendarPageController.page.toInt() * 7;
      DateTime startDate = _missionProvider.dates[calendarPageIndex];
      DateTime endDate = startDate.add(Duration(days: 6));
      if (endDate.isAfter(DateTime.now())) {
        endDate = DateTime.now();
      }

      if (!endDate.isAfter(DateTime.now()) &&
          !startDate.add(Duration(days: 1)).isBefore(profile.createdDate)) {
        if (calendarProgress.isEmpty || calendarProgress.length == 0) {
          yield CheckState();
          isLoadingView = true;
          yield LoadingState();
          List<PerformHistory> progress =
              await MissionRepository.getPerformPeriod(
                  startDate: startDate.isoYYYYMMDD,
                  endDate: endDate.isoYYYYMMDD);
          calendarProgress.addAll(progress);
        } else if (calendarProgress.indexWhere(
                    (element) => element.date == startDate.isoYYYYMMDD) ==
                -1 &&
            calendarProgress.indexWhere(
                    (element) => element.date == endDate.isoYYYYMMDD) ==
                -1) {
          yield CheckState();
          isLoadingView = true;
          yield LoadingState();
          List<PerformHistory> progress =
              await MissionRepository.getPerformPeriod(
                  startDate: startDate.isoYYYYMMDD,
                  endDate: endDate.isoYYYYMMDD);

          for (int i = 0; i < progress.length; i++) {
            if (calendarProgress.indexWhere(
                    (element) => element.date == progress[i].date) ==
                -1) {
              calendarProgress.add(progress[i]);
            }
          }
        }

        yield CheckState();
        isLoadingView = false;
        yield LoadingState();
      }

      yield CheckState();
      yield LoadingState();
    }

    if (event is CalendarDatePressEvent) {
      missionPageController.jumpToPage(event.dateIndex);
      add(MissionPageChangeEvent(event.dateIndex));
    }

    if (event is ArrivedFromNotificationList &&
        event.arg is NotificationPageResult) {
      // if (!event.arg.isReadBeforeClick) {
      //   _missionProvider.clear();
      //   await _missionProvider.getWeeklyData(
      //       update: true, date: _missionProvider.endDate);
      // }
      DateTime now = DateTime.now();

      missionPageController.jumpToPage(_missionProvider.dates
          .indexOf(DateTime(now.year, now.month, now.day)));
    }

    if (event is NotifyCheck) {
      bool unread = (await PushRepository.unreadCheck()) != 0;
      if (unread != this.unreadPushExist) {
        unreadPushExist = unread;
        yield NotifyRefreshState();
      }
    }

    if (event is RefreshIndicatorCallEvent) {
      isLoadingView = true;
      yield LoadingState();

      var missionRes =
          await MissionRepository.getMissions(date: event.selectDate);

      if (missionRes is ServiceError) {
        isLoadingView = false;
        yield LoadingState();
        return;
      } else {
        if (missions.length != 0) {
          if (missions
                  .indexWhere((e) => e.date == event.selectDate.isoYYYYMMDD) !=
              -1)
            missions.removeAt(missions
                .indexWhere((e) => e.date == event.selectDate.isoYYYYMMDD));
        }

        if (diaryChecks.length != 0) {
          if (diaryChecks.indexWhere(
                  (element) => element.date == event.selectDate.isoYYYYMMDD) !=
              -1)
            diaryChecks.removeAt(diaryChecks.indexWhere(
                (element) => element.date == event.selectDate.isoYYYYMMDD));
        }

        if (trackerChecks.length != 0) {
          if (trackerChecks.indexWhere(
                  (element) => element.date == event.selectDate.isoYYYYMMDD) !=
              -1)
            trackerChecks.removeAt(trackerChecks.indexWhere(
                (element) => element.date == event.selectDate.isoYYYYMMDD));
        }

        // if (calendarProgress.length != 0) {
        //   if (calendarProgress.indexWhere(
        //           (element) => element.date == event.selectDate.isoYYYYMMDD) !=
        //       -1) {
        //     calendarProgress.removeAt(calendarProgress.indexWhere(
        //         (element) => element.date == event.selectDate.isoYYYYMMDD));
        //   }
        // }

        if (missionRes != null) {
          missions.add(missionRes);
          trackingData =
              await TrackingRepository.trackerGetTracking(missionRes.date);
          bool checks =
              await _missionProvider.diaryCheck(date: missionRes.date);
          if (missionRes is MissionRenewal) {
            diaryChecks.add(DiaryChecks(date: missionRes.date, check: checks));
            if (trackingData.id != null) {
              trackerChecks.add(TrackerChecks(
                  date: missionRes.date,
                  trackingData: trackingData,
                  check: trackingData.isSave));
              trackerCheck = trackingData.isSave;
            }
            List<PerformHistory> progress =
                await MissionRepository.getPerformPeriod(
                    startDate: missionRes.date, endDate: missionRes.date);

            calendarProgress.replaceRange(
                calendarProgress
                    .indexWhere((element) => element.date == missionRes.date),
                calendarProgress
                    .indexWhere((element) => element.date == missionRes.date),
                progress);
          }
          if (!getDiaryCheck) {
            diaryCheck = checks;
          }
          getDiaryCheck = true;
        }

        isLoadingView = false;
        yield LoadingState();
      }
      yield DiaryCheck();
    }

    if (event is GestureChangeEvent) {
      gestureUpDown = !gestureUpDown;
      yield GestureChangeState();
    }

    if (event is LoadingEvent) {
      yield LoadingState();
    }
  }

  checkEvaluation() async {
    String checkEvaluation = await AppDao.evaluationPayment;
    List<String> splitCheck = checkEvaluation.split("*");
    if (splitCheck.length == 3) {
      if (splitCheck[0] + "*" + splitCheck[1] == await AppDao.email) {
        if (splitCheck[2] == "true") {
          evaluationPayment = true;
        }
      } else {
        evaluationPayment = false;
      }
    } else {
      if (checkEvaluation.split("*")[0] == await AppDao.email) {
        if (checkEvaluation.split("*")[1] == "true") {
          evaluationPayment = true;
        }
      } else {
        evaluationPayment = false;
      }
    }
  }

  getPerformHistoryByPageIndex(
      int pageIndex, int dailyMission, BuildContext context) async {
    int userId = await AppDao.userId;

    performList = await MissionRepository.getPerformHistory(
        date: _missionProvider.dates[pageIndex], userId: userId);
    if (performList.isNotEmpty && performList != null) {
      missionRemain = dailyMission - performList[0]['completed_count'];
      Timer(Duration(milliseconds: 500), () {
        _onAllCompleted(context);
      });
    }
  }

  _onAllCompleted(context) {
    if (missionRemain != null &&
        (missionRemain == 0 && completed) &&
        diaryCheck &&
        trackerCheck) {
      completeDialog(context);
      completed = false;
    }
  }

  getMission(DateTime date) {
    if (missions.isEmpty || missions.length == 0) {
      return null;
    }

    if (missions
        .where((e) => (e == null ? "" : e.date) == date.isoYYYYMMDD)
        .isEmpty) {
      return null;
    }

    return missions
        .where((e) => (e == null ? "" : e.date) == date.isoYYYYMMDD)
        .first
        .missions;
  }

  MissionRenewal getMissionByPageIndex(int pageIndex) {
    MissionRenewal missionRenewal;
    for (int i = 0; i < missions.length; i++) {
      if (missions[i].date ==
          _missionProvider.dates[pageIndex]
              .toIso8601String()
              .substring(0, 10)) {
        missionRenewal = missions[i];
        break;
      }
    }

    if (missionRenewal == null) {
      return null;
    }

    return missionRenewal;
  }

  bool getDiaryCheckCalendar(int pageIndex) {
    bool diaryChecksItem;
    for (int i = 0; i < diaryChecks.length; i++) {
      if (diaryChecks[i].date ==
          _missionProvider.dates[pageIndex]
              .toIso8601String()
              .substring(0, 10)) {
        diaryChecksItem = diaryChecks[i].check;
        break;
      }
    }

    if (diaryChecksItem == null) {
      return false;
    }

    return diaryChecksItem;
  }

  bool getTrackerCheckCalendar(int pageIndex) {
    bool trackerChecksItem;
    if (trackerChecks != null) {
      for (int i = 0; i < trackerChecks.length; i++) {
        if (trackerChecks[i].date ==
            _missionProvider.dates[pageIndex].isoYYYYMMDD) {
          trackerChecksItem = trackerChecks[i].check;
          break;
        }
      }
    }

    if (trackerChecksItem == null) {
      return false;
    }

    return trackerChecksItem;
  }

  bool getTrackerCheckData(int pageIndex) {
    bool trackerChecksItem = false;
    if (trackerChecks != null) {
      for (int i = 0; i < trackerChecks.length; i++) {
        if (trackerChecks[i].date ==
            _missionProvider.dates[pageIndex].isoYYYYMMDD) {
          trackerChecksItem = true;
          break;
        }
      }
    }

    if (trackerChecksItem == null) {
      return false;
    }

    return trackerChecksItem;
  }

  DateTime getDate(int dateIndex) => _missionProvider.dates[dateIndex];

  bool isSameSelectedDay(int dateIndex) =>
      _missionProvider.isSameSelectedDay(_missionProvider.dates[dateIndex]);
}

class CalendarInitEvent extends BaseBlocEvent {
  final List<MissionRenewal> missions;
  final List<DiaryChecks> diaryChecks;
  final List<String> diaryRemove;
  final List<TrackerChecks> trackerChecks;

  CalendarInitEvent(
      {this.missions, this.diaryChecks, this.diaryRemove, this.trackerChecks});
}

class MissionPageChangeEvent extends BaseBlocEvent {
  final int pageIndex;

  MissionPageChangeEvent(this.pageIndex);
}

class CalendarWeekChangeEvent extends BaseBlocEvent {
  final int pageIndex;

  CalendarWeekChangeEvent(this.pageIndex);
}

class CalendarDatePressEvent extends BaseBlocEvent {
  final int dateIndex;

  CalendarDatePressEvent(this.dateIndex);
}

class RefreshIndicatorCallEvent extends BaseBlocEvent {
  DateTime selectDate;

  RefreshIndicatorCallEvent({this.selectDate});
}

class ArrivedFromNotificationList extends BaseBlocEvent {
  final dynamic arg;

  ArrivedFromNotificationList(this.arg);
}

class NotifyCheck extends BaseBlocEvent {}

class NotifyRefreshState extends BaseBlocState {}

class BaseHomeCalendarState extends BaseBlocState {}

class CalendarInitializedState extends BaseBlocState {}

class DiaryCheck extends BaseBlocState {}

class GestureChangeEvent extends BaseBlocEvent {}

class GestureChangeState extends BaseBlocState {}

class LoadingEvent extends BaseBlocEvent {}

class LoadingState extends BaseBlocState {}

class CheckState extends BaseBlocState {}
