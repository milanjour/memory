import 'package:flutter/material.dart';

import 'questions_set.dart';

class MemoryGameState extends ChangeNotifier {
  QuestionSet _questionSet =
      QuestionSet(questions: List.empty(), answers: List.empty());
  List<int> _selectedIndices = [];
  List<int> _correctIndices = [];

  QuestionSet get questionSet => _questionSet;

  List<int> get selectedIndices => _selectedIndices;

  List<int> get correctIndices => _correctIndices;

  set questionSet(QuestionSet value) {
    _questionSet = value;
    _questionSet.shuffleAnswers();
    notifyListeners();
  }

  set selectedIndices(List<int> value) {
    _selectedIndices = value;
    notifyListeners();
  }

  set correctIndices(List<int> value) {
    _correctIndices = value;
    notifyListeners();
  }

  void select(int selected) {
    if (correctIndices.contains(selected) ||
        (selectedIndices.contains(selected)) && selectedIndices.length < 2) {
      return;
    }
    if (selectedIndices.length >= 2) {
      selectedIndices.clear();
    }
    selectedIndices.add(selected);
    if (_isRightMatch()) {
      correctIndices.add(selectedIndices[0]);
      correctIndices.add(selectedIndices[1]);
    }
    notifyListeners();
  }

  bool _isRightMatch() {
    if (selectedIndices.length == 2) {
      bool isRightMatch = questionSet.isRightMatch(selectedIndices);
      // isRightMatch
      //     ? playLocal("assets/sounds/439211__javapimp__kara-ok.ogg", 1.0)
      //     : playLocal("assets/sounds/572936__bloodpixelhero__error.wav", 1.0);
      return isRightMatch;
    } else {
      return false;
    }
  }

  bool isGameFinished() {
    return questionSet.answers.length == correctIndices.length;
  }

  void reset(bool keepGameChoice) {
    if(keepGameChoice) {
      questionSet.shuffleAnswers();
    } else {
      questionSet = QuestionSet(questions: List.empty(), answers: List.empty());
    }
    correctIndices.clear();
    selectedIndices.clear();
    notifyListeners();
  }
}
