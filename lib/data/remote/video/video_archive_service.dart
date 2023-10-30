import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/video_archive_list.dart';
import 'package:connect/models/video_archive_queries.dart';
import 'package:http/http.dart';

class VideoArchiveService extends BaseService {
  final VideoArchiveOrderBy order;
  final VideoArchiveCategory category;
  final int page;

  VideoArchiveService({this.order, this.category, this.page})
      : assert(order != null),
        assert(category != null),
        assert(page != null);

  @override
  Future<Response> request() {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl +
        'connect/api/v1/video/archives' +
        '?page=$page' +
        '&size=15' +
        '&category=${describeEnum(category).toUpperCase()}' +
        '&orderby=${describeEnum(order).toUpperCase()}';
  }

  @override
  success(body) {
    return VideoArchiveList.fromJson(body);
  }
}
