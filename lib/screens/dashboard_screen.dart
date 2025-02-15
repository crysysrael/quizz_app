import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'results_overview_screen.dart'; // 🔥 Tela de visão geral dos resultados

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic> _quizStats = {};
  bool _isLoading = true;
  bool _hasData = false;

  final bool _isAdmin =
      true; // 🔥 Simulação: futuramente será baseada em autenticação

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

      if (snapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
        return;
      }

      int totalQuizzes = snapshot.docs.length;
      Map<String, int> correctAnswersByAge = {};
      Map<String, int> totalAttemptsByAge = {};
      int longestTime = 0;
      int shortestTime = 999999;
      int totalTime = 0;

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String ageGroup = data['ageGroup'] ?? "Desconhecido";
        int correctAnswers = data['correctAnswers'] ?? 0;
        int totalQuestions = data['totalQuestions'] ?? 1;
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

      String bestAgeGroup = "Nenhum dado";
      String worstAgeGroup = "Nenhum dado";
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
        _hasData = true;
      });
    } catch (e) {
      print("Erro ao buscar estatísticas: $e");
      setState(() {
        _isLoading = false;
        _hasData = false;
      });

      // 🔥 Exibe um aviso para o usuário se houver erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro ao carregar estatísticas: $e"),
          backgroundColor: Colors.red,
        ),
      );
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
          : !_hasData
              ? const Center(
                  child: Text(
                    "Nenhum dado disponível.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

                      const SizedBox(height: 20),

                      // 🔥 Botão para visualizar os resultados gerais (somente admins)
                      if (_isAdmin)
                        Center(
                          child: ElevatedButton(
                            onPressed: _hasData
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ResultsOverviewScreen(),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _hasData
                                  ? Colors.orange
                                  : Colors
                                      .grey, // Desativa o botão se não houver dados
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "📊 Ver Resultados Gerais",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
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
