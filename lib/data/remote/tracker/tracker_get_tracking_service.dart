import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/tracking_data.dart';
import 'package:http/src/response.dart';

class TrackerGetTrackingService extends BaseService<TrackingData> {
  final String date;

  TrackerGetTrackingService({this.date});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/$date';
  }

  @override
  TrackingData success(body) {
    // TODO: implement success
    return TrackingData.fromJson(body);
  }
}
