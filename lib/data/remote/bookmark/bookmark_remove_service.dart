import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class BookmarkRemoveService extends BaseService {
  final String id;

  BookmarkRemoveService({this.id});

  @override
  Future<Response> request() async {
    // TODO: implement request
    return await fetchDelete();
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
