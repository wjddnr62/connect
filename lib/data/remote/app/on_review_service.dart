import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class GetOnReviewService extends BaseService<bool> {
  GetOnReviewService() : super(withAccessToken: false);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return 'https://data.rapaelrehab.com/connect/status.json';
  }

  @override
  bool success(dynamic body) {
    if (body is Map<String, dynamic>) {
      bool onReview = body.containsKey('on-review') ? body['on-review'] : false;
      bool sameVersion =
          body.containsKey('version') ? body['version'] == gVersion : false;

      return onReview && sameVersion;
    }

    return false;
  }
}
