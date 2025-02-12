import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/quiz_controller.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatelessWidget {
  final QuizController quizController;

  const ResultScreen({super.key, required this.quizController});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultados"),
        backgroundColor: const Color(0xFFF6AB3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Seu Desempenho",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Mostrando acertos e erros com ícones
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 40),
                    Text(
                      "Acertos: ${quizController.correctAnswers}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 40),
                    Text(
                      "Erros: ${quizController.wrongAnswers}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔹 Tempo médio e total gasto
            Text(
              "Tempo médio por pergunta: ${averageTime.toStringAsFixed(1)} segundos",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Tempo total: ${totalTime ~/ 1000} segundos",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // 🔥 Perguntas mais rápidas e mais demoradas
            Text(
              "Perguntas mais rápidas:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...questionTimes.take(2).map((q) => Text(
                  "- ${q['question']} (${q['time'].toStringAsFixed(1)}s)",
                  style: const TextStyle(fontSize: 14),
                )),
            const SizedBox(height: 10),
            Text(
              "Perguntas mais demoradas:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...questionTimes.reversed.take(2).map((q) => Text(
                  "- ${q['question']} (${q['time'].toStringAsFixed(1)}s)",
                  style: const TextStyle(fontSize: 14),
                )),

            const SizedBox(height: 20),

            // 🔹 Gráfico de tempo por pergunta
            Text(
              "Tempo gasto por pergunta",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(title: AxisTitle(text: "Tempo (s)")),
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

            const Spacer(),

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
                backgroundColor: const Color(0xFFF6AB3C),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                "Reiniciar Quiz",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
