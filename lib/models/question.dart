class EvaluationItem {
  final String title;
  final bool isCompleted;
  final Question question;
  final int progress;

  EvaluationItem({this.title, this.isCompleted, this.question, this.progress});

  factory EvaluationItem.fromJson(Map<String, dynamic> json) {
    return EvaluationItem(
      progress: json['progress'] == null ? 0 : json['progress'],
      isCompleted: json['is_completed'],
      question:
          json['question'] != null ? Question.fromJson(json['question']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['progress'] = this.progress;
    data['is_completed'] = this.isCompleted;

    if (this.question != null) {
      data['question'] = this.question.toJson();
    }

    return data;
  }
}

class Question {
  final List<Answer> answers;
  final String text;
  final bool multiSelectable;

  Question({this.answers, this.text, this.multiSelectable = false});

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      answers: json['answers'] != null
          ? (json['answers'] as List).map((i) => Answer.fromJson(i)).toList()
          : null,
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    if (this.answers != null) {
      data['answers'] = this.answers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Answer {
  final String label;
  final int value;
  final String image;
  final String selectedImage;

  Answer({
    this.label,
    this.value,
    this.image,
    this.selectedImage,
  });

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      label: json['label'],
      value: json['value'],
      image: json['image'],
      selectedImage: json['selectedImage'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    data['image'] = this.image;
    data['selectedImage'] = this.selectedImage;
    return data;
  }
}
