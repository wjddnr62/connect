import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class UpdateFcmService extends BaseService<bool> {
  final String uuid;
  final String fcmToken;

  UpdateFcmService({this.uuid, this.fcmToken});

  @override
  Future<Response> request() {
    debugPrint("update FcmToken : $fcmToken");

    return fetchPost(
      body: jsonEncode({
        'uuid': '$uuid',
        'fcm_token': '$fcmToken',
      }),
    );
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/client/firebase';
  }

  @override
  bool success(body) {
    return body;
  }
}
