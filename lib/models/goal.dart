class Goal {
  final List<Servey> servey;

  Goal({this.servey});

  factory Goal.fromJson(Map<String, dynamic> body) {
    return Goal(
        servey: (body['servey_list'] as List)
            .map((e) => Servey.fromJson(e))
            .toList());
  }
}

class Servey {
  final String title;
  final String data;

  Servey({this.title, this.data});

  factory Servey.fromJson(body) {
    return Servey(title: body['title'] as String, data: body['data'] as String);
  }
}
