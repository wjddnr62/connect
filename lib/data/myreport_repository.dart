import 'package:connect/data/remote/myreport/myreport_get_advice_service.dart';
import 'package:connect/data/remote/myreport/myreport_get_current_status_service.dart';

class MyReportRepository {
  static Future<dynamic> myReportGetCurrentStatus() =>
      MyReportGetCurrentStatusService().start();

  static Future<dynamic> myReportGetAdvice() => MyReportGetAdviceService().start();
}
