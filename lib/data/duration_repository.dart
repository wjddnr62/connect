import 'package:connect/data/remote/duration/duration_regist_service.dart';
import 'package:connect/data/remote/duration/duration_update_service.dart';

class DurationRepository {
  static Future<dynamic> durationRegist(String date) =>
      DurationRegistService(date: date).start();

  static Future<dynamic> durationUpdate(String date) =>
      DurationUpdateService(date: date).start();
}
