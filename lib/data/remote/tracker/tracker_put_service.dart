import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/tracking.dart';
import 'package:http/src/response.dart';

class TrackerPutService extends BaseService {

  final Tracking tracking;
  final String dateTime;

  TrackerPutService({this.tracking, this.dateTime});

  @override
  Future<Response> request() {
    // TODO: implement request
    if (tracking.step != null) {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['step'] = tracking.step ?? 0;
      return fetchPut(body: jsonEncode(data));
    } else {
      final Map<String, dynamic> data = new Map<String, dynamic>();
      data['upper'] = tracking.upper ?? 0;
      data['lower'] = tracking.lower ?? 0;
      data['whole'] = tracking.whole ?? 0;
      data['social'] = tracking.social ?? 0;
      return fetchPut(body: jsonEncode(data));
    }
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/$dateTime';
  }

  @override
  success(body) {
    // TODO: implement success
    return body;
  }

}