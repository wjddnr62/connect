import 'dart:io';

import 'package:connect/data/remote/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:connect/data/local/app_dao.dart';

class DiaryUserImageUploadService {
  File imageFile;

  DiaryUserImageUploadService({this.imageFile});

  Future<String> start() async {
    String url;
    var client = http.Client();
    Uri uri = Uri.parse(baseUrl + 'connect/api/v1/diary/image');

    try {
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
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

      await response.stream.bytesToString().then((value) {
        if (response.statusCode == 200) {
          url = value;
        } else {
          url = "";
        }
      });
    } catch (e) {
      Exception(e);
    } finally {
      client.close();
    }
    return url;
  }
}
