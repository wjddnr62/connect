class Evaluation {
  final String type;
  final String image;
  final List<Question> question;

  Evaluation({this.type, this.image, this.question});

  factory Evaluation.fromJson(Map<String, dynamic> body) {
    return Evaluation(
      type: body['type'],
      image: body['image'],
      question:
          (body['questions'] as List).map((i) => Question.fromJson(i)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['type'] = this.type;
    data['image'] = this.image;
    data['questions'] = this.question;

    return data;
  }
}

class Question {
  final String text;
  final List<Answers> answer;

  Question({this.text, this.answer});

  factory Question.fromJson(body) {
    return Question(
        text: body['text'] as String,
        answer:
            (body['answers'] as List).map((i) => Answers.fromJson(i)).toList());
  }
}

class Answers {
  final String label;
  final String type;

  Answers({this.label, this.type});

  factory Answers.fromJson(Map<String, dynamic> body) {
    return Answers(label: body['label'] as String, type: body['type'] as String);
  }
}

class EvaluationSelectAnswer {
  String typeSelect;
  double scoreSum;
//  int indexSum;

  EvaluationSelectAnswer({this.typeSelect, this.scoreSum});

  Map<String, dynamic> toJson() => {'type': typeSelect, 'level': scoreSum};
}

class ValidEvaluation {
  final bool isValid;
  final String title;
  final String description;

  ValidEvaluation({this.isValid, this.title, this.description});

  factory ValidEvaluation.fromJson(body) {
    return ValidEvaluation(
        title: body['title'] as String,
        description: body['description'] as String,
        isValid: body['isValid'] as bool);
  }
}
