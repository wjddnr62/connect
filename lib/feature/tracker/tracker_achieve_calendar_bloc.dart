import 'package:connect/data/tracking_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/utils/extensions.dart';

class TrackerAchieveCalendarBloc extends BaseBloc {
  TrackerAchieveCalendarBloc(BuildContext context)
      : super(BaseTrackerAchieveCalendarState());

  bool isLoading = false;
  DateTime nowDate = DateTime.now();
  int dayLength = 0;
  int nowDay = 0;
  List<int> days = List();
  int startDay = 0;
  List<int> completedDay = List();

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    yield StartState();
    if (event is TrackerAchieveCalendarInitEvent) {
      isLoading = true;
      yield LoadingState();
      days.clear();
      days = List();
      completedDay.clear();
      completedDay = List();

      var res = await TrackingRepository.trackerGetAchieve(nowDate.yyyymm);
      if (res != null) {
        for (int i = 0; i < res['achieveDates'].length; i++) {
          completedDay
              .add(int.parse(res['achieveDates'][i].toString().split("-")[2]));
        }
      }

      DateTime firstDayCurrentMonth = DateTime(nowDate.year, nowDate.month, 1);

      DateTime lastDayCurrentMonth = DateTime(
        nowDate.year,
        nowDate.month + 1,
      ).subtract(Duration(days: 1));

      dayLength =
          lastDayCurrentMonth.difference(firstDayCurrentMonth).inDays + 1;
      nowDay = nowDate.day;
      startDay = firstDayCurrentMonth.weekday;

      for (int i = 0; i < dayLength; i++) {
        days.add(i + 1);
      }
      yield StartState();
      isLoading = false;
      yield LoadingState();
    }

    if (event is MonthNextEvent) {
      yield LoadingState();
      DateTime lastDayCurrentMonth = DateTime(
        nowDate.year,
        nowDate.month + 1,
      ).subtract(Duration(days: 1));
      int addDay = lastDayCurrentMonth.difference(nowDate).inDays + 2;
      nowDate = nowDate.add(Duration(days: addDay));
      if (nowDate.month == DateTime.now().month) {
        nowDate = DateTime.now();
      }
      yield ChangeMonthState();
    }

    if (event is MonthPrevEvent) {
      yield LoadingState();
      DateTime firstDayCurrentMonth = DateTime(nowDate.year, nowDate.month, 1);
      int subtractDay = nowDate.difference(firstDayCurrentMonth).inDays + 1;
      nowDate = nowDate.subtract(Duration(days: subtractDay));
      if (nowDate.month == DateTime.now().month) {
        nowDate = DateTime.now();
      }
      yield ChangeMonthState();
    }
  }
}

class MonthNextEvent extends BaseBlocEvent {}

class MonthPrevEvent extends BaseBlocEvent {}

class ChangeMonthState extends BaseBlocState {}

class TrackerAchieveCalendarInitEvent extends BaseBlocEvent {}

class TrackerAchieveCalendarInitState extends BaseBlocState {}

class BaseTrackerAchieveCalendarState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class StartState extends BaseBlocState {}