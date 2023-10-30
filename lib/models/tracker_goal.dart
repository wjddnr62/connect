class TrackerGoal {
  final String id;
  final int userId;
  final String yearMonth;
  final GoalScale goalScale;
  final GoalScale goalSpecificScale;
  final int goalStep;
  final int goalUpper;
  final int goalLower;
  final int goalWhole;
  final int goalSocial;

  TrackerGoal(
      {this.id,
      this.userId,
      this.yearMonth,
      this.goalScale,
      this.goalSpecificScale,
      this.goalStep,
      this.goalUpper,
      this.goalLower,
      this.goalWhole,
      this.goalSocial});

  factory TrackerGoal.fromJson(Map<String, dynamic> data) {
    return TrackerGoal(
        id: data['id'],
        userId: data['user_id'],
        yearMonth: data['year_month'],
        goalScale: data['goal_setting_scale'] != null
            ? GoalScale.fromJson(data['goal_setting_scale'])
            : null,
        goalSpecificScale: data['goal_setting_scale2'] != null
            ? GoalScale.fromJson(data['goal_setting_scale2'])
            : null,
        goalStep: data['goal_step'],
        goalUpper: data['goal_upper'],
        goalLower: data['goal_lower'],
        goalWhole: data['goal_whole'],
        goalSocial: data['goal_social']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['year_month'] = this.yearMonth;
    data['goal_setting_scale'] = this.goalScale.toJson();
    data['goal_setting_scale2'] = this.goalSpecificScale.toJson();
    data['goal_step'] = this.goalStep;
    data['goal_upper'] = this.goalUpper;
    data['goal_lower'] = this.goalLower;
    data['goal_whole'] = this.goalWhole;
    data['goal_social'] = this.goalSocial;
    return data;
  }
}

class GoalScale {
  final int seq;
  final String goalDescription;

  GoalScale({this.seq, this.goalDescription});

  factory GoalScale.fromJson(Map<String, dynamic> data) {
    return GoalScale(
        seq: data['seq'], goalDescription: data['goal_description']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['seq'] = this.seq;
    data['goal_description'] = this.goalDescription;
    return data;
  }
}

