import 'package:connect/data/remote/profile/profile_service.dart';

class ProfileRepository {
  static Future<dynamic> updateUserProfile(
      {String name,
      String birthday,
      String gender,
      String statusMessage,
      String profileImageName,
      String patientWishMessage}) async {
    return UpdateUserProfileService(
            name: name ?? "",
            birthday: birthday,
            gender: gender,
            statusMessage: statusMessage ?? "",
            profileImageName: profileImageName,
            patientWishMessage: patientWishMessage)
        .start();
  }
}
