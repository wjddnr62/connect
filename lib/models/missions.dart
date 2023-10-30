const String MISSION_TYPE_ACTIVITY = 'ACTIVITY';
const String MISSION_TYPE_EXERCISE_BASICS = 'BASICS';
const String MISSION_TYPE_VIDEO = 'VIDEO';
const String MISSION_TYPE_CARD_READING = "READING";
const String MISSION_TYPE_QUIZ = "QUIZ";

class Mission {
  final String id;
  final String type;
  final String title;
  final String description;

  // final String image;
  // final List<String> tags;
  // final Meta meta;
  bool completed;
  bool isFree;

  // String shareLink;

  Mission({
    this.id,
    this.type,
    this.title,
    this.description,
    // this.image,
    // this.tags,
    // this.meta,
    this.completed,
    this.isFree,
    // this.shareLink
  });

  factory Mission.fromJson(body) {
    return Mission(
      id: body['id'] as String,
      type: body['type'] as String,
      title: body['title'] as String,
      description: body['description'] as String,
      // image: body['image'] as String,
      // tags: body['tags'] != null ? new List<String>.from(body['tags']) : null,
      // meta: body['meta'] != null ? Meta.fromJson(body['meta']) : null,
      completed: body['completed'] as bool ?? false,
      isFree: body['isFree'],
      // shareLink: body['shareLink']
    );
  }
}

class MissionRenewal {
  final String date;
  final List<Mission> missions;

  MissionRenewal({this.date, this.missions});

  factory MissionRenewal.fromJson(body) {
    return MissionRenewal(
        date: body['date'] != null ? body['date'] as String : "",
        missions: body['missions'] != null
            ? (body['missions'] as List)
                .map((e) => Mission.fromJson(e))
                .toList()
            : null);
  }
}

class MissionDetail {
  final String id;
  final String type;
  final String title;
  final String description;
  final String image;
  final List<String> tags;
  final Meta meta;
  bool completed;
  bool isFree;
  String shareLink;
  bool isBookmark;

  MissionDetail(
      {this.id,
      this.type,
      this.title,
      this.description,
      this.image,
      this.tags,
      this.meta,
      this.completed,
      this.isFree,
      this.shareLink,
      this.isBookmark});

  factory MissionDetail.fromJson(body) {
    return MissionDetail(
        id: body['id'] as String,
        type: body['type'] as String,
        title: body['title'] as String,
        description: body['description'] as String,
        image: body['image'] as String,
        tags: body['tags'] != null ? new List<String>.from(body['tags']) : null,
        meta: body['meta'] != null ? Meta.fromJson(body['meta']) : null,
        completed: body['completed'] as bool,
        isFree: body['isFree'],
        shareLink: body['shareLink'],
        isBookmark: body['isBookmark']);
  }
}

class Meta {
  final List<String> links;
  final List<Quiz> quizList;
  final int repeatCount;

  Meta({this.links, this.quizList, this.repeatCount});

  factory Meta.fromJson(body) {
    return Meta(
        links:
            body['links'] != null ? new List<String>.from(body['links']) : null,
        quizList: body['quizList'] != null
            ? (body['quizList'] as List).map((e) => Quiz.fromJson(e)).toList()
            : null,
        repeatCount:
            body['repeat_count'] != null ? body['repeat_count'] as int : 0);
  }
}

class Quiz {
  final String quizType;
  final String title;
  final String content;
  final List<Answer> answerList;
  final bool onlyAnswer;
  final int order;

  Quiz(
      {this.quizType,
      this.title,
      this.content,
      this.answerList,
      this.onlyAnswer,
      this.order});

  factory Quiz.fromJson(body) {
    return Quiz(
        quizType: body['quizType'],
        title: body['title'],
        content: body['content'],
        answerList: body['answerList'] != null
            ? (body['answerList'] as List)
                .map((e) => Answer.fromJson(e))
                .toList()
            : null,
        onlyAnswer: body['onlyAnswer'],
        order: body['order']);
  }
}

class Answer {
  final String text;
  final bool isAnswer;
  final int order;

  Answer({this.text, this.isAnswer, this.order});

  factory Answer.fromJson(body) {
    return Answer(
        text: body['text'], isAnswer: body['is_answer'], order: body['order']);
  }
}

class EvaluationMission extends Mission {
  EvaluationMission({
    type,
    title,
    description,
    completed,
  }) : super(
          type: type,
          title: title,
          description: description,
          completed: completed,
        );

  factory EvaluationMission.fromJson(Map<String, dynamic> map) {
    var mission = EvaluationMission(
      title: map['title'] as String,
      description: map['description'] as String,
      completed: map['isCompleted'] as bool,
    );

    return mission;
  }
}
