import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';
import 'quiz_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  _CategorySelectionScreenState createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  bool isCountdownEnabled =
      false; // 🔥 Flag para ativar/desativar contagem regressiva

  @override
  Widget build(BuildContext context) {
    final quizController = Provider.of<QuizController>(context);
    final categories = quizController.questionsByCategory.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Escolha uma Categoria",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            const Color(0xFFF6AB3C), // 🔥 Mantendo a identidade visual
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 Alternar contagem regressiva
            SwitchListTile(
              title: const Text(
                "Modo com Contagem Regressiva",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Ative para um desafio com tempo limitado."),
              value: isCountdownEnabled,
              activeColor: Colors.red,
              onChanged: (bool value) {
                setState(() {
                  isCountdownEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 🔥 Lista de categorias estilizadas
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  String category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      quizController.startQuiz(category, isCountdownEnabled);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const QuizScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFF6AB3C), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF6AB3C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
