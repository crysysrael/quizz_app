import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import 'quiz_screen.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizController = Provider.of<QuizController>(context);
    final categories = quizController.questionsByCategory.keys
        .toList(); // 🔥 Agora acessa corretamente

    return Scaffold(
      appBar: AppBar(
        title: const Text("Escolha uma Categoria"),
        backgroundColor: const Color(0xFFF6AB3C), // Laranja Scratch
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Selecione uma categoria para iniciar o quiz:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Lista de categorias
            ...categories.map((category) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    quizController.startQuiz(category);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const QuizScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6AB3C), // Laranja Scratch
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
