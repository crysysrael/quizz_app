import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../screens/result_screen.dart';

class QuizController extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Stopwatch _stopwatch = Stopwatch();

  // 🔥 Mapa de perguntas organizadas por categoria
  final Map<String, List<Question>> _questionsByCategory = {
    "Introdução ao Scratch": [
      Question(
        questionText: "O que é o Scratch?",
        options: [
          "Um editor de texto",
          "Uma linguagem de programação visual",
          "Um navegador",
          "Uma rede social"
        ],
        correctIndex: 1,
        category: "Introdução ao Scratch",
      ),
      Question(
        questionText: "Quem criou o Scratch?",
        options: ["Microsoft", "Google", "MIT Media Lab", "Apple"],
        correctIndex: 2,
        category: "Introdução ao Scratch",
      ),
    ],

    // 🔥 Categoria com alternativas em IMAGENS
    "Blocos de Código": [
      Question(
        questionText: "Qual desses blocos inicia um programa no Scratch?",
        imageOptions: [
          "assets/images/bloco_movimento.png",
          "assets/images/bloco_inicio.png",
          "assets/images/bloco_repetir.png",
          "assets/images/bloco_som.png",
        ],
        correctIndex: 1,
        category: "Blocos de Código",
      ),
      Question(
        questionText: "Qual desses blocos é usado para repetir ações?",
        imageOptions: [
          "assets/images/bloco_movimento.png",
          "assets/images/bloco_inicio.png",
          "assets/images/bloco_repetir.png",
          "assets/images/bloco_som.png",
        ],
        correctIndex: 2,
        category: "Blocos de Código",
      ),
    ],
  };

  List<Question> _questions = [];
  String _selectedCategory = "Introdução ao Scratch"; // Categoria padrão

  // 🔥 Getter público para acessar as categorias
  Map<String, List<Question>> get questionsByCategory => _questionsByCategory;

  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  Question get currentQuestion => _questions[_currentQuestionIndex];

  void startQuiz(String category) {
    _selectedCategory = category;
    _questions = _questionsByCategory[category] ?? [];
    _currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
  }

  void answerQuestion(int selectedIndex, BuildContext context) {
    _stopwatch.stop();
    int timeTaken = _stopwatch.elapsedMilliseconds;
    _questions[_currentQuestionIndex].timeSpent = timeTaken;

    if (selectedIndex == _questions[_currentQuestionIndex].correctIndex) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _stopwatch.reset();
      _stopwatch.start();
    } else {
      _stopwatch.stop();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ResultScreen(quizController: this)),
      );
    }

    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    for (var question in _questions) {
      question.timeSpent = null;
    }
    notifyListeners();
  }
}
