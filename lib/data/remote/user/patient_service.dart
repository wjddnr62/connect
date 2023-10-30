import 'package:connect/models/patient.dart';
import 'package:http/http.dart' as http;

import '../base_service.dart';

class GetPatientService extends BaseService<Patient> {
  final userId;

  GetPatientService({this.userId});

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/patients/$userId';
  }

  @override
  Patient success(body) {
    return Patient.fromJson(body);
  }
}
