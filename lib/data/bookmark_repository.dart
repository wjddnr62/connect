import 'package:connect/data/remote/bookmark/bookmark_add_service.dart';
import 'package:connect/data/remote/bookmark/bookmark_inquiry_list_service.dart';
import 'package:connect/data/remote/bookmark/bookmark_remove_service.dart';

class BookmarkRepository {
  static Future<dynamic> bookmarkAdd(String id) =>
      BookmarkAddService(id: id).start();

  static Future<dynamic> bookmarkRemove(String id) =>
      BookmarkRemoveService(id: id).start();

  static Future<dynamic> bookmarkInquiryList() =>
      BookmarkInquiryListService().start();
}
