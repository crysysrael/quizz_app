import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../screens/result_screen.dart';
import '../main.dart'; // 🔥 Importa o arquivo onde a chave global foi definida

class QuizController extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimer;
  int _remainingTime = 10; // ⏳ Tempo inicial para cada pergunta
  bool _countdownEnabled =
      false; // 🔥 Flag para ativar/desativar a contagem regressiva

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

  // 🔥 Getters
  Map<String, List<Question>> get questionsByCategory => _questionsByCategory;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get remainingTime => _remainingTime;
  bool get isCountdownEnabled => _countdownEnabled;
  Question get currentQuestion => _questions.isNotEmpty
      ? _questions[_currentQuestionIndex]
      : Question(questionText: "", options: [], correctIndex: 0, category: "");

  // 🔥 Inicia o quiz
  void startQuiz(String category, bool enableCountdown) {
    _countdownEnabled = enableCountdown;
    _questions = _questionsByCategory[category] ?? [];
    _currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    _stopwatch.reset();
    _stopwatch.start();

    if (_countdownEnabled) {
      _startCountdown();
    }

    notifyListeners();
  }

  // ⏳ Inicia a contagem regressiva
  void _startCountdown() {
    _remainingTime = 10;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
      } else {
        timer.cancel();
        _handleTimeout();
      }
      notifyListeners();
    });
  }

  // 🚨 Se o tempo acabar, conta como erro e avança para a próxima pergunta
  void _handleTimeout() {
    wrongAnswers++; // Conta como erro se o tempo acabar

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _remainingTime = 10;
      _startCountdown();
    } else {
      _stopwatch.stop();
      _countdownTimer?.cancel();
      _goToResultScreen();
    }
    notifyListeners();
  }

  // ✅ Responde a pergunta manualmente
  void answerQuestion(int selectedIndex, BuildContext context) {
    _stopwatch.stop();
    _countdownTimer?.cancel();

    int timeTaken = _stopwatch.elapsedMilliseconds;
    if (_questions.isNotEmpty) {
      _questions[_currentQuestionIndex].timeSpent = timeTaken;
    }

    if (selectedIndex == _questions[_currentQuestionIndex].correctIndex) {
      correctAnswers++;
    } else {
      wrongAnswers++;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _stopwatch.reset();
      _stopwatch.start();
      if (_countdownEnabled) _startCountdown();
    } else {
      _stopwatch.stop();
      _goToResultScreen();
    }

    notifyListeners();
  }

  // 🔄 Redireciona para a tela de resultados
  void _goToResultScreen() {
    navigatorKey.currentState?.pushReplacement(
      MaterialPageRoute(
        builder: (context) => ResultScreen(quizController: this),
      ),
    );
  }

  // 🔄 Reinicia o quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    correctAnswers = 0;
    wrongAnswers = 0;
    _countdownTimer?.cancel();
    for (var question in _questions) {
      question.timeSpent = null;
    }
    notifyListeners();
  }
}
