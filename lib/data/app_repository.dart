import 'package:connect/data/remote/app/on_review_service.dart';
import 'package:connect/data/remote/user/client_init_service.dart';
import 'package:connect/data/remote/user/update_fcm_service.dart';

import 'remote/app/should_update_service.dart';

class AppRepository {
  static bool isOnReview = false;

  static Future<dynamic> init() {
    return ClientInitService().start();
  }

  static Future<dynamic> updateFcm({final String uuid, final String fcmToken}) {
    return UpdateFcmService(uuid: uuid, fcmToken: fcmToken).start();
  }

  static Future<dynamic> shouldUpdateApp() {
    return ShouldUpdateService().start();
  }

  static onReview() async {
    var res = await GetOnReviewService().start();
    if (res is bool) {
      isOnReview = res;
    }
  }
}
