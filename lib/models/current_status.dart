class CurrentStatus {
  final String message;
  final String imageUrl;
  final int subscriptionPeriod;
  final double practiceTimes;
  final int missionAchievement;
  final double activityAchievement;
  final int diary;

  CurrentStatus(
      {this.message,
      this.imageUrl,
      this.subscriptionPeriod,
      this.practiceTimes,
      this.missionAchievement,
      this.activityAchievement,
      this.diary});

  factory CurrentStatus.fromJson(Map<String, dynamic> json) {
    return CurrentStatus(
        message: json['message'],
        imageUrl: json['image_url'],
        subscriptionPeriod: json['subscription_period'],
        practiceTimes: json['practice_times'],
        missionAchievement: json['mission_achievement'],
        activityAchievement: json['activity_achievement'],
        diary: json['diary']);
  }
}
