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

class _CategorySelectionScreenState extends State<CategorySelectionScreen>
    with SingleTickerProviderStateMixin {
  bool isCountdownEnabled = false;
  String selectedAgeGroup = "13 - 17 anos"; // 🔥 Definição padrão

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = true; // 🔥 Indica carregamento das categorias

  final List<String> ageGroups = [
    "Menos de 12 anos",
    "13 - 17 anos",
    "18 - 29 anos",
    "Mais de 30 anos"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();

    // 🔥 Buscar categorias do Firebase antes de exibir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<QuizController>(context, listen: false)
          .fetchQuestionsFromFirestore();
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        backgroundColor: const Color(0xFFF6AB3C),
        elevation: 2,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFF6AB3C),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 🔥 Seletor de faixa etária
                    const Text(
                      "Selecione sua faixa etária:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: selectedAgeGroup,
                      items: ageGroups.map((String group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(group),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedAgeGroup = newValue!;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔥 Alternar contagem regressiva
                    SwitchListTile(
                      title: const Text(
                        "Modo com Contagem Regressiva",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                          "Ative para um desafio com tempo limitado."),
                      value: isCountdownEnabled,
                      activeColor: Colors.red,
                      onChanged: (bool value) {
                        setState(() {
                          isCountdownEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // 🔥 Lista de categorias estilizadas com efeito de toque
                    Expanded(
                      child: categories.isEmpty
                          ? const Center(
                              child: Text(
                                "Nenhuma categoria disponível!",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            )
                          : ListView.builder(
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                String category = categories[index];

                                return GestureDetector(
                                  onTap: () {
                                    quizController.startQuiz(
                                      category,
                                      isCountdownEnabled,
                                      selectedAgeGroup, // 🔥 Passa a faixa etária correta
                                    );
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                                secondaryAnimation) =>
                                            const QuizScreen(),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          const begin = Offset(1.0, 0.0);
                                          const end = Offset.zero;
                                          const curve = Curves.easeInOut;
                                          var tween = Tween(
                                                  begin: begin, end: end)
                                              .chain(CurveTween(curve: curve));

                                          return SlideTransition(
                                            position: animation.drive(tween),
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: const Color(0xFFF6AB3C),
                                          width: 2),
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
      ),
    );
  }
}
