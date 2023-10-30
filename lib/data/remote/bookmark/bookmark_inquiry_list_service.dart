import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/bookmark.dart';
import 'package:http/src/response.dart';

class BookmarkInquiryListService extends BaseService {
  @override
  Future<Response> request() async {
    // TODO: implement request
    return await fetchGet();
  }

  @override
  setUrl() {
    // TODO: implement setUrl
    return '${baseUrl}connect/api/v1/bookmark/list';
  }

  @override
  success(body) {
    // TODO: implement success
    Bookmark bookmark = Bookmark.fromJson(body);
    return bookmark;
    // if ((bookmark.readings.isNotEmpty && bookmark.readings.length != 0) &&
    //     (bookmark.exercises.isNotEmpty && bookmark.exercises.length != 0)) {
    //   return bookmark;
    // } else {
    //   return null;
    // }
  }
}
