import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart';

class VideoBookmarkUpdateService extends BaseService {
  final String videoId;
  final bool enable;

  VideoBookmarkUpdateService({this.videoId, this.enable})
      : assert(videoId != null),
        assert(enable != null);

  @override
  Future<Response> request() {
    return fetchPut(body: jsonEncode({'is_bookmarked': enable}));
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/video/bookmark/$videoId';
  }

  @override
  success(body) {
    return true;
  }
}
