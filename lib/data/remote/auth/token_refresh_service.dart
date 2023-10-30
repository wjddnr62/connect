import 'dart:convert';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/models/auth.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:http/http.dart' as http;

import '../../../connect_config.dart';

export 'dart:convert';

class TokenRefreshService {
  Future<dynamic> start() async {
    http.Response response;

    var refreshToken = await AppDao.refreshToken;
    try {
      Log.d('TokenRefreshService', 'start refresh accessToken');
      response = await http.post(
          baseUrl +
              'uaa/oauth/token?client_id=connect&response_type=code&grant_type=refresh_token&refresh_token=$refreshToken',
          headers: {'Content-Type': 'application/json;charset=UTF-8'});
    } catch (e) {
      return ServiceError();
    }

    if (response == null) {
      return ServiceError();
    }

    if (response.body == null) {
      return ServiceError();
    }

    Map<String, dynamic> body;
    try {
      body = json.decode(
          Utf8Decoder(allowMalformed: false).convert(response.bodyBytes));
    } catch (e) {
      if ((e is TypeError || e is FormatException) &&
          response.statusCode == 200) {
        Log.d('TokenRefreshService',
            'response.bodyBytes.toString() = ${response.bodyBytes.toString()}');
        Log.d('TokenRefreshService',
            'String.fromCharCodes(response.bodyBytes) = ${String.fromCharCodes(response.bodyBytes)}');
        return _success(String.fromCharCodes(response.bodyBytes));
      } else {
        return ServiceError();
      }
    }

    if (response.statusCode == 200) {
      return _success(body);
    } else {
      return ServiceError.fromJson(body);
    }
  }

  Auth _success(dynamic body) {
    return Auth.fromJson(body);
  }
}
