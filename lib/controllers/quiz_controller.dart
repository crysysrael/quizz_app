import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/question_model.dart';
import '../screens/result_screen.dart';
import '../main.dart'; // 🔥 Importa a chave global de navegação

class QuizController extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimer;
  int _remainingTime = 10;
  bool _countdownEnabled = false;

  final AudioPlayer _audioPlayer = AudioPlayer(); // 🎵 Para tocar os sons

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

  Map<String, List<Question>> get questionsByCategory => _questionsByCategory;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get remainingTime => _remainingTime;
  bool get isCountdownEnabled => _countdownEnabled;
  Question get currentQuestion => _questions.isNotEmpty
      ? _questions[_currentQuestionIndex]
      : Question(questionText: "", options: [], correctIndex: 0, category: "");

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

  void _handleTimeout() async {
    wrongAnswers++;
    await _playSound(
        "sounds/wrong.mp3"); // 🎵 Toca som de erro ao zerar o tempo

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

  void answerQuestion(int selectedIndex, BuildContext context) async {
    _stopwatch.stop();
    _countdownTimer?.cancel();

    int timeTaken = _stopwatch.elapsedMilliseconds;
    if (_questions.isNotEmpty) {
      _questions[_currentQuestionIndex].timeSpent = timeTaken;
    }

    // 🎵 Toca o som de acerto ou erro
    if (selectedIndex == _questions[_currentQuestionIndex].correctIndex) {
      correctAnswers++;
      await _playSound("sounds/correct.mp3");
    } else {
      wrongAnswers++;
      await _playSound("sounds/wrong.mp3");
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

  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      print("Erro ao reproduzir som: $e");
    }
  }

  void _goToResultScreen() {
    navigatorKey.currentState?.pushReplacement(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          ResultScreen(quizController: this),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeTween =
            Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation.drive(fadeTween),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    ));
  }

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
