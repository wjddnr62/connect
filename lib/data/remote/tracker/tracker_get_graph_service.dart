import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/tracking_graph.dart';
import 'package:http/src/response.dart';

class TrackerGetGraphService extends BaseService {
  final String date;

  TrackerGetGraphService({this.date});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/tracking/graph/$date';
  }

  @override
  success(body) {
    // TODO: implement success
    return TrackingGraph.fromJson(body);
  }
}
