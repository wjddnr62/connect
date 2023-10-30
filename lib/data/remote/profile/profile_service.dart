// 12월 릴리즈 추가

import 'dart:io';

import 'package:connect/data/local/app_dao.dart';
import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';
import 'package:http/http.dart' as http;

class UpdateUserProfileService extends BaseService<bool> {
  final String name;
  final String birthday;
  final String gender;
  final String statusMessage;
  final String profileImageName;
  final String patientWishMessage;

  UpdateUserProfileService(
      {this.name,
      this.birthday,
      this.gender,
      this.statusMessage,
      this.profileImageName,
      this.patientWishMessage});

  @override
  Future<Response> request() async {
    Map<String, Object> data = {};
    if (name != null) {
      data.addAll({'name': name});
    }
    if (birthday != null && birthday != "") {
      data.addAll({'birthday': birthday});
    }
    if (gender != null && gender != "") {
      data.addAll({'gender': gender});
    }
    if (statusMessage != null) {
      data.addAll({'status_message': statusMessage});
    }
    if (profileImageName != null && profileImageName != "") {
      data.addAll({'profileImageName': profileImageName});
    }
    if (patientWishMessage != null && patientWishMessage != "") {
      data.addAll({'patient_wish_message': patientWishMessage});
    }
    return await fetchPut(body: jsonEncode(data));
  }

  @override
  setUrl() async {
    return baseUrl + 'user/api/v2/users/email/${await AppDao.email}';
  }

  @override
  bool success(body) {
    return body;
  }
}

class UpdateUserProfileImageService {
  File imageFile;

  UpdateUserProfileImageService({this.imageFile});

  Future<bool> start() async {
    var client = http.Client();
    Uri uri = Uri.parse(baseUrl + 'user/api/v2/users/image');

    try {
      http.MultipartRequest request = http.MultipartRequest('PUT', uri);
      request.files
          .add(await http.MultipartFile.fromPath('file', imageFile.path));
      String accessToken = await AppDao.accessToken;
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'serviceType': 'connect',
        'Content-Type': 'multipart/form-data',
        'OS-Type': Platform.isIOS ? 'IOS' : 'ANDROID'
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      Exception(e);
    } finally {
      client.close();
    }
    return false;
  }
}
