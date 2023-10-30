import 'package:connect/models/profile.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../connect_config.dart';
import '../connect_firebase.dart';

class UserProperties {
  static const _tag = 'USER_PROPERTIES';

  /// app uuid
  static Future<void> userId() {
    Log.d(_tag, 'userId = $gUuid');
    return gAnalytics.setUserId(gUuid);
  }

  /// dev-debug, dev-release, stage-debug, stage-release, prod-debug, prod-release
  static Future<void> productType() {
    Log.d(_tag, 'product_type = $gProduction');
    return gAnalytics.setUserProperty(name: 'product_type', value: gProduction);
  }

  /// email id
  static Future<void> userEmail(String email) {
    Log.d(_tag, 'user_email = $email');
    return Future.wait([
      gAnalytics.setUserProperty(name: 'user_email', value: email),
      Crashlytics.instance.setUserEmail(email)
    ]);
  }

  /// Patient, Caregiver
  static Future<void> userType(String userType) {
    Log.d(_tag, 'user_type = $userType');
    return gAnalytics.setUserProperty(name: 'user_type', value: userType);
  }

  /// MALE, FEMALE, OTHER
  static Future<void> userGender(String gender) {
    Log.d(_tag, 'user_gender = $gender');
    return gAnalytics.setUserProperty(name: 'user_gender', value: gender);
  }

  /// Birth, Caregiver
  static Future<void> userBirthYear(String year) {
    Log.d(_tag, 'user_birth_year = $year');
    return gAnalytics.setUserProperty(name: 'user_birth_year', value: year);
  }

  /// US State
  static Future<void> userResidence(String stateCode) {
    Log.d(_tag, 'user_residence = $stateCode');
    return gAnalytics.setUserProperty(name: 'user_residence', value: stateCode);
  }

  static Future<void> userProperties(Profile profile) {
    return Future.wait([
      userEmail(profile.email),
      userType(profile.type),
      userGender(profile.gender),
      userBirthYear('${profile.birthday.year}'),
      userResidence(profile.usStateCode)
    ]);
  }
}
