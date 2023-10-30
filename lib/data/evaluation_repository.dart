import 'package:connect/data/remote/evaluation/evaluation_service.dart';
import 'package:connect/models/evaluation.dart';

class EvaluationRepository {
  static Future<dynamic> isCompleteEvaluation() =>
      IsCompletedEvaluationService().start();

  static Future<dynamic> isValidEvaluation() =>
      IsValidEvaluationService().start();

  static Future<dynamic> getEvaluationQuestion() =>
      GetEvaluationQuestion().start();

  static Future<dynamic> getEvaluationItem({int answer}) =>
      GetEvaluationItemService(answer: answer).start();

  static Future<dynamic> putUserFunctionalLevel({String functionalLevel, String mobility}) =>
      PutUserFunctionalLevel(functionalLevel: functionalLevel, mobility: mobility).start();

  static Future<dynamic> putUserEvaluationSave(
          {List<EvaluationSelectAnswer> answers}) =>
      PutUserEvaluationSave(answers: answers).start();

  static Future<dynamic> getWelcomeMessage() => GetWelcomeService().start();
}
