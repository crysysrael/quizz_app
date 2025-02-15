import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResultsOverviewScreen extends StatefulWidget {
  const ResultsOverviewScreen({super.key});

  @override
  _ResultsOverviewScreenState createState() => _ResultsOverviewScreenState();
}

class _ResultsOverviewScreenState extends State<ResultsOverviewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchQuizStatistics() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('quiz_results').get();

      if (snapshot.docs.isEmpty) {
        return {
          "totalQuizzes": 0,
          "correctAnswersByAge": {},
          "totalAttemptsByAge": {},
          "longestTime": 0,
          "shortestTime": 0,
          "averageTime": 0,
        };
      }

      int totalQuizzes = snapshot.docs.length;
      Map<String, int> correctAnswersByAge = {};
      Map<String, int> totalAttemptsByAge = {};
      int longestTime = 0;
      int shortestTime = 9999999;
      int totalTime = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String ageGroup = data['ageGroup'] ?? "Desconhecido";
        int correctAnswers = data['correctAnswers'] ?? 0;
        int totalQuestions = data['totalQuestions'] ?? 0;
        int quizTime = data['totalTime'] ?? 0;

        if (!correctAnswersByAge.containsKey(ageGroup)) {
          correctAnswersByAge[ageGroup] = 0;
          totalAttemptsByAge[ageGroup] = 0;
        }

        correctAnswersByAge[ageGroup] =
            (correctAnswersByAge[ageGroup] ?? 0) + correctAnswers;
        totalAttemptsByAge[ageGroup] =
            (totalAttemptsByAge[ageGroup] ?? 0) + totalQuestions;

        if (quizTime > longestTime) longestTime = quizTime;
        if (quizTime < shortestTime) shortestTime = quizTime;
        totalTime += quizTime;
      }

      return {
        "totalQuizzes": totalQuizzes,
        "correctAnswersByAge": correctAnswersByAge,
        "totalAttemptsByAge": totalAttemptsByAge,
        "longestTime": longestTime,
        "shortestTime": shortestTime,
        "averageTime": totalQuizzes > 0 ? totalTime ~/ totalQuizzes : 0,
      };
    } catch (e) {
      print("Erro ao buscar estatísticas: $e");
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📊 Visão Geral dos Resultados",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF6AB3C),
        elevation: 2,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchQuizStatistics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFF6AB3C)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum dado disponível no momento.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var data = snapshot.data!;
          int totalQuizzes = data["totalQuizzes"] ?? 0;
          int longestTime = data["longestTime"] ?? 0;
          int shortestTime = data["shortestTime"] ?? 0;
          int averageTime = data["averageTime"] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                    "Total de Quizzes Realizados", totalQuizzes.toString()),
                _buildStatCard(
                    "⏳ Tempo Médio de Resposta", "$averageTime segundos"),
                _buildStatCard("⏱️ Pergunta que levou mais tempo",
                    "$longestTime segundos"),
                _buildStatCard("⚡ Pergunta respondida mais rápido",
                    "$shortestTime segundos"),

                const SizedBox(height: 20),
                const Text(
                  "📈 Desempenho por Faixa Etária:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // 🔥 Lista de desempenho por faixa etária
                Expanded(
                  child: data['correctAnswersByAge'].isNotEmpty
                      ? ListView(
                          children: data['correctAnswersByAge']
                              .keys
                              .map<Widget>((ageGroup) {
                            int correct =
                                data['correctAnswersByAge'][ageGroup] ?? 0;
                            int total =
                                data['totalAttemptsByAge'][ageGroup] ?? 0;
                            double percentage =
                                total > 0 ? (correct / total) * 100 : 0;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ListTile(
                                title: Text(
                                  ageGroup,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                    "Acertos: $correct / $total perguntas"),
                                trailing: Text(
                                  total > 0
                                      ? "${percentage.toStringAsFixed(1)}%"
                                      : "Nenhuma resposta",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: total > 0
                                          ? Colors.green
                                          : Colors.grey),
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      : const Center(
                          child: Text(
                            "Nenhuma estatística por faixa etária disponível.",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔹 Função para criar cards estilizados de estatísticas
  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
