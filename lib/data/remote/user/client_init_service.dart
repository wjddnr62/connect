import 'package:connect/connect_config.dart' as config;
import 'package:connect/data/remote/base_service.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:http/http.dart' as http;

import '../../../connect_firebase.dart';

class ClientInitService extends BaseService<bool> {
  ClientInitService() : super(withAccessToken: false);

  @override
  Future<http.Response> request() async {
    var clientInfo = ClientInfo(
      uuid: config.gUuid,
      adId: config.gAdId,
      fcmToken: gFcmId,
      appVersion: config.gVersion,
      gmtOffset: DateTime.now().timeZoneOffset.inMinutes,
      serviceType: 'connect',
    );

    var res;
    try {
      res = await fetchPost(body: jsonEncode(clientInfo.toJson()));
    } catch (e) {
      Log.d('ClientInitService', '$e');
    }

    return res;
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/client/init';
  }

  @override
  bool success(dynamic body) {
    return body;
  }
}

class ClientInfo {
  final String uuid;
  final String adId;
  final String fcmToken;
  final String appVersion;
  final int gmtOffset;
  final String serviceType;

  ClientInfo({
    this.uuid,
    this.adId,
    this.fcmToken,
    this.appVersion,
    this.gmtOffset,
    this.serviceType,
  });

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'app_version': appVersion,
        'ad_id': adId,
        'fcm_token': fcmToken,
        'gmt_offset': gmtOffset,
        'service_type': serviceType,
      };
}
