import 'package:connect/data/remote/share/share_service.dart';

class ShareRepository {
  static Future<dynamic> getShareContent() => GetShareContentService().start();
}
