class EventCommon {
  static const OPEN_APP = 'common_open_app';
  static const OPEN_APP_STORE = 'common_open_appstore';
}

class EventPermission {
  static const PERMISSION_NOTIFICATION_SHOW_GUIDE =
      'permission_notification_show_guide';
  static const PERMISSION_NOTIFICATION_REQUEST =
      'permission_notification_request';
}

class EventSign {
  static const String SIGNUP_START = 'signup_start';
  static const String SIGNUP_VERIFIED_EMAIL = 'signup_verified_email';
  static const String SIGNUP_AGREE_TERMS = 'signup_agree_terms';
  static const String SIGNUP_CREATE_PASSWORD = 'signup_create_password';
  static const String SIGNUP_CONFIRM_PASSWORD = 'signup_confirm_password';
  static const String SIGNUP_COMPLETE = 'signup_complete';

  static const LOGIN_START = 'login_start';
  static const LOGIN_INPUT_PASSWORD = 'login_input_password';
  static const LOGIN_COMPLETE = 'login_complete';

  static const LOGOUT = "logout";
}

class EventProfile {
  static const String PROFILE_START = "profile_start";
  static const String PROFILE_INPUT_NAME = "profile_input_name";
  static const String PROFILE_INPUT_BIRTHDAY = "profile_input_birthday";
  static const String PROFILE_INPUT_GENDER = "profile_input_gender";
  static const String PROFILE_INPUT_RESIDENCE = "profile_input_residence";
  static const String PROFILE_INPUT_DIAGNOSTIC_NAME =
      "profile_input_diagnostic_name";
  static const String PROFILE_INPUT_ONSET_DATE = "profile_input_onset_date";
  static const String PROFILE_INPUT_AFFECTED_SIDE =
      "profile_input_affected_side";
  static const String PROFILE_INPUT_DOMINANT_HAND =
      "profile_input_dominant_hand";
  static const String PROFILE_COMPLETE = "profile_complete";
}

class EventMission {
  static const String MISSION_START_ACTIVITY = "mission_start_activity";
  static const String MISSION_COMPLETE_ACTIVITY = "mission_complete_activity";
  static const String MISSION_UNDO_ACTIVITY = "mission_undo_activity";

  static const String MISSION_START_READING = "mission_start_reading";
  static const String MISSION_COMPLETE_READING = "mission_complete_reading";
  static const String MISSION_UNDO_READING = "mission_undo_reading";

  static const String MISSION_START_BASIC_EXERCISE =
      "mission_start_basic_exercise";
  static const String MISSION_COMPLETE_BASIC_EXERCISE =
      "mission_complete_basic_exercise";
  static const String MISSION_UNDO_BASIC_EXERCISE =
      "mission_undo_basic_exercise";

  static const String MISSION_START_VIDEO = "mission_start_video";
  static const String MISSION_COMPLETE_VIDEO = "mission_complete_video";
  static const String MISSION_UNDO_VIDEO = "mission_undo_video";
}

class EventEvaluation {
  static const String EVALUATION_START = "evaluation_start";
  static const String EVALUATION_COMPLETE = "evaluation_complete";
}
