import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/question_model.dart';
import '../screens/result_screen.dart';
import '../main.dart';

class QuizController extends ChangeNotifier {
  int _currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  String selectedAgeGroup = "";
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _countdownTimer;
  int _remainingTime = 10;
  bool _countdownEnabled = false;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<Question>> _questionsByCategory = {};
  List<Question> _questions = [];

  // 🔥 Getters
  Map<String, List<Question>> get questionsByCategory => _questionsByCategory;
  List<Question> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get remainingTime => _remainingTime;
  bool get isCountdownEnabled => _countdownEnabled;
  String get ageGroup => selectedAgeGroup;

  Question get currentQuestion => _questions.isNotEmpty
      ? _questions[_currentQuestionIndex]
      : Question(
          id: "",
          questionText: "",
          options: [],
          correctIndex: 0,
          category: "",
          difficultyLevel: "");

  // 🔥 Busca perguntas do Firestore
  Future<void> fetchQuestionsFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('questions').get();
      Map<String, List<Question>> tempQuestionsByCategory = {};

      for (var doc in querySnapshot.docs) {
        Question question = Question.fromMap(doc.data(), doc.id);
        if (!tempQuestionsByCategory.containsKey(question.category)) {
          tempQuestionsByCategory[question.category] = [];
        }
        tempQuestionsByCategory[question.category]!.add(question);
      }

      _questionsByCategory = tempQuestionsByCategory;
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar perguntas do Firestore: $e");
    }
  }

  // 🔥 Inicia o quiz carregando perguntas do Firebase
  Future<void> startQuiz(
      String category, bool enableCountdown, String ageGroup) async {
    _countdownEnabled = enableCountdown;
    selectedAgeGroup = ageGroup;

    if (_questionsByCategory.isEmpty) {
      await fetchQuestionsFromFirestore();
    }

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

  // 🚨 Se o tempo acabar, conta como erro
  void _handleTimeout() async {
    wrongAnswers++;
    await _playSound("sounds/wrong.mp3");

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _remainingTime = 10;
      _startCountdown();
    } else {
      _stopwatch.stop();
      _countdownTimer?.cancel();
      await _saveResultToFirestore();
      _goToResultScreen();
    }
    notifyListeners();
  }

  // ✅ Responde a pergunta
  void answerQuestion(int selectedIndex, BuildContext context) async {
    _stopwatch.stop();
    _countdownTimer?.cancel();

    int timeTaken = _stopwatch.elapsedMilliseconds;
    if (_questions.isNotEmpty) {
      _questions[_currentQuestionIndex].timeSpent = timeTaken;
    }

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
      await _saveResultToFirestore();
      _goToResultScreen();
    }

    notifyListeners();
  }

  // 🔥 Salva os resultados no Firestore
  Future<void> _saveResultToFirestore() async {
    try {
      // 🔥 Obtém um ID único para o usuário (futuro: usar autenticação)
      String userId =
          "user_${DateTime.now().millisecondsSinceEpoch}"; // 🔥 Temporário

      await _firestore.collection('quiz_results').add({
        'userId': userId,
        'ageGroup': selectedAgeGroup,
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'totalQuestions': _questions.length,
        'totalTime': _stopwatch.elapsed.inSeconds, // 🔥 Tempo total em segundos
        'timestamp': FieldValue
            .serverTimestamp(), // 🔥 Timestamp automático do Firestore
      });

      print("✅ Resultado salvo com sucesso no Firestore!");
    } catch (e) {
      print("❌ Erro ao salvar resultado no Firestore: $e");
    }
  }

  // 🎵 Reproduz som
  Future<void> _playSound(String path) async {
    try {
      await _audioPlayer.play(AssetSource(path));
    } catch (e) {
      print("Erro ao reproduzir som: $e");
    }
  }

  // 🔄 Redireciona para a tela de resultados
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
