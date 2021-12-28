import 'package:collection/collection.dart';
import 'dart:convert';

QuestionSet questionSetFromJson(String str) =>
    QuestionSet.fromJson(json.decode(str));

class QuestionSet {
  QuestionSet({required this.questions, required this.answers});

  List<Question> questions;

  List<Answer> answers;

  factory QuestionSet.fromJson(Map<String, dynamic> json) {
    List<Question> questionsList =
        List<Question>.from(json["questions"].map((x) => Question.fromJson(x)));
    return QuestionSet(
        questions: questionsList,
        answers: questionsList.expand((question) => question.answers).toList());
  }

  void shuffleAnswers() {
    answers.shuffle();
  }

  bool isRightMatch(List<int> selectedIndices) {
    Set<Answer> selectedAnswers =
        selectedIndices.map((index) => answers.elementAt(index)).toSet();
    return questions.any((question) =>
        const SetEquality().equals(question.answers.toSet(), selectedAnswers));
  }
}

class Question {
  Question({
    required this.id,
    required this.answers,
  });

  String id;
  List<Answer> answers;

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json["id"],
        answers: List<Answer>.from(json["answers"].map((x) => Answer(
              id: x["answer"]["id"],
              type: x["answer"]["type"],
              value: x["answer"]["value"],
            ))),
      );
}

class Answer {
  Answer({
    required this.id,
    required this.type,
    required this.value,
  });

  String id;
  String type;
  String value;

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: json["id"],
        type: json["type"],
        value: json["value"],
      );
}
