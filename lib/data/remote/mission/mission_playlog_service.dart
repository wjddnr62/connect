import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class MissionPlayLogService extends BaseService {
  final String missionId;
  final DateTime startDate;
  final DateTime endDate;
  final Duration duration;

  MissionPlayLogService(
      this.missionId, this.startDate, this.endDate, this.duration);

  @override
  Future<Response> request() {
    return fetchPost(
        body: jsonEncode({
      'mission_id': missionId,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate.toUtc().toIso8601String(),
      'duration': duration.inSeconds
    }));
  }

  @override
  setUrl() {
    return baseUrl + 'connect/api/v2/mission/playlog';
  }

  @override
  success(body) {}
}
