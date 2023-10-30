import 'package:connect/data/remote/goal/goal_data_get_service.dart';
import 'package:connect/data/remote/goal/goal_user_data_get_service.dart';
import 'package:connect/data/remote/goal/goal_user_data_save_service.dart';

class GoalRepository {
  static Future<dynamic> getGoalData() => GoalDataGetService().start();

  static Future<dynamic> getGoalUserData() => GoalUserDataGetService().start();

  static Future<dynamic> putGoalUserData(List<String> serveys) =>
      GoalUserDataSaveService(serveys: serveys).start();
}
