import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/quiz_controller.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizController quizController;

  const ResultScreen({super.key, required this.quizController});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  String mostSkilledAgeGroup = "Carregando...";
  String leastSkilledAgeGroup = "Carregando...";
  bool isLoading = true; // 🔥 Indicador de carregamento

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
    _animationController.forward();

    _fetchAgeGroupPerformance();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAgeGroupPerformance() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot snapshot = await firestore.collection('quiz_results').get();

      Map<String, int> ageGroupScores = {};
      Map<String, int> ageGroupCounts = {};

      for (var doc in snapshot.docs) {
        String ageGroup = doc['ageGroup'] ?? "Desconhecido";
        int correctAnswers = doc['correctAnswers'] ?? 0;

        if (!ageGroupScores.containsKey(ageGroup)) {
          ageGroupScores[ageGroup] = 0;
          ageGroupCounts[ageGroup] = 0;
        }

        ageGroupScores[ageGroup] =
            (ageGroupScores[ageGroup] ?? 0) + correctAnswers;
        ageGroupCounts[ageGroup] = (ageGroupCounts[ageGroup] ?? 0) + 1;
      }

      if (ageGroupScores.isNotEmpty) {
        mostSkilledAgeGroup = ageGroupScores.entries
            .reduce((a, b) => (a.value / (ageGroupCounts[a.key] ?? 1)) >
                    (b.value / (ageGroupCounts[b.key] ?? 1))
                ? a
                : b)
            .key;

        leastSkilledAgeGroup = ageGroupScores.entries
            .reduce((a, b) => (a.value / (ageGroupCounts[a.key] ?? 1)) <
                    (b.value / (ageGroupCounts[b.key] ?? 1))
                ? a
                : b)
            .key;
      }
    } catch (e) {
      print("Erro ao buscar dados do Firestore: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizController = widget.quizController;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    List<int> timePerQuestion =
        quizController.questions.map((q) => q.timeSpent ?? 0).toList();
    int totalTime = timePerQuestion.fold(0, (sum, time) => sum + time);
    double averageTime = timePerQuestion.isNotEmpty
        ? totalTime / timePerQuestion.length / 1000
        : 0.0;

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFF6AB3C)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultados"),
        backgroundColor: const Color(0xFFF6AB3C),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      "Faixa etária com melhor desempenho:",
                      style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mostSkilledAgeGroup,
                      style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.green,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Faixa etária com mais dificuldades:",
                      style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      leastSkilledAgeGroup,
                      style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          color: Colors.red,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Tempo médio por pergunta: ${averageTime.toStringAsFixed(1)} segundos",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              Text(
                "Tempo total: ${totalTime ~/ 1000} segundos",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: screenHeight * 0.3,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis:
                      NumericAxis(title: AxisTitle(text: "Tempo (s)")),
                  series: <CartesianSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: List.generate(
                        quizController.questions.length,
                        (index) => {
                          "question": index.toString(),
                          "time":
                              (quizController.questions[index].timeSpent ?? 0) /
                                  1000,
                        },
                      ),
                      xValueMapper: (data, _) => data["question"],
                      yValueMapper: (data, _) => data["time"],
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  quizController.resetQuiz();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6AB3C)),
                child: const Text("Reiniciar Quiz",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
