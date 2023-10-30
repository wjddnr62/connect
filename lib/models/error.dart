import 'package:connect/utils/logger/log.dart';

const String UNKNOWN_ERROR = 'unknown error';

class ServiceError {
  /// definition of error
  final String code;

  /// message of error
  final String message;

  /// extra error spec of app-internal exception or error
  final String spec;

  ServiceError({
    this.code = UNKNOWN_ERROR,
    this.message,
    this.spec,
  }) {
    Log.d('error', '$this');
  }

  @override
  String toString() {
    return 'code = $code\nmessage = $message';
  }

  factory ServiceError.fromJson(Map<String, dynamic> body) {
    ServiceError ret = ServiceError(
      code: body['code'] as String,
      message: body['message'] as String,
    );

    Log.d('error', '$ret');
    return ret;
  }
}
