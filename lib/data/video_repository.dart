import 'package:connect/data/remote/base_service.dart';
import 'package:connect/data/remote/video/video_archive_service.dart';
import 'package:connect/data/remote/video/video_bookmark_check_service.dart';
import 'package:connect/data/remote/video/video_bookmark_update_service.dart';
import 'package:connect/data/remote/video/video_view_count_increment_service.dart';
import 'package:connect/models/video_archive_queries.dart';

class VideoRepository {
  static VideoRepository _instance;

  static VideoRepository get instance {
    _instance ??= VideoRepository();
    return _instance;
  }

  Future<dynamic> loadArchives(
      {@required int page,
      @required VideoArchiveCategory category,
      @required VideoArchiveOrderBy order}) {
    assert(page != null);
    assert(category != null);
    assert(order != null);

    return VideoArchiveService(order: order, category: category, page: page)
        .start();
  }

  Future<dynamic> incrementViewCount({@required dynamic id}) {
    assert(id != null);
    return VideoViewCountIncrementService(id).start();
  }

  Future<dynamic> bookmarkCheck({@required dynamic id}) {
    assert(id != null);
    return VideoBookmarkCheckService(id).start();
  }

  Future<dynamic> bookmarkUpdate(
      {@required dynamic id, @required bool enable}) async {
    assert(id != null);
    assert(enable != null);
    return VideoBookmarkUpdateService(videoId: id, enable: enable).start();
  }
}
