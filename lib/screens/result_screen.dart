import 'package:flutter/material.dart';
import '../controllers/quiz_controller.dart';
import '../services/local_storage_service.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatefulWidget {
  final QuizController quizController;

  const ResultScreen({super.key, required this.quizController});

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? selectedDifficulty;
  String? selectedUsability;

  @override
  Widget build(BuildContext context) {
    final quizController = widget.quizController;
    int totalTime =
        quizController.questions.fold(0, (sum, q) => sum + (q.timeSpent ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resultados"),
        backgroundColor: const Color(0xFFF6AB3C), // Laranja Scratch
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Seu Desempenho",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text("Acertos: ${quizController.correctAnswers}"),
            Text("Erros: ${quizController.wrongAnswers}"),
            Text("Tempo Total: ${totalTime ~/ 1000} segundos"),
            const SizedBox(height: 20),

            // Dropdown para Dificuldade
            const Text("Qual foi a dificuldade do quiz?"),
            DropdownButton<String>(
              value: selectedDifficulty,
              hint: const Text("Selecione"),
              onChanged: (String? value) {
                setState(() {
                  selectedDifficulty = value;
                });
              },
              items: ["Fácil", "Normal", "Difícil"].map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Dropdown para Usabilidade
            const Text("Como você avaliaria a usabilidade do app?"),
            DropdownButton<String>(
              value: selectedUsability,
              hint: const Text("Selecione"),
              onChanged: (String? value) {
                setState(() {
                  selectedUsability = value;
                });
              },
              items: ["Satisfatória", "Frustrante"].map((String feedback) {
                return DropdownMenuItem<String>(
                  value: feedback,
                  child: Text(feedback),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Botão de Reiniciar
            ElevatedButton(
              onPressed: () {
                widget.quizController
                    .resetQuiz(); // 🔥 Agora reseta corretamente o quiz
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const WelcomeScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF6AB3C), // Laranja Scratch
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: const Text(
                "Reiniciar Quiz",
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white, // Mantendo o fundo branco
    );
  }
}
