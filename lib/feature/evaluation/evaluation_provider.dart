import 'dart:async';

import 'package:connect/data/evaluation_repository.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/error.dart';
import 'package:connect/models/evaluation.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:provider/provider.dart';

class EvaluationProvider extends ChangeNotifier {
  List<Evaluation> evaluationQuestion = List();
  bool loading = true;

  static EvaluationProvider of(BuildContext context) =>
      Provider.of<EvaluationProvider>(context);

  getEvaluationQuestion() async {
    loading = true;
    var res = await EvaluationRepository.getEvaluationQuestion();

    if (res == null) {
      return null;
    }

    if (res is ServiceError) {
      return res;
    }

    if (res is List<Evaluation>) {
      evaluationQuestion = res;

      loading = false;
      notifyListeners();
      return res;
    }
  }

  putUserEvaluationData(
      {String functionalLevel, String mobility, List<EvaluationSelectAnswer> answers}) async {
    loading = true;
    notifyListeners();

    var res = await EvaluationRepository.putUserFunctionalLevel(
        functionalLevel: functionalLevel, mobility: mobility);

    if (res is ServiceError) {
      return res;
    }

    if (res == true || res == null) {
      var saveEvaluation =
      await EvaluationRepository.putUserEvaluationSave(answers: answers);

      if (saveEvaluation == null) {
        return null;
      }

      if (saveEvaluation is ServiceError) {
        return saveEvaluation;
      }

      if (saveEvaluation == true) {
        loading = false;
        notifyListeners();
        return true;
      }
    }
  }
}
