import 'package:connect/models/missions.dart';

class Bookmark {
  List<Mission> readings;
  List<Mission> exercises;

  Bookmark({this.readings, this.exercises});

  factory Bookmark.fromJson(body) {
    return Bookmark(
        readings: body['reading'] != null
            ? (body['reading'] as List).map((e) => Mission.fromJson(e)).toList()
            : null,
        exercises: body['exercise'] != null
            ? (body['exercise'] as List)
                .map((e) => Mission.fromJson(e))
                .toList()
            : null);
  }
}
