import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/training_summary.dart';
import 'package:http/http.dart';
import 'package:http/src/response.dart';

class SummaryService extends BaseService {
  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'home/api/v1/training/summary';
  }

  @override
  success(body) {
    return TrainingSummary.fromJson(body);
  }
}
