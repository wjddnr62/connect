import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/advice.dart';
import 'package:http/http.dart' as http;

/**
 * 치료사가 배정되었을 때 받는 Advice
 */
class TherapistAdviceService extends BaseService<StrokeCoachAdvice> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'therapist/api/v1/connect/advice';
  }

  @override
  StrokeCoachAdvice success(body) {
    return StrokeCoachAdvice.fromJson(body);
  }
}

/**
 * 치료사가 배정되지 않았을 때 내려오는 Advice
 */
class AdviceService extends BaseService<Advice> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/advice';
  }

  @override
  Advice success(body) {
    return Advice.fromJson(body);
  }
}
