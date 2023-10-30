import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class BookmarkAddService extends BaseService {
  final String id;

  BookmarkAddService({this.id});

  @override
  Future<Response> request() async {
    // TODO: implement request
    return await fetchPut();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/bookmark/$id';
  }

  @override
  success(body) {
    // TODO: implement success
    return body;
  }
}
