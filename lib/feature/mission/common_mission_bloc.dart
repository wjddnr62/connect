import 'dart:async';

import 'package:connect/data/bookmark_repository.dart';
import 'package:connect/data/contents_repository.dart';
import 'package:connect/data/mission_repository.dart';
import 'package:connect/data/remote/mission/mission_service.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/home/MissionProvider.dart';
import 'package:connect/feature/mission/mission_complete_button.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/resources/app_strings.dart';
import 'package:connect/user_log/user_logger.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../base_bloc.dart';

class CommonMissionBloc extends BaseBloc {
  final DateTime date;
  final Mission mission;
  DateTime _missionStartTime;
  final Profile profile;

//  ContentsRepository repository;
  MissionProvider repository;

  bool activate = true;

  MissionDetail missionDetail;

  bool isLoading = false;

  CommonMissionBloc(BuildContext context,
      {@required this.date,
      @required this.mission,
      this.missionDetail,
      this.profile})
      : super(mission.completed ?? false ? StateComplete() : StateNotComplete()) {
    repository = Provider.of<MissionProvider>(context, listen: false);
  }

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield RefreshState();
    if (event is MissionTouchEvent) {
      yield MissionTouchState(mission: event.mission);
    }

    if (event is MissionPageEnter) {
      _missionStartTime = DateTime.now();
    }

    if (event is EventComplete) {
      if (activate) {
        yield StateProcessing();
        activate = false;
        activateTimer();
        mission.completed =
            await repository.doMission(date: date, id: mission.id);
        _logComplete();
        yield StateComplete();
      }

      return;
    }

    if (event is MissionPageExit) {
      final endTime = DateTime.now();
      repository.playLog(mission.id, _missionStartTime, endTime,
          endTime.difference(_missionStartTime));
      _missionStartTime = null;
    }

    if (event is EventUndo) {
      if (activate) {
        yield StateProcessing();
        activate = false;
        activateTimer();
        mission.completed =
            !(await repository.undoMission(date: date, id: mission.id));
        _logUndo();
        yield StateNotComplete();
      }

      return;
    }

    if (event is GetMissionDetailEvent) {
      isLoading = true;
      yield GetMissionDetailState();
      yield RefreshState();
      loadingCheckTimer(event.context);
      missionDetail =
          await GetMissionDetailService(missionId: mission.id).start();
      isLoading = false;
      yield GetMissionDetailState();
    }

    if (event is MissionBookmarkAddEvent) {
      await BookmarkRepository.bookmarkAdd(event.id);

      missionDetail.isBookmark = true;
      yield MissionBookmarkAddState();
    }

    if (event is MissionBookmarkRemoveEvent) {
      await BookmarkRepository.bookmarkRemove(event.id);

      missionDetail.isBookmark = false;
      yield MissionBookmarkAddState();
    }
  }

  activateTimer() async {
    Timer(Duration(milliseconds: 1500), () {
      activate = true;
    });
  }

  loadingCheckTimer(context) {
    Timer(Duration(milliseconds: 7000), () {
      if (isLoading) {
        Navigator.of(context).pop();

        showDialog(
            context: context,
            child: BaseAlertDialog(
              content: AppStrings.of(
                  StringKey.Access_interrupted_due_to_a_temporary_problem),
              onConfirm: () => null,
            ));
      }
    });
  }

  _logComplete() {
    String tag = "mission_complete_";
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
    }

    UserLogger.logEventName(eventName: tag, param: {"id": mission.id});
  }

  _logUndo() {
    String tag = "mission_undo_";
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
    }

    UserLogger.logEventName(eventName: tag, param: {"id": mission.id});
  }
}

class EventComplete extends BaseBlocEvent {}

class EventUndo extends BaseBlocEvent {}

class StateProcessing extends BaseBlocState {}

class StateComplete extends BaseBlocState {}

class StateNotComplete extends BaseBlocState {}

class MissionPageEnter extends BaseBlocEvent {}

class MissionPageExit extends BaseBlocEvent {}

class InitEvent extends BaseBlocEvent {}

class MissionTouchEvent extends BaseBlocEvent {
  final String mission;

  MissionTouchEvent({this.mission});
}

class MissionTouchState extends BaseBlocState {
  final String mission;

  MissionTouchState({this.mission});
}

class GetMissionDetailEvent extends BaseBlocEvent {
  final BuildContext context;

  GetMissionDetailEvent(this.context);
}

class GetMissionDetailState extends BaseBlocState {}

class MissionBookmarkAddEvent extends BaseBlocEvent {
  final String id;

  MissionBookmarkAddEvent({this.id});
}

class MissionBookmarkAddState extends BaseBlocState {}

class MissionBookmarkRemoveEvent extends BaseBlocEvent {
  final String id;

  MissionBookmarkRemoveEvent({this.id});
}

class MissionBookmarkRemoveState extends BaseBlocState {}

class RefreshState extends BaseBlocState {}
