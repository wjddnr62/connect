import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/videocall_accessinfo.dart';
import 'package:http/src/response.dart' as http;

import '../../../connect_config.dart';

class VideoCallJoinService extends BaseService<VideoCallAccessInfo> {
  final String scheduleId;

  VideoCallJoinService(this.scheduleId);

  @override
  setUrl() {
    return baseUrl +
        'therapist/api/v1/connect/schedule/$scheduleId/joinvideocall?zone_offset=${DateTime.now().timeZoneOffset.inMinutes}';
  }

  @override
  VideoCallAccessInfo success(body) {
    return VideoCallAccessInfo.fromJson(body);
  }

  @override
  Future<http.Response> request() async {
    return fetchGet();
  }
}
