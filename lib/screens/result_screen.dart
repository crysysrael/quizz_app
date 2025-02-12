import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:share_plus/share_plus.dart';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quizController = widget.quizController;

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 📌 Calculando tempo médio por pergunta
    List<int> timePerQuestion =
        quizController.questions.map((q) => q.timeSpent ?? 0).toList();
    int totalTime = timePerQuestion.fold(0, (sum, time) => sum + time);
    double averageTime = timePerQuestion.isNotEmpty
        ? totalTime / timePerQuestion.length / 1000
        : 0.0;

    // 🔥 Organizando as perguntas por tempo gasto
    List<Map<String, dynamic>> questionTimes = List.generate(
      quizController.questions.length,
      (index) => {
        "question": quizController.questions[index].questionText,
        "time": (quizController.questions[index].timeSpent ?? 0) / 1000
      },
    );
    questionTimes.sort((a, b) => a["time"].compareTo(b["time"]));

    // 🎯 Definir feedback baseado na pontuação
    String feedbackMessage;
    String emoji;
    if (quizController.correctAnswers == quizController.questions.length) {
      feedbackMessage = "Excelente! Você acertou tudo!";
      emoji = "😀";
    } else if (quizController.correctAnswers >=
        quizController.questions.length * 0.6) {
      feedbackMessage = "Muito bom! Você se saiu bem!";
      emoji = "🙂";
    } else {
      feedbackMessage = "Continue praticando, você consegue!";
      emoji = "😟";
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

              // 🎉 Animação ao exibir os resultados
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      feedbackMessage,
                      style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    Text(
                      emoji,
                      style: TextStyle(fontSize: screenWidth * 0.15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Mostrando acertos e erros com ícones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green, size: screenWidth * 0.1),
                      Text(
                        "Acertos: ${quizController.correctAnswers}",
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Icon(Icons.cancel,
                          color: Colors.red, size: screenWidth * 0.1),
                      Text(
                        "Erros: ${quizController.wrongAnswers}",
                        style: TextStyle(fontSize: screenWidth * 0.05),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🔹 Tempo médio e total gasto
              Text(
                "Tempo médio por pergunta: ${averageTime.toStringAsFixed(1)} segundos",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
              Text(
                "Tempo total: ${totalTime ~/ 1000} segundos",
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),

              const SizedBox(height: 20),

              // 🔥 Perguntas mais rápidas e mais demoradas
              Text(
                "Perguntas mais rápidas:",
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              ...questionTimes.take(2).map((q) => Text(
                    "- ${q['question']} (${q['time'].toStringAsFixed(1)}s)",
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  )),
              const SizedBox(height: 10),
              Text(
                "Perguntas mais demoradas:",
                style: TextStyle(
                    fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
              ),
              ...questionTimes.reversed.take(2).map((q) => Text(
                    "- ${q['question']} (${q['time'].toStringAsFixed(1)}s)",
                    style: TextStyle(fontSize: screenWidth * 0.035),
                  )),

              const SizedBox(height: 20),

              // 🔹 Gráfico de tempo por pergunta
              SizedBox(
                height: screenHeight * 0.3,
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis:
                      NumericAxis(title: AxisTitle(text: "Tempo (s)")),
                  series: <CartesianSeries>[
                    ColumnSeries<Map<String, dynamic>, String>(
                      dataSource: questionTimes,
                      xValueMapper: (data, _) =>
                          questionTimes.indexOf(data).toString(),
                      yValueMapper: (data, _) => data["time"],
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 🔄 Botão para compartilhar o resultado
              ElevatedButton.icon(
                onPressed: () {
                  String resultText =
                      "🎯 Meu resultado no Quiz:\n\nAcertos: ${quizController.correctAnswers}\nErros: ${quizController.wrongAnswers}\nTempo total: ${totalTime ~/ 1000} segundos\n\nBaixe o app e desafie-se!";
                  Share.share(resultText);
                },
                icon: const Icon(Icons.share, color: Colors.white),
                label: const Text(
                  "Compartilhar Resultado",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent),
              ),
              const SizedBox(height: 15),

              // 🔄 Botão para reiniciar o quiz
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
