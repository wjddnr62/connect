import 'package:connect/utils/logger/log.dart';

import '../connect_firebase.dart';

class EventMission {
  static const _tag = 'EVENT';

  /// Start Severity Answer on First mission
  static startCheckSeverity() async {
    await gAnalytics.logEvent(name: 'first_mission_severity_start');
    Log.d(_tag, 'first_mission_severity_start');
  }

  /// Move to Mission Detail except first mission.
  static missionDetail({
    String missionType,
    String missionId,
    bool completed,
  }) async {
    await gAnalytics.logEvent(
      name: 'mission_detail',
      parameters: {
        'mission_type': missionType,
        'mission_id': missionId,
        'completed': completed,
      },
    );

    Log.d(_tag,
        'mission_detail : type = $missionType, id = $missionId, completed = $completed');
  }

  /// do mission
  static doMission({
    String missionType,
    String missionId,
  }) async {
    await gAnalytics.logEvent(
      name: 'mission_do',
      parameters: {
        'mission_type': missionType,
        'mission_id': missionId,
      },
    );

    Log.d(_tag, 'mission_do : type = $missionType, id = $missionId');
  }

  /// undo mission
  static undoMission({
    String missionType,
    String missionId,
  }) async {
    await gAnalytics.logEvent(
      name: 'mission_undo',
      parameters: {
        'mission_type': missionType,
        'mission_id': missionId,
      },
    );

    Log.d(_tag, 'mission_undo : type = $missionType, id = $missionId');
  }

  /// move to Notification List Page
  static notificationList() async {
    await gAnalytics.logEvent(name: 'notification_list');
    Log.d(_tag, 'notification_list');
  }

  static notificationPushReceive(String type) async {
    await gAnalytics.logEvent(
      name: 'notification_push_receive',
      parameters: {
        'type': type,
      },
    );
    Log.d(_tag, 'notification_push_receive');
  }

  static notificationPushShow(String type) async {
    await gAnalytics.logEvent(
      name: 'notification_push_show',
      parameters: {
        'type': type,
      },
    );
    Log.d(_tag, 'notification_push_show : type = $type');
  }

  static notificationPushClick(String type) async {
    await gAnalytics.logEvent(
      name: 'notification_push_click',
      parameters: {
        'type': type,
      },
    );
    Log.d(_tag, 'notification_push_click');
  }
}
