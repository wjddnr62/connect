import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/clinic.dart';
import 'package:http/src/response.dart';

class GetClinicListService extends BaseService<List<Clinic>> {
  @override
  Future<Response> request() => fetchGet();

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/clinic/m/list';
  }

  @override
  List<Clinic> success(body) {
    var ret =
        (body as List<dynamic>).map((data) => Clinic.fromJson(data)).toList();

    return ret;
  }
}

class SaveClinicService extends BaseService<bool> {
  final Clinic clinic;

  SaveClinicService(this.clinic);

  @override
  Future<Response> request() => fetchPost();

  @override
  setUrl() => baseUrl + 'user/api/v1/clinic/patient/req/${clinic.id}';

  @override
  bool success(body) {
    return body;
  }
}
