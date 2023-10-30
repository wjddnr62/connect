import 'package:connect/data/evaluation_repository.dart';
import 'package:connect/feature/base_bloc.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/question.dart';
import 'package:connect/user_log/events.dart';

class PatientInfoMissionBloc extends BaseBloc {
  String missionId;

  PatientInfoMissionBloc() : super(GettingQuestionState());

  @override
  Stream<BaseBlocState> mapEventToState(BaseBlocEvent event) async* {
    if (event is GettingQuestionEvent) {
      yield GettingQuestionState();
      var response = await EvaluationRepository.getEvaluationItem();

      if (response is EvaluationItem) {
        add(EvaluateEvent(evaluation: response));
        return;
      }

      yield ErrorState(
          error: response is ServiceError ? response : ServiceError());
      return;
    }

    if (event is EvaluateEvent) {
      yield EvaluateState(evaluation: event.evaluation);
      return;
    }

    if (event is AnswerEvent) {
      yield GettingQuestionState();
      var response = await EvaluationRepository.getEvaluationItem(
          answer: event.answerValue);

      if (response is EvaluationItem) {
        if (response.question == null ||
            response.question.answers.isEmpty ||
            response.isCompleted) {
          var message = await EvaluationRepository.getWelcomeMessage();

          add(CompleteEvent(message: (message is String) ? message : null));
        } else {
          add(EvaluateEvent(evaluation: response));
        }
        return;
      }

      yield ErrorState(
          error: response is ServiceError ? response : ServiceError());

      return;
    }

    if (event is CompleteEvent) {
      yield CompleteState(message: event.message);
      return;
    }
  }
}

// ignore: must_be_immutable
class GettingQuestionEvent extends BaseBlocEvent {
  final int answerValue;

  GettingQuestionEvent({this.answerValue});
}

// ignore: must_be_immutable
class EvaluateEvent extends BaseBlocEvent {
  final EvaluationItem evaluation;

  EvaluateEvent({this.evaluation});
}

// ignore: must_be_immutable
class AnswerEvent extends BaseBlocEvent {
  final int answerValue;

  AnswerEvent({this.answerValue});
}

// ignore: must_be_immutable
class CompleteEvent extends BaseBlocEvent {
  final String message;

  CompleteEvent({this.message});
}

// ignore: must_be_immutable
class GettingQuestionState extends BaseBlocState {}

// ignore: must_be_immutable
class EvaluateState extends BaseBlocState {
  final EvaluationItem evaluation;

  EvaluateState({this.evaluation});
}

// ignore: must_be_immutable
class ErrorState extends BaseBlocState {
  final ServiceError error;

  ErrorState({this.error}) : assert(error != null);
}

// ignore: must_be_immutable
class CompleteState extends BaseBlocState {
  final String message;

  CompleteState({this.message});

  @override
  String get tag => EventEvaluation.EVALUATION_COMPLETE;
}
