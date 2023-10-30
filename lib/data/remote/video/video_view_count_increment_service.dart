import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart';

class VideoViewCountIncrementService extends BaseService {
  final dynamic videoId;

  VideoViewCountIncrementService(this.videoId);

  @override
  Future<Response> request() {
    return fetchPost();
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v1/video/view/$videoId';
  }

  @override
  success(body) {
    return true;
  }
}
