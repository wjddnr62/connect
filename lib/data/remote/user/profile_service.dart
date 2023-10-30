import 'package:connect/models/profile.dart';
import 'package:http/http.dart' as http;

import '../base_service.dart';

class GetProfileService extends BaseService<Profile> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/patient/me';
  }

  @override
  Profile success(body) {
    return Profile.fromJson(body);
  }
}

class UpdateProfileService extends BaseService<bool> {
  final Profile profile;

  UpdateProfileService({this.profile});

  @override
  Future<http.Response> request() async {
    List<String> strokeSide = [];
    if (profile.infectedSide[0]) {
      strokeSide.add('LEFT');
    }
    if (profile.infectedSide[1]) {
      strokeSide.add('RIGHT');
    }
    return fetchPost(
      body: jsonEncode({
        'name': profile.name,
        'gender': profile.gender,
        'stroke_side': strokeSide,
        'birthday': profile.birthday.toIso8601String(),
        'onset_date': profile.onsetDate.toIso8601String(),
        'us_state_code': profile.usStateCode,
        'dominant_hand': profile.dominantHand,
        'diagnostic_name': profile.diagnosticName,
      }),
    );
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/users/symptom';
  }

  @override
  bool success(body) {
    return body;
  }
}
