import 'package:connect/data/remote/base_service.dart';
import 'package:connect/models/chat.dart';
import 'package:connect/models/schedule.dart';
import 'package:http/http.dart' as http;

class RequestRegisterVideoCallService extends BaseService<bool> {
  final RequestSchedule requestSchedule;

  RequestRegisterVideoCallService(this.requestSchedule)
      : assert(requestSchedule != null);

  @override
  Future<http.Response> request() async {
    return fetchPost(body: jsonEncode(requestSchedule.toJson()));
  }

  @override
  setUrl() {
    return baseUrl + 'therapist/api/v1/connect/schedule/videosession/request';
  }

  @override
  bool success(body) {
    return body;
  }
}

class GetTextChatToken extends BaseService<ChatToken> {
  @override
  Future<http.Response> request() async {
    return fetchGet();
  }

  @override
  setUrl() {
    return baseUrl + 'user/api/v1/patients/chat';
  }

  @override
  ChatToken success(body) {
    return ChatToken.fromJson(body);
  }
}

class CancelVideoCall extends BaseService<bool> {
  final String id;

  CancelVideoCall({this.id}) : assert(id != null);

  @override
  Future<http.Response> request() async {
    return await fetchDelete();
  }

  @override
  setUrl() {
    return baseUrl + 'therapist/api/v1/connect/schedule/$id/cancelvideocall';
  }

  @override
  bool success(body) {
    return body;
  }
}
