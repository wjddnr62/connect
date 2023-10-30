import 'package:connect/data/remote/stroke_coach/working_hour_service.dart';

class StrokeCoachRepository {
  static Future<dynamic> getStrokeCoachWorkingHours() {
    return WorkingHourService().start();
  }
}
