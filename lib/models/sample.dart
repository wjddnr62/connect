class Sample {
  final int goalStep;
  final int goalUpper;
  final int goalLower;
  final int goalWhole;
  final int goalSocial;

  Sample(
      {this.goalStep,
      this.goalUpper,
      this.goalLower,
      this.goalWhole,
      this.goalSocial});

  factory Sample.fromJson(Map<String, dynamic> json) {
    return Sample(
        goalStep: json['goal_step'],
        goalUpper: json['goal_upper'],
        goalLower: json['goal_lower'],
        goalWhole: json['goal_whole'],
        goalSocial: json['goal_social']);
  }
}
