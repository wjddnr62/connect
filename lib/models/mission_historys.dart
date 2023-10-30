class MissionHistory {
  final DateTime date;
  final int missionCount;
  final int completedCount;

  MissionHistory({this.date, this.missionCount, this.completedCount});

  factory MissionHistory.fromJson(Map<String, dynamic> json) {
    return MissionHistory(
        date: json['date'],
        missionCount: json['mission_count'],
        completedCount: json['completed_count']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['date'] = this.date;
    data['mission_count'] = this.missionCount;
    data['completed_count'] = this.completedCount;

    return data;

//    return {
//      'date': date.toString(),
//      'mission_count': missionCount,
//      'completed_count': completedCount
//    };
  }
}

class PerformHistory {
  final String date;
  final int missionCount;
  final int completedCount;

  PerformHistory({this.date, this.missionCount, this.completedCount});

  factory PerformHistory.fromJson(Map<String, dynamic> json) {
    return PerformHistory(
        date: json['date'],
        missionCount: json['mission_count'],
        completedCount: json['completed_count']);
  }
}
