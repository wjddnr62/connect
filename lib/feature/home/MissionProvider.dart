import 'package:connect/data/diary_repository.dart';
import 'package:connect/data/evaluation_repository.dart';
import 'package:connect/data/mission_repository.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/remote/mission/mission_playlog_service.dart';
import 'package:connect/feature/notification/notification_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/evaluation.dart';
import 'package:connect/models/mission_historys.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/push_notification.dart';
import 'package:connect/utils/calendar_utils.dart';
import 'package:connect/utils/date_format.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/utils/extensions.dart';
import 'package:provider/provider.dart';

class MissionProvider extends ChangeNotifier {
  DateTime selectedDate;
  List<DateTime> dates = List();

  List<bool> diaryCheckList = List();
  DateTime _startDate;
  DateTime _endDate;
  DateTime _since;
  DateTime _to;

  int get dateCount => dates.length;

  DateTime get endDate => _endDate;
  bool loading = false;
  bool completedEvaluation = true;
  String completedTitle = "";
  String completedDescription = "";

  String validTitle = "";
  String validDescription = "";

  static MissionProvider of(BuildContext context) =>
      Provider.of<MissionProvider>(context);

  void init() {
    _since = DateTime(2019, 4, 1);
    _to = DateTime.now();
    refreshDateList(0);
  }

  getDiaryCheckList(MissionRenewal missions) async {
    if (missions == null) {
      return false;
    }
    var res = await DiaryRepository.diaryUserWriteCheckService(missions.date);

    if (res is ServiceError) {
      return false;
    }

    return res;
  }

  int getValidMissionIndex(int calendarPageIndex) {
    int index = (calendarPageIndex * 7) + selectedDate.weekday - 1;
    // block to scroll over today.
    if (index > dates.length - 1 - (7 - _to.weekday)) {
      index = dates.length - 1 - (7 - _to.weekday);
    }

    return index;
  }

  void missionDateChanged(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  bool isSameSelectedDay(DateTime targetDate) {
    return isSameDay(selectedDate, targetDate);
  }

  Future refreshDateList(int pageIndex) async {
    // 오늘을 포함하고 있다면 다시 만들 필요가 없다.
    if (dates.contains(DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day))) {
      return;
    }
    // 혹시나 클리
    dates.clear();

    _startDate = DateTime(_since.year, _since.month, _since.day).weekStart;
    _endDate = DateTime(_to.year, _to.month, _to.day).weekEnd;
    DateTime date = _startDate;
    int difference = date.difference(_endDate).inDays;

    while (difference <= 0) {
      dates.add(date);
      date = date.tomorrow;
      difference = date.difference(_endDate).inDays;
    }

    selectedDate = _endDate;
  }

  needToUpdateSeverity() async {
    var res = await EvaluationRepository.isCompleteEvaluation();

    if (res == null) {
      return null;
    }

    if (res is ServiceError) {
      return res;
    }

    completedEvaluation = res.completed;
    completedTitle = res.title;
    completedDescription = res.description;

    notifyListeners();

    return res;
  }

  Future<bool> doMission({DateTime date, String id}) async {
    var res = await MissionRepository.complete(id);

    if (res is ServiceError) {
      return false;
    }

    notifyListeners();

    return true;
  }

  Future<bool> undoMission({DateTime date, String id}) async {
    var res = await MissionRepository.undo(id);

    if (res is ServiceError) {
      return false;
    }

    notifyListeners();

    return true;
  }

  Future<bool> diaryCheck({String date}) async {
    var res = await DiaryRepository.diaryUserWriteCheckService(date);

    if (res is ServiceError) {
      return false;
    }

    notifyListeners();

    return res;
  }

  Future playLog(
      String missionId, DateTime start, DateTime end, Duration duration) async {
    return MissionPlayLogService(missionId, start, end, duration).start();
  }
}
