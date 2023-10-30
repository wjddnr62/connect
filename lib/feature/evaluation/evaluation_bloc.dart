import 'dart:async';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/profile_repository.dart';
import 'package:connect/data/user_repository.dart';
import 'package:connect/feature/bottom_navigation/home_navigation.dart';
import 'package:connect/feature/home/home_calendar.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/evaluation.dart';
import 'package:connect/models/profile.dart';
import 'package:connect/utils/appsflyer/apps_flyer.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:provider/provider.dart';

import '../base_bloc.dart';
import 'evaluation_provider.dart';

class EvaluationBloc extends BaseBloc {
  EvaluationProvider evaluationProvider;

  EvaluationBloc(BuildContext context) : super(BaseEvaluationState()) {
    evaluationProvider =
        Provider.of<EvaluationProvider>(context, listen: false);
  }

  bool get isLoading => evaluationProvider.loading;
  bool loading = false;

  List<Evaluation> evaluationData = List();
  String type = "Function";
  int progress = 0;
  int index = 1;
  List<EvaluationSelectAnswer> evaluationSelectAnswer = List();
  List<double> scoreSave = List();
  List<int> typeIndex = List();

  final String function = "Function";
  final String generalHealthcare = "General Healthcare";
  final String lifeStyle = "Life Style";
  final String socialActivity = "Social Activity";

  String userLevel;
  String userMobility;

  double scrollAnimationDataListTopHeight = 174;

  bool genderSelect = false;

  bool evaluationCheckFinish = false;
  bool genderSelectFinish = false;

  int selectGender;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    yield LoadingState();
    if (event is EvaluationInitEvent) {
      await evaluationSetData();
      yield EvaluationInitState();
    }

    if (event is EvaluationAnswerSelectEvent) {
      index += 1;
      yield EvaluationAnswerSelectState();
    }

    if (event is EvaluationProgressChangeEvent) {
      index = 1;
      progress += 1;
      type = evaluationData[progress].type;
      yield EvaluationProgressChangeState();
    }

    if (event is DataInputEvent) {
      loading = true;
      yield LoadingState();
      scoreSave = List();
      for (int i = 0; i < evaluationSelectAnswer.length; i++) {
        evaluationSelectAnswer[i].typeSelect = typeChange(
          evaluationSelectAnswer[i].typeSelect,
        );

        evaluationSelectAnswer[i].scoreSum =
            evaluationSelectAnswer[i].scoreSum / typeIndex[i];
      }

      await evaluationProvider.putUserEvaluationData(
          functionalLevel: userLevel,
          mobility: userMobility,
          answers: evaluationSelectAnswer);

      await AppDao.setEvaluationPayment("${await AppDao.email}*true");

      loading = false;
      yield LoadingState();

      if (event.checkStatus == 0) {
        appsflyer.saveLog(evalDone);
        await ProfileRepository.updateUserProfile(
            patientWishMessage: event.wishMessage);
        // HomeCalendarPage.pushAndRemoveUntil(event.context);
        HomeNavigation.pushAndRemoveUntil(event.context);
      } else {
        // HomeCalendarPage.popUntil(event.context);
        HomeNavigation.popUntil(event.context);
      }
    }

    if (event is EvaluationFinishEvent) {
      evaluationCheckFinish = true;

      yield EvaluationFinishState();
    }

    if (event is EvaluationBackMoveEvent) {
      if (index != 1) {
        index -= 1;
        evaluationSelectAnswer[progress].scoreSum -= scoreSave.last;
        scoreSave.removeLast();
      } else if (index == 1) {
        progress -= 1;
        index = evaluationData[progress].question.length;
        type = evaluationData[progress].type;
        evaluationSelectAnswer[progress].scoreSum -= scoreSave.last;
        scoreSave.removeLast();
      }
      yield EvaluationBackMoveState();
    }

    if (event is EvaluationScrollChangeEvent) {
      if (event.type == 1) {
        scrollAnimationDataListTopHeight = 74;
      } else {
        scrollAnimationDataListTopHeight = 174;
      }

      yield EvaluationScrollChangeState();
    }

    if (event is GenderSelectEvent) {
      selectGender = event.selectGender;
      genderSelect = true;
      yield GenderSelectState();
    }

    if (event is GenderSelectFinishEvent) {
      loading = true;
      yield LoadingState();
      Profile profile = await UserRepository.getProfile();

      String gender;
      if (selectGender == 0) {
        gender = "MALE";
      } else if (selectGender == 1) {
        gender = "FEMALE";
      } else if (selectGender == 2) {
        gender = "OTHER";
      }

      var res = await ProfileRepository.updateUserProfile(
          name: profile.name,
          statusMessage: profile.statusMessage,
          birthday:
              "${profile.birthday.year}-${profile.birthday.month.toString().length == 1 ? "0${profile.birthday.month}" : "${profile.birthday.month}"}-${profile.birthday.day.toString().length == 1 ? "0${profile.birthday.day}" : "${profile.birthday.day}"}",
          gender: gender,
          profileImageName: profile.profileImageName);
      if (res is ServiceError) {
        loading = false;
      } else {
        loading = false;
        genderSelectFinish = true;
      }
      yield GenderSelectFinishState();
    }
  }

  evaluationSetData() async {
    evaluationData = await evaluationProvider.getEvaluationQuestion();
    for (int i = 0; i < evaluationData.length; i++) {
      evaluationSelectAnswer.add(EvaluationSelectAnswer(
          typeSelect: evaluationData[i].type, scoreSum: 0));
      typeIndex.add(0);
    }
  }

  typeChange(type) {
    switch (type) {
      case "Function":
        return "FUNCTION";
      case "General Healthcare":
        return "GENERAL_HEALTHCARE";
      case "Life Style":
        return "LIFE_STYLE";
      case "Social Activity":
        return "SOCIAL_ACTIVITY";
    }
  }
}

class EvaluationInitEvent extends BaseBlocEvent {}

class EvaluationInitState extends BaseBlocState {}

class EvaluationAnswerSelectEvent extends BaseBlocEvent {}

class EvaluationAnswerSelectState extends BaseBlocState {}

class EvaluationBackMoveEvent extends BaseBlocEvent {}

class EvaluationBackMoveState extends BaseBlocState {}

class DataInputEvent extends BaseBlocEvent {
  final BuildContext context;
  final int checkStatus;
  final String wishMessage;

  DataInputEvent({this.context, this.checkStatus, this.wishMessage});
}

class GenderSelectFinishEvent extends BaseBlocEvent {}

class GenderSelectFinishState extends BaseBlocState {}

class GenderSelectEvent extends BaseBlocEvent {
  final int selectGender;

  GenderSelectEvent({this.selectGender});
}

class GenderSelectState extends BaseBlocState {}

class EvaluationFinishEvent extends BaseBlocEvent {}

class EvaluationFinishState extends BaseBlocState {}

class EvaluationProgressChangeEvent extends BaseBlocEvent {}

class EvaluationProgressChangeState extends BaseBlocState {}

class EvaluationScrollChangeEvent extends BaseBlocEvent {
  final int type;

  EvaluationScrollChangeEvent({this.type});
}

class EvaluationScrollChangeState extends BaseBlocState {}

class BaseEvaluationState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}
