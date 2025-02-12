import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/quiz_controller.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedAnswerIndex;

  @override
  Widget build(BuildContext context) {
    final quizController = Provider.of<QuizController>(context);
    final question = quizController.currentQuestion;
    double progress = (quizController.currentQuestionIndex + 1) /
        quizController.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pergunta ${quizController.currentQuestionIndex + 1} de ${quizController.questions.length}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF6AB3C),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔥 Barra de progresso
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFF6AB3C),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔥 Pergunta (Card estilizado)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Text(
                question.questionText,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // 🔥 Renderiza imagens ou texto, dependendo da pergunta
            if (question.imageOptions != null &&
                question.imageOptions!.isNotEmpty)
              ...List.generate(question.imageOptions!.length, (index) {
                bool isSelected = selectedAnswerIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswerIndex = index;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      quizController.answerQuestion(index, context);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.greenAccent : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Image.asset(
                      question.imageOptions![index],
                      height: 100, // Tamanho do bloco
                    ),
                  ),
                );
              })
            else
              ...List.generate(question.options!.length, (index) {
                bool isSelected = selectedAnswerIndex == index;
                bool isCorrect = index == question.correctIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedAnswerIndex = index;
                    });
                    Future.delayed(const Duration(milliseconds: 500), () {
                      quizController.answerQuestion(index, context);
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isCorrect ? Colors.green : Colors.redAccent)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? (isCorrect ? Colors.green : Colors.red)
                            : Colors.grey,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Text(
                      question.options![index],
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
