import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/evaluation.dart';
import 'package:connect/models/missions.dart';
import 'package:connect/models/question.dart';
import 'package:http/http.dart' as http;
import 'package:http/src/response.dart';

class IsCompletedEvaluationService extends BaseService<EvaluationMission> {
  IsCompletedEvaluationService();

  @override
  Future<http.Response> request() async => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/evaluation/isCompletedHandArmFunction';

  @override
  EvaluationMission success(body) => EvaluationMission.fromJson(body);
}

class IsValidEvaluationService extends BaseService<ValidEvaluation> {
  IsValidEvaluationService();

  @override
  Future<http.Response> request() async => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/evaluation/isValidHandArmFunction';

  @override
  ValidEvaluation success(body) => ValidEvaluation.fromJson(body);
}

class GetEvaluationQuestion extends BaseService<List<Evaluation>> {
  GetEvaluationQuestion();

  @override
  Future<http.Response> request() async => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/evaluation/handArmFunciton';

  @override
  List<Evaluation> success(body) {
    List<Evaluation> evaluations = List();

    for (var data in body) {
      Evaluation evaluation = Evaluation.fromJson(data);
      evaluations.add(evaluation);
    }

    return evaluations;
  }
}

class PutUserFunctionalLevel extends BaseService {
  final String functionalLevel;
  final String mobility;

  PutUserFunctionalLevel({this.functionalLevel, this.mobility})
      : assert(functionalLevel != null && mobility != null);

  @override
  Future<http.Response> request() async {
    // TODO: implement request
    return fetchPut(
        body: jsonEncode({
      'user_id': await AppDao.userId,
      'user_name': await AppDao.nickname,
      'email': await AppDao.email,
      'level': functionalLevel,
      'mobility': mobility
    }));
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/user/handArmFunction';
  }

  @override
  success(body) {
    // TODO: implement success
    return true;
  }
}

class PutUserEvaluationSave extends BaseService {
  final List<EvaluationSelectAnswer> answers;

  PutUserEvaluationSave({this.answers})
      : assert(answers != null && answers.length != 0);

  List encodeToJson(List<EvaluationSelectAnswer> answers) {
    List jsonList = List();
    answers.map((item) => jsonList.add(item.toJson())).toList();
    return jsonList;
  }

  @override
  Future<http.Response> request() {
    // TODO: implement request
    return fetchPost(body: jsonEncode(encodeToJson(answers)));
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}user/api/v1/patient/evaluation';
  }

  @override
  success(body) {
    // TODO: implement success
    return true;
  }
}

class GetEvaluationItemService extends BaseService<EvaluationItem> {
  final int answer;

  GetEvaluationItemService({this.answer});

  @override
  Future<Response> request() async {
    return fetchPost(body: json.encode({'answer': answer}));
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/evaluation/handArmFunciton';
  }

  @override
  EvaluationItem success(body) {
    return EvaluationItem.fromJson(body);
  }
}

class GetWelcomeService extends BaseService<String> {
  @override
  Future<http.Response> request() => fetchGet();

  @override
  setUrl() => baseUrl + 'connect/api/v1/app/welcome';

  @override
  String success(body) {
    return body;
  }
}
