import 'package:connect/models/tracker_goal.dart';
import 'package:connect/utils/extensions.dart';

class TrackingData {
  final String id;
  final int userId;
  final DateTime date;
  final GoalInfo goalInfo;
  final int step;
  final int upper;
  final int lower;
  final int whole;
  final int social;
  final double activityAchievement;
  final bool isSave;

  TrackingData(
      {this.id,
      this.userId,
      this.date,
      this.goalInfo,
      this.step,
      this.upper,
      this.lower,
      this.whole,
      this.social,
      this.activityAchievement,
      this.isSave});

  factory TrackingData.fromJson(Map<String, dynamic> data) {
    return TrackingData(
        id: data['id'],
        userId: data['user_id'],
        date: data['date'].toString().toDateTime(),
        goalInfo: data['goal_info'] != null
            ? GoalInfo.fromJson(data['goal_info'])
            : null,
        step: data['step'],
        upper: data['upper'],
        lower: data['lower'],
        whole: data['whole'],
        social: data['social'],
        activityAchievement: data['activity_achievement'],
        isSave: data['is_save']);
  }
}

class GoalInfo {
  final String id;
  final int userId;
  final String yearMonth;
  final GoalScale goalSettingScale;
  final GoalScale goalSettingScale2;
  final int goalStep;
  final int goalUpper;
  final int goalLower;
  final int goalWhole;
  final int goalSocial;

  GoalInfo(
      {this.id,
      this.userId,
      this.yearMonth,
      this.goalSettingScale,
      this.goalSettingScale2,
      this.goalStep,
      this.goalUpper,
      this.goalLower,
      this.goalWhole,
      this.goalSocial});

  factory GoalInfo.fromJson(Map<String, dynamic> data) {
    return GoalInfo(
        id: data['id'],
        userId: data['user_id'],
        yearMonth: data['year_month'],
        goalSettingScale: data['goal_setting_scale'] != null
            ? GoalScale.fromJson(data['goal_setting_scale'])
            : null,
        goalSettingScale2: data['goal_setting_scale2'] != null
            ? GoalScale.fromJson(data['goal_setting_scale2'])
            : null,
        goalStep: data['goal_step'],
        goalUpper: data['goal_upper'],
        goalLower: data['goal_lower'],
        goalWhole: data['goal_whole'],
        goalSocial: data['goal_social']);
  }
}
