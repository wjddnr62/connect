import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/trackerChecks.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/utils/extensions.dart';

class HomeNavigationBloc extends BaseBloc {
  HomeNavigationBloc(BuildContext context) : super(BaseHomeNavigationState());

  int selectedIndex = 0;
  List<MissionRenewal> missions;
  List<DiaryChecks> diaryChecks;
  List<String> diaryRemove = List();
  List<TrackerChecks> trackerChecks = List();

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is HomeNavigationInitEvent) {
      yield HomeNavigationInitState();
    }

    if (event is ChangeViewEvent) {
      selectedIndex = event.changeIndex;
      if (event.missions != null && event.missions.isNotEmpty) {
        missions = event.missions;
      }
      if (event.diaryChecks != null && event.diaryChecks.isNotEmpty) {
        diaryChecks = event.diaryChecks;
      }
      if (event.trackerChecks != null && event.trackerChecks.isNotEmpty) {
        trackerChecks = event.trackerChecks;
      }

      yield ChangeViewState();
    }

    if (event is SaveMissionEvent) {
      if (event.missions != null && event.missions.isNotEmpty) {
        missions = event.missions;
      }
      if (event.diaryChecks != null && event.diaryChecks.isNotEmpty) {
        diaryChecks = event.diaryChecks;
      }
      if (event.trackerChecks != null && event.trackerChecks.isNotEmpty) {
        trackerChecks = event.trackerChecks;
      }

      yield SaveMissionState();
    }

    if (event is DiaryRemoveDateEvent) {
      diaryRemove.add(DateTime.parse(event.date).isoYYYYMMDD);
      yield DiaryRemoveDateState();
    }

    if (event is DiaryRemoveListClearEvent) {
      diaryRemove = List();
      yield DiaryRemoveListClearState();
    }
  }
}

class ChangeViewEvent extends BaseBlocEvent {
  final int changeIndex;
  final List<MissionRenewal> missions;
  final List<DiaryChecks> diaryChecks;
  final List<TrackerChecks> trackerChecks;

  ChangeViewEvent(
      {this.changeIndex, this.missions, this.diaryChecks, this.trackerChecks});
}

class ChangeViewState extends BaseBlocState {}

class SaveMissionEvent extends BaseBlocEvent {
  final List<MissionRenewal> missions;
  final List<DiaryChecks> diaryChecks;
  final List<TrackerChecks> trackerChecks;

  SaveMissionEvent({this.missions, this.diaryChecks, this.trackerChecks});
}

class SaveMissionState extends BaseBlocState {}

class DiaryRemoveDateEvent extends BaseBlocEvent {
  final String date;

  DiaryRemoveDateEvent({this.date});
}

class DiaryRemoveDateState extends BaseBlocState {}

class DiaryRemoveListClearEvent extends BaseBlocEvent {}

class DiaryRemoveListClearState extends BaseBlocState {}

class BaseHomeNavigationState extends BaseBlocState {}

class HomeNavigationInitEvent extends BaseBlocEvent {}

class HomeNavigationInitState extends BaseBlocState {}
