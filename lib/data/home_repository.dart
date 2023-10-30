import 'package:connect/data/remote/home/summary_service.dart';

class HomeRepository {
  static var instance = HomeRepository._internal();

  factory HomeRepository() {
    return instance;
  }

  HomeRepository._internal();

  Future<dynamic> trainingSummary() async {
    return SummaryService().start();
  }
}
