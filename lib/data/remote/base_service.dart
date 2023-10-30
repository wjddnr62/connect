import 'dart:convert';
import 'dart:io';

import 'package:connect/connect_app.dart';
import 'package:connect/connect_config.dart';
import 'package:connect/data/auth_repository.dart';
import 'package:connect/data/local/app_dao.dart';
import 'package:connect/models/auth.dart';
import 'package:connect/models/error.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/toast/toast.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../user_repository.dart';

export 'dart:convert';

export 'package:connect/connect_config.dart';
export 'package:flutter/foundation.dart';

const MAX_RETRY_COUNT = 3;

abstract class BaseService<T> {
  int _retryCount = 0;
  String _url;
  final bool withAccessToken;
  final bool jsonContentType;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
  };

  BaseService({this.withAccessToken = true, this.jsonContentType = true});

  dynamic setUrl();

  String get url => _url;

  dynamic _contentTypes() {
    return jsonContentType
        ? {'Content-Type': 'application/json'}
        : {'Content-Type': 'application/x-www-form-urlencoded'};
  }

  dynamic _extraHeaders() async {
    String accessToken = await AppDao.accessToken;
    return withAccessToken
        ? {'Authorization': 'Bearer $accessToken', 'serviceType': 'connect'}
        : {'serviceType': 'connect'};
  }

  void setContentType(String contentType){
    _headers['Content-Type'] = contentType;
  }

  Future<dynamic> start() async {
    _url = await setUrl();
    var extra = await _extraHeaders();
    if (extra != null && extra is Map<String, String>) {
      _headers.addAll(extra);
    }
    _headers.addAll(_contentTypes());

    return await _start();
  }

  Future<dynamic> _start() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    http.Response response;
    try {
      response = await request();
      Log.d('BaseService', 'request headers ${response?.request?.headers}');
      Log.d('BaseService', 'request url ${response?.request?.url}');
      Log.d('BaseService', 'request method ${response?.request?.method}');
      if (!response?.request?.url.toString().contains("duration") && (prefs.getBool("log") ?? false))
        showToast(response?.request?.url.toString(), custom: false);
    } catch (e, s) {
      return ServiceError(code: '$e', message: '$s');
    }

    if (response == null) {
      return ServiceError(code: 'null_response', message: 'response is null');
    }

    if (response.body == null) {
      return ServiceError(
          code: 'null_response_body', message: 'body of response is null');
    }

    var body;
    try {
      if (response.bodyBytes?.length == 0) {
      } else {
        body = json.decode(
            Utf8Decoder(allowMalformed: false).convert(response.bodyBytes));
      }
    } catch (e, s) {
      Log.d('BaseService', '$e\n$s');
      body = (String.fromCharCodes(response.bodyBytes));
    }

    Log.d('BaseService', 'status code : ${response.statusCode}');
    Log.d('BaseService',
        'body : ' + (isDebug ? _simpleBody(body.toString()) : body.toString()));
    if (response.statusCode == 200 || response.statusCode == 204) {
      return success(body);
    } else {
      /// expired token
      if (response.statusCode == 401 && body['code'] == 'token.expired') {
        /// update token
        _retryCount++;
        if (_retryCount < MAX_RETRY_COUNT) {
          var auth = await AuthRepository.updateAccessToken();

          if (auth is ServiceError) {
            await UserRepository.logout();
            return ServiceError.fromJson(body);
          }

          if (auth is Auth) {
            _headers['Authorization'] = 'Bearer ${auth.accessToken}';
          }

          /// retry
          return await _start();
        }
      }
    }
    try {
      return ServiceError.fromJson(body);
    } catch (e, s) {
      Log.d('BaseService', '$e\n$s');
      return ServiceError(spec: body);
    }
  }

  Future<http.Response> request();

  T success(dynamic body);

  Future<http.Response> fetchGet() async {
    debugPrint('request url : $url');
    debugPrint('request header : $_headers');
    return await http.get(url, headers: _headers);
  }

  Future<http.Response> fetchPut({
    dynamic body,
    Encoding encoding,
  }) async {
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');
    return await http.put(url,
        headers: _headers, body: body, encoding: encoding);
  }

  Future<http.Response> fetchPost({
    dynamic body,
  }) async {
    debugPrint('request url : $url');
    debugPrint('request body : $body');
    debugPrint('request header : $_headers');

    return await http.post(url, headers: _headers, body: body);
  }

  Future<http.Response> fetchDelete() async {
    debugPrint('request url : $url');
    debugPrint('request header : $_headers');
    return await http.delete(url, headers: _headers);
  }

  _simpleBody(String body) {
    if (body.length > 1000) {
      body = body.substring(0, 1000);
      body += "\n................";
    }
    return body;
  }
}
