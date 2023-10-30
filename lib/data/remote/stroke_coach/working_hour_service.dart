import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/working_hours.dart';
import 'package:http/src/response.dart' as http;

class WorkingHourService extends BaseService<WorkingHours> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return "${baseUrl}therapist/api/v1/connect/workinghours";
  }

  @override
  WorkingHours success(body) {
    return WorkingHours.fromJson(body);
  }
}
