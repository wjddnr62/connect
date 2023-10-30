import 'package:connect/data/remote/auth/token_refresh_service.dart';

class PushNotification {
  Map<String, dynamic> json;

  String get contents => json['contents'] ?? "";

  String get scheduleId => json['schedule_id'] ?? "";

  String get title => json['title'] ?? "";

  final String type;
  final String historyId;

  PushNotification({this.json, this.historyId, this.type});

  factory PushNotification.fromJson(Map<String, dynamic> data) {
    final contentMap = jsonDecode(data['json']);
    return PushNotification(
        json: contentMap, historyId: data['history_id'], type: data['type']);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {'json': json},
      'type': type,
      'historyId': historyId
    };
  }

  @override
  String toString() {
    return 'PushNotification{json: $json, type: $type, historyId: $historyId}';
  }
}

class NotificationType {
  static const connect_mission_advice_daily = 'advice-daily';
  static const connect_mission_current_status_daily = 'current-status-daily';
  static const connect_mission_arrived_daily =
      'therapist-session-created'; //'mission-daily';
  static const connect_advice_msg_arrive = "connect_advice_msg_arrive";
  static const portal_patient_assign = "portal_patient_assign";
  static const mission_post_daily= "mission-post-daily";

  static const connect_share = "connect-share";

  static const sendbird_messasing = "sendbird_messasing";

  static const connect_recommend_diary = "connect-recommend-diary";
}
