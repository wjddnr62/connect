import 'package:connect/data/remote/rank/rank_get_data_me_service.dart';
import 'package:connect/data/remote/rank/rank_get_data_service.dart';

class RankRepository {
  static Future<dynamic> rankGetData(String date) =>
      RankGetDataService(date: date).start();

  static Future<dynamic> rankGetDataMe(String date) =>
      RankGetDataMeService(date: date).start();
 }
