class Question {
  final String questionText;
  final List<String>? options; // 🔥 Agora pode ser texto ou imagem
  final List<String>? imageOptions; // 🔥 Novo campo para imagens
  final int correctIndex;
  final String category;
  int? timeSpent;

  Question({
    required this.questionText,
    this.options,
    this.imageOptions,
    required this.correctIndex,
    required this.category,
    this.timeSpent,
  });
}
