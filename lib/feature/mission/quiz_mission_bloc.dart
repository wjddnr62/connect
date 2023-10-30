import 'dart:async';

import 'package:connect/data/remote/mission/mission_service.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/feature/home/MissionProvider.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/resources/app_colors.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/resources/app_text_style.dart';
import 'package:connect/widgets/base_alert_dialog.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'common_mission_bloc.dart';

class QuizMissionBloc extends BaseBloc {
  QuizMissionBloc(BuildContext context, CommonMissionBloc bloc) : super(bloc.mission.completed ? StateComplete() : StateNotComplete()) {
    repository = Provider.of<MissionProvider>(context, listen: false);
  }

  String quizType = "OX";
  int answer = 1;
  int selectAnswer;
  String nextQuizType = "multiple";
  bool finishPage = false;
  String descriptionText = "";
  String image;
  List<Quiz> quiz;
  int quizNum = 0;
  List<Html> htmlList = List();
  bool answerDialog = false;

  // ignore: close_sinks
  CommonMissionBloc commonBloc;
  MissionDetail missionDetail;
  bool isLoading = false;

  bool activate = true;

  MissionProvider repository;

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    // TODO: implement mapEventToState
    if (event is QuizMissionInitEvent) {
      commonBloc = event.bloc;
      isLoading = true;
      yield LoadingState();

      loadingCheckTimer(event.context);
      missionDetail =
      await GetMissionDetailService(missionId: commonBloc.mission.id).start();
      isLoading = false;
      yield LoadingState();

      quiz = missionDetail.meta.quizList;

      if (quiz[quizNum].quizType == null) {
        quizType = 'description';
      } else {
        quizType = quiz[quizNum].quizType;
      }

      if (quiz[quizNum].answerList != null) {
        for (int i = 0; i < quiz[quizNum].answerList.length; i++) {
          if (quiz[quizNum].answerList[i].isAnswer) {
            answer = i;
            break;
          }
        }
      }

      if (quiz.length == 2) {
        if (quiz[1].answerList == null) {
          finishPage = true;
        }
      }

      String html = missionDetail.meta.links[quizNum];
      htmlAdd(html);
      yield QuizMissionInitState();
    }

    if (event is OXButtonSelectEvent) {
      selectAnswer = event.selectAnswer;
      if (answer != selectAnswer) {
        yield WrongAnswerState();
      } else if (answer == selectAnswer) {
        if (quizNum + 1 < quiz.length) {
          quizNum += 1;
          if (quiz[quizNum].quizType == null) {
            nextQuizType = "description";
            descriptionText = missionDetail.meta.links[quizNum];
            if (quizNum < quiz.length) {
              answerDialog = true;
              yield AnswerState(next: true);
            }
          } else {
            nextQuizType = quiz[quizNum].quizType;
            selectAnswer = null;

            if (quiz[quizNum].answerList != null)
              for (int i = 0; i < quiz[quizNum].answerList.length; i++) {
                if (quiz[quizNum].answerList[i].isAnswer) {
                  answer = i;
                  break;
                }
              }

            descriptionText = missionDetail.meta.links[quizNum];
            htmlAdd(descriptionText);
            answerDialog = true;
            yield AnswerState(next: true);
          }
        } else {
          yield AnswerState(next: false);
          // complete code 작성
        }
      }
      yield OXButtonSelectState();
    }

    if (event is QuizTypeChangeEvent) {
      quizType = event.type;
      yield QuizTypeChangeState();
    }

    if (event is TryAgainEvent) {
      selectAnswer = null;
      yield TryAgainState();
    }

    if (event is MultipleButtonSelectEvent) {
      selectAnswer = event.selectAnswer;
      if (answer != selectAnswer) {
        yield WrongAnswerState();
      } else if (answer == selectAnswer) {
        if (quizNum + 1 < quiz.length) {
          quizNum += 1;
          if (quiz[quizNum].quizType == null) {
            nextQuizType = "description";
            descriptionText = missionDetail.meta.links[quizNum];
            if (quizNum < quiz.length) {
              answerDialog = true;
              yield AnswerState(next: true);
            }
          } else {
            nextQuizType = quiz[quizNum].quizType;
            selectAnswer = null;

            if (quiz[quizNum].answerList != null)
              for (int i = 0; i < quiz[quizNum].answerList.length; i++) {
                if (quiz[quizNum].answerList[i].isAnswer) {
                  answer = i;
                  break;
                }
              }

            descriptionText = missionDetail.meta.links[quizNum];
            htmlAdd(descriptionText);
            answerDialog = true;
            yield AnswerState(next: true);
          }
        } else {
          answerDialog = true;
          yield AnswerState(next: false);
        }
      }
      yield MultipleButtonSelectState();
    }

    if (event is DescriptiveSubmitEvent) {
      if (quizNum + 1 < quiz.length) {
        quizNum += 1;
        if (quiz[quizNum].quizType == null) {
          nextQuizType = "description";
          descriptionText = missionDetail.meta.links[quizNum];
          // htmlAdd(descriptionText);
          if (quizNum < quiz.length) {
            answerDialog = true;
            yield AnswerState(next: true);
          }
        } else {
          nextQuizType = quiz[quizNum].quizType;
          selectAnswer = null;

          if (quiz[quizNum].answerList != null)
            for (int i = 0; i < quiz[quizNum].answerList.length; i++) {
              if (quiz[quizNum].answerList[i].isAnswer) {
                answer = i;
                break;
              }
            }

          descriptionText = missionDetail.meta.links[quizNum];
          htmlAdd(descriptionText);
          answerDialog = true;
          yield AnswerState(next: true);
        }
      } else {
        answerDialog = true;
        yield AnswerState(next: false);
      }
    }

    if (event is NextButtonClickEvent) {
      quizNum += 1;
      if (quizNum < quiz.length) {
        quizType = quiz[quizNum].quizType;
        selectAnswer = null;

        if (quizType != null && quiz[quizNum].answerList != null) {
          for (int i = 0; i < quiz[quizNum].answerList.length; i++) {
            if (quiz[quizNum].answerList[i].isAnswer) {
              answer = i;
              break;
            }
          }

          descriptionText = missionDetail.meta.links[quizNum];
          htmlAdd(descriptionText);
          yield LoadingState();
          if (quizNum + 2 == quiz.length) {
            finishPage = true;
          }
        } else {
          quizType = "description";
          descriptionText = quiz[quizNum].content;
          htmlAdd(descriptionText);
          yield LoadingState();
          if (quizNum + 1 == quiz.length) {
            finishPage = true;
          }
        }
      }
    }

    if (event is EventCompleteQuiz) {
      if (activate) {
        yield StateProcessingQuiz();
        activate = false;
        activateTimer();
        commonBloc.mission.completed =
        await repository.doMission(date: commonBloc.date, id: commonBloc.mission.id);
        yield StateCompleteQuiz();
      }

      return;
    }

    if (event is EventUndoQuiz) {
      if (activate) {
        yield StateProcessingQuiz();
        activate = false;
        activateTimer();
        commonBloc.mission.completed =
        !(await repository.undoMission(date: commonBloc.date, id: commonBloc.mission.id));
        yield StateNotCompleteQuiz();
      }

      return;
    }
  }

  loadingCheckTimer(context) {
    Timer(Duration(milliseconds: 7000), () {
      if (isLoading) {
        Navigator.of(context).pop();

        showDialog(
            context: context,
            child: BaseAlertDialog(
              content: AppStrings.of(StringKey.Access_interrupted_due_to_a_temporary_problem),
              onConfirm: () => null,
            ));
      }
    });
  }

  htmlAdd(html) {
    htmlList = List();
    htmlList.add(Html(
        padding: EdgeInsets.only(
            top: resize(16),
            bottom: resize(16),
            left: resize(24),
            right: resize(24)),
        data: html,
        useRichText: true,
        onLinkTap: (url) async {
          if (await canLaunch(url)) {
            await launch(url);
          }
        },
        customTextStyle: (n, te) {
          final attr = n.attributes['style'];
          if (attr == null) return te;
          final keyValue = attr.split(":");
          return te.copyWith(
              color: getHtmlColor(keyValue, 'color'),
              backgroundColor: getHtmlColor(keyValue, 'background-color'),
              fontSize: getHtmlFontSize(keyValue));
        },
        defaultTextStyle: AppTextStyle.from(
            color: AppColors.black,
            size: TextSize.body_medium,
            weight: TextWeight.semibold,
            height: 1.5)));
  }

  activateTimer() async {
    Timer(Duration(milliseconds: 1500), () {
      activate = true;
    });
  }

  Color getHtmlColor(List<String> keyValue, String key) {
    if (keyValue.isEmpty || keyValue.first != key) return null;

    var hexCode = keyValue[1].replaceAll(' #', '0xFF').toLowerCase();
    hexCode = hexCode.replaceAll(';', '');
    return Color(int.parse(hexCode));
  }

  double getHtmlFontSize(List<String> keyValue) {
    if (keyValue.isEmpty || keyValue.first != 'font-size') return null;

    var sizeStr = keyValue[1].replaceAll('pt;', '').trim();
    return resize(double.parse(sizeStr));
  }
}

class DescriptiveSubmitEvent extends BaseBlocEvent {
  final String answer;

  DescriptiveSubmitEvent({this.answer});
}

class MultipleButtonSelectEvent extends BaseBlocEvent {
  final int selectAnswer;

  MultipleButtonSelectEvent({this.selectAnswer});
}

class MultipleButtonSelectState extends BaseBlocState {}

class NextButtonClickEvent extends BaseBlocEvent {}

class TryAgainEvent extends BaseBlocEvent {}

class TryAgainState extends BaseBlocState {}

class QuizTypeChangeEvent extends BaseBlocEvent {
  final String type;

  QuizTypeChangeEvent({this.type});
}

class QuizTypeChangeState extends BaseBlocState {}

class WrongAnswerState extends BaseBlocState {}

class AnswerState extends BaseBlocState {
  final bool next;

  AnswerState({this.next});
}

class OXButtonSelectEvent extends BaseBlocEvent {
  final int selectAnswer;

  OXButtonSelectEvent({this.selectAnswer});
}

class OXButtonSelectState extends BaseBlocState {}

class BaseQuizMissionState extends BaseBlocState {}

class LoadingState extends BaseBlocState {}

class QuizMissionInitEvent extends BaseBlocEvent {
  final CommonMissionBloc bloc;
  final BuildContext context;

  QuizMissionInitEvent({this.bloc, this.context});
}

class QuizMissionInitState extends BaseBlocState {}

class EventCompleteQuiz extends BaseBlocEvent {}

class EventUndoQuiz extends BaseBlocEvent {}

class StateProcessingQuiz extends BaseBlocState {}

class StateCompleteQuiz extends BaseBlocState {}

class StateNotCompleteQuiz extends BaseBlocState {}