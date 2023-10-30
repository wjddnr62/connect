import 'package:sembast/sembast.dart';
import 'package:unique_ids/unique_ids.dart';

import 'app_database.dart';

/// app 정보에 접근하는 DAO
/// app 정보
/// - uuid : 앱 인스턴스들의 고유 값이다.
///

class AppDao {
  static Future setUuid(String id) async {
    await _put(key: 'uuid', value: id);
  }

  static Future<String> get uuid async {
    String id = await _get(key: 'uuid') as String;
    if (id == null) {
      id = await UuIdGenerator.generateUuid();
      await AppDao.setUuid(id);
    }

    return id;
  }

  static Future setAdId(String id) async {
    await _put(key: 'adId', value: id);
  }

  static Future get adId async {
    return await _get(key: 'adId') as String;
  }

  static Future setAccessToken(String token) async {
    await _put(key: 'accessToken', value: token);
  }

  static Future<String> get accessToken async {
    return await _get(key: 'accessToken') as String;
  }

  static Future setRefreshToken(String token) async {
    await _put(key: 'refreshToken', value: token);
  }

  static Future<String> get refreshToken async {
    return await _get(key: 'refreshToken') as String;
  }

  static Future setHaveBeenConnected(bool success) async {
    await _put(key: 'haveBeenConnected', value: success);
  }

  static Future<bool> get haveBeenConnected async {
    bool result = await _get(key: 'haveBeenConnected') as bool;
    return result ??= false;
  }

  /// FIRST MISSION STEP
  static Future setUpdatedProfile(bool success) async {
    await _put(key: 'updatedProfile', value: success);
  }

  static Future<bool> get updatedProfile async {
    bool result = await _get(key: 'updatedProfile') as bool;
    return result ??= false;
  }

  static Future setWaitingEmailVerification(bool success) async {
    await _put(key: 'waitingEmailVerification', value: success);
  }

  static Future<bool> get waitingEmailVerification async {
    bool result = await _get(key: 'waitingEmailVerification') as bool;
    return result ??= false;
  }

  static Future setEmail(String email) async {
    await _put(key: 'email', value: email);
  }

  static Future<String> get email async {
    return await _get(key: 'email') as String;
  }

  static Future setName(String nickname) async {
    await _put(key: 'nickname', value: nickname ?? "");
  }

  static Future<String> get nickname async {
    return await _get(key: 'nickname') as String;
  }

  static Future setMarketPlaceName(String marketPlace) async {
    await _put(key: 'marketplaceName', value: marketPlace);
  }

  static Future<String> get marketPlaceName async {
    return await _get(key: 'marketplaceName') as String;
  }

  static Future setMarketPlace(String marketPlace) async {
    await _put(key: 'marketplace', value: marketPlace);
  }

  static Future<String> get marketPlace async {
    return await _get(key: 'marketplace') as String;
  }

  static Future setUserId(int userId) async {
    await _put(key: 'userId', value: userId);
  }

  static Future<int> get userId async {
    return await _get(key: 'userId') as int;
  }

  static Future setUserType(String type) async {
    await _put(key: "userType", value: type);
  }

  static Future<String> get userType async {
    return await _get(key: "userType") as String;
  }

  static Future<String> get profileImage async =>
      await _get(key: 'profileImage') as String;

  static Future<String> setProfileImage(String image) async =>
      await _put(key: 'profileImage', value: image);

  static Future<String> get profileImageName async =>
      await _get(key: 'profileImageName') as String;

  static Future<String> setProfileImageName(String name) async =>
      await _put(key: 'profileImageName', value: name);

  static Future<int> get strokeCoachId async {
    return await _get(key: 'therapistId') as int;
  }

  static Future setStrokeCoachId(int strokeCoachId) async {
    await _put(key: 'therapistId', value: strokeCoachId);
  }

  static Future<bool> get introSkip async {
    return (await _get(key: 'introSkip') as bool) ?? false;
  }

  static Future setIntroSkip(bool value) async {
    await _put(key: 'introSkip', value: value);
  }

  static Future<bool> get welcomePageSkip async {
    return (await _get(key: 'welcomePageSkip') as bool) ?? false;
  }

  static Future setWelcomePageSkip(bool value) async {
    await _put(key: 'welcomePageSkip', value: value);
  }

  static Future setEvaluationPayment(String value) async {
    await _put(key: 'evaluationPayment', value: value);
  }

  static Future<String> get evaluationPayment async {
    return (await _get(key: 'evaluationPayment') as String) ?? "";
  }

  static Future setTutorialGesture(bool value) async {
    await _put(key: 'tutorialGesture', value: value);
  }

  static Future<bool> get tutorialGesture async {
    return (await _get(key: 'tutorialGesture') as bool) ?? false;
  }

  static _put({String key, dynamic value}) async {
    var store = StoreRef.main();
    var db = await AppDatabase.instance.database;
    await store.record(key).put(db, value);
  }

  static Future<dynamic> _get({String key}) async {
    var store = StoreRef.main();
    var db = await AppDatabase.instance.database;
    return await store.record(key).get(db) as dynamic;
  }
}

class UuIdGenerator {
  static Future<String> generateUuid() async {
    return await UniqueIds.uuid;
  }
}
