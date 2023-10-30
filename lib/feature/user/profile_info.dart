import 'package:connect/models/stroke_coach.dart';

void resetProfileGlobal() {}

class ProfileInfo {
  static final ProfileInfo _instance = ProfileInfo._();

  String name;
  DateTime birthday = DateTime(1970, 1, 1);
  String gender;
  DateTime onsetDate = DateTime.now();
  List<bool> affectedSide = [false, false];
  String usStateCode;
  String diagnosticName;
  String dominantHand;
  StrokeCoach strokeCoach;
  String marketPlace;

  ProfileInfo._();

  static ProfileInfo get instance => _instance;

  static bool chatEnable = false;

  reset() {
    name = '';
    birthday = DateTime(1970, 1, 1);
    gender = null;
    onsetDate = DateTime(1970, 1, 1);
    affectedSide = [false, false];
    usStateCode = null;
    diagnosticName = null;
    dominantHand = null;
    strokeCoach = null;
    marketPlace = null;
  }
}
