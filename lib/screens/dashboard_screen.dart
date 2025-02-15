import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _quizStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizStatistics();
  }

  // 🔥 Busca estatísticas no Firestore
  Future<void> _fetchQuizStatistics() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('quiz_results').get();

      int totalQuizzes = snapshot.docs.length;
      Map<String, int> correctAnswersByAge = {};
      Map<String, int> totalAttemptsByAge = {};
      int longestTime = 0;
      int shortestTime = 999999;
      int totalTime = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String ageGroup = data['ageGroup'];
        int correctAnswers = data['correctAnswers'];
        int totalQuestions = data['totalQuestions'];
        int quizTime = data['totalTime'];

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

      String bestAgeGroup = "";
      String worstAgeGroup = "";
      double bestAccuracy = 0;
      double worstAccuracy = 100;

      correctAnswersByAge.forEach((ageGroup, correct) {
        int total = totalAttemptsByAge[ageGroup] ?? 1;
        double accuracy = (correct / total) * 100;

        if (accuracy > bestAccuracy) {
          bestAccuracy = accuracy;
          bestAgeGroup = ageGroup;
        }

        if (accuracy < worstAccuracy) {
          worstAccuracy = accuracy;
          worstAgeGroup = ageGroup;
        }
      });

      setState(() {
        _quizStats = {
          "totalQuizzes": totalQuizzes,
          "bestAgeGroup": bestAgeGroup,
          "worstAgeGroup": worstAgeGroup,
          "longestTime": longestTime,
          "shortestTime": shortestTime,
          "averageTime": totalQuizzes > 0 ? totalTime ~/ totalQuizzes : 0,
        };
        _isLoading = false;
      });
    } catch (e) {
      print("Erro ao buscar estatísticas: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "📊 Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF6AB3C),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF6AB3C),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCard("Total de Quizzes Realizados",
                      _quizStats["totalQuizzes"].toString()),
                  _buildStatCard(
                      "Faixa Etária com Melhor Desempenho",
                      _quizStats["bestAgeGroup"].isNotEmpty
                          ? _quizStats["bestAgeGroup"]
                          : "N/A"),
                  _buildStatCard(
                      "Faixa Etária com Mais Dificuldade",
                      _quizStats["worstAgeGroup"].isNotEmpty
                          ? _quizStats["worstAgeGroup"]
                          : "N/A"),
                  _buildStatCard("Maior Tempo em um Quiz",
                      "${_quizStats["longestTime"]} segundos"),
                  _buildStatCard("Menor Tempo em um Quiz",
                      "${_quizStats["shortestTime"]} segundos"),
                  _buildStatCard("Tempo Médio por Quiz",
                      "${_quizStats["averageTime"]} segundos"),
                ],
              ),
            ),
    );
  }

  // 🔹 Cria um Card estilizado para exibir estatísticas
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
