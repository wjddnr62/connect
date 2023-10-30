import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/sample.dart';
import 'package:http/src/response.dart';

class TrackerGetSampleService extends BaseService<Sample> {
  final int scaleInfo;
  final int scaleDetailInfo;

  TrackerGetSampleService({this.scaleInfo, this.scaleDetailInfo});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/tracking/settingList/$scaleInfo/$scaleDetailInfo';
  }

  @override
  Sample success(body) {
    // TODO: implement success
    return Sample.fromJson(body);
  }
}
