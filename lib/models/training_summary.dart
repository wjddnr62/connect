class TrainingSummary {
  final bool isHomeUser;
  final int totalStarCount;
  final int todayPlayedTime;
  final int todayStarCount;
  final int last7DaysPlayedTime;
  final int last7DaysStarCount;

  TrainingSummary(
      {this.isHomeUser,
      this.totalStarCount,
      this.todayPlayedTime,
      this.todayStarCount,
      this.last7DaysStarCount,
      this.last7DaysPlayedTime});

  factory TrainingSummary.fromJson(Map<String, dynamic> json) {
    return TrainingSummary(
      isHomeUser: json['isHomeUser'],
      totalStarCount: json['totalStarCount'],
      todayStarCount: json['todayStarCount'],
      todayPlayedTime: json['todayPlayedTime'],
      last7DaysStarCount: json['last7DaysStarCount'],
      last7DaysPlayedTime: json['last7DaysPlayedTime'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isHomeUser'] = isHomeUser;
    data['totalStarCount'] = todayStarCount;
    data['todayPlayedTime'] = todayPlayedTime;
    data['last7DaysStarCount'] = last7DaysStarCount;
    data['last7DaysPlayedTime'] = last7DaysPlayedTime;
    return data;
  }
}
