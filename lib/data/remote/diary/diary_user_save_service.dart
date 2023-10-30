import 'package:connect/data/remote/base_service.dart';
import 'package:http/src/response.dart';

class DiaryUserSaveService extends BaseService {
  final String writeDatetime;
  final String sleepDatetime;
  final String wakeDatetime;
  final String weatherType;
  final String feelingType;
  final String contentMessage;
  final List<Map<String, dynamic>> contentImages;
  final bool isPrivate;

  DiaryUserSaveService(
      {this.writeDatetime,
      this.sleepDatetime,
      this.wakeDatetime,
      this.weatherType,
      this.feelingType,
      this.contentMessage,
      this.contentImages,
      this.isPrivate});

  @override
  Future<Response> request() async {
    return await fetchPost(
        body: jsonEncode({
      'write_datetime': writeDatetime,
      'sleep_datetime': sleepDatetime,
      'wake_datetime': wakeDatetime,
      'weather_type': weatherType,
      'feeling_type': feelingType,
      'content_message': contentMessage,
      'content_images': contentImages,
      'is_private': isPrivate
    }));
  }

  @override
  setUrl() {
    return '${baseUrl}connect/api/v1/diary';
  }

  @override
  success(body) {
    return body;
  }
}
