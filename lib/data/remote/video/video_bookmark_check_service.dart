import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart';

class VideoBookmarkCheckService extends BaseService {
  final String videoId;

  VideoBookmarkCheckService(this.videoId) : assert(videoId != null);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/video/bookmark/$videoId';
  }

  @override
  success(body) {
    return body['is_bookmarked'];
  }
}
