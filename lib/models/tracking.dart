class Tracking {
  final int step;
  final int upper;
  final int lower;
  final int whole;
  final int social;

  Tracking({this.step, this.upper, this.lower, this.whole, this.social});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['step'] = this.step ?? 0;
    data['upper'] = this.upper ?? 0;
    data['lower'] = this.lower ?? 0;
    data['whole'] = this.whole ?? 0;
    data['social'] = this.social ?? 0;

    return data;
  }
}

class GoalTracking {
  final int goalStep;
  final int goalUpper;
  final int goalLower;
  final int goalWhole;
  final int goalSocial;

  GoalTracking(
      {this.goalStep,
      this.goalUpper,
      this.goalLower,
      this.goalWhole,
      this.goalSocial});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['goal_step'] = this.goalStep;
    data['goal_upper'] = this.goalUpper;
    data['goal_lower'] = this.goalLower;
    data['goal_whole'] = this.goalWhole;
    data['goal_social'] = this.goalSocial;

    return data;
  }
}
