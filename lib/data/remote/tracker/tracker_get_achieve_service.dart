import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class TrackerGetAchieveService extends BaseService {
  final String date;

  TrackerGetAchieveService({this.date});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/achieve/$date';
  }

  @override
  success(body) {
    // TODO: implement success
    if (body['achieveDates'].length != 0) {
      return body;
    } else {
      return null;
    }
  }
}
