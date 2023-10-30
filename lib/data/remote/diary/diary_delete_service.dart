import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class DiaryDeleteService extends BaseService {

  final String id;

  DiaryDeleteService({this.id});

  @override
  Future<Response> request() {
    // TODO: implement request
    return fetchDelete();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/diary/$id';
  }

  @override
  success(body) {
    // TODO: implement success
    return body;
  }

}