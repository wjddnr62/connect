import 'package:connect/utils/logger/log.dart';

import '../connect_firebase.dart';

class EVentProfile {
  static const _tag = 'EVENT';

  static Future<void> startProfile() {
    Log.d(_tag, 'profile_start');
    return gAnalytics.logEvent(name: 'profile_start');
  }

  static Future<void> inputName(String name) {
    Log.d(_tag, 'profile_input_name');
    return gAnalytics.logEvent(name: 'profile_input_name');
  }

  static Future<void> inputBirthday(DateTime birthday) {
    Log.d(_tag, 'profile_input_birthday');
    return gAnalytics.logEvent(name: 'profile_input_birthday');
  }

  static Future<void> inputGender(String gender) {
    Log.d(_tag, 'profile_input_gender');
    return gAnalytics.logEvent(name: 'profile_input_gender');
  }

  static Future<void> inputResidence(String stateCode) {
    Log.d(_tag, 'profile_input_residence');
    return gAnalytics.logEvent(name: 'profile_input_residence');
  }

  static Future<void> inputDiagnosticName(String diagnostic) {
    Log.d(_tag, 'profile_input_diagnostic');
    return gAnalytics.logEvent(name: 'profile_input_diagnostic');
  }

  static Future<void> inputOnsetDate(String onsetDate) {
    Log.d(_tag, 'profile_input_onset_date');
    return gAnalytics.logEvent(name: 'profile_input_onset_date');
  }

  static Future<void> inputAffectedSide(String side) {
    Log.d(_tag, 'profile_input_affected_side');
    return gAnalytics.logEvent(name: 'profile_input_affected_side');
  }

  static Future<void> inputDominantHand(String side) {
    Log.d(_tag, 'profile_input_dominant_hand');
    return gAnalytics.logEvent(name: 'profile_input_dominant_hand');
  }

  static Future<void> completeProfile() {
    Log.d(_tag, 'profile_complete');
    return gAnalytics.logEvent(name: 'profile_complete');
  }
}
