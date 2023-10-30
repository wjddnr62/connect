import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/auth/token_refresh_service.dart';
import 'package:connect/models/auth.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/logger/log.dart';

class AuthRepository {
  static Future<dynamic> updateAccessToken() async {
    var res = await TokenRefreshService().start();

    if (res == null) {
      return ServiceError();
    }

    if (res is ServiceError) {
      return res;
    }

    if (res is Auth) {
      Log.d('AuthRepository', 'accessToken = ${res.accessToken}');
      await Future.wait([
        AppDao.setUserId(res.userId),
        AppDao.setRefreshToken(res.refreshToken),
        AppDao.setName(res.name),
        AppDao.setAccessToken(res.accessToken),
        AppDao.setEmail(res.email)
      ]);
    }

    return res;
  }
}
