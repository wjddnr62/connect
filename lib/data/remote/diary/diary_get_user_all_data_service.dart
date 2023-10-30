import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/diary.dart';
import 'package:connect/resources/app_images.dart';
import 'package:http/src/response.dart';

class DiaryGetUserAllDataService extends BaseService<List<Diary>> {
  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/diary/user/me';
  }

  @override
  List<Diary> success(body) {
    // TODO: implement success
    if (body != null) {
      List<Diary> diary = List();
      for (int i = 0; i < body.length; i++) {
        diary.add(Diary.fromJson(body[i]));
      }
      return diary;
    } else {
      return List();
    }
  }
}
