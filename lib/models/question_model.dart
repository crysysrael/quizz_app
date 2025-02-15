class Question {
  final String id; // 🔥 Identificador único da pergunta
  final String questionText;
  final List<String> options; // 🔥 Garante que nunca será nulo
  final List<String> imageOptions; // 🔥 Lista de imagens para alternativas
  final int correctIndex;
  final String category;
  final String difficultyLevel; // 🔥 Adicionado nível de dificuldade
  int? timeSpent;

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.imageOptions,
    required this.correctIndex,
    required this.category,
    required this.difficultyLevel, // 🔥 Campo obrigatório
    this.timeSpent,
  });

  // 🔄 Converte a pergunta para um mapa para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'options': options,
      'imageOptions': imageOptions,
      'correctIndex': correctIndex,
      'category': category,
      'difficultyLevel': difficultyLevel,
      'timeSpent': timeSpent,
    };
  }

  // 🔄 Converte um mapa do Firestore para um objeto Question
  factory Question.fromMap(Map<String, dynamic> map, String documentId) {
    return Question(
      id: documentId,
      questionText: map['questionText'] ?? '',
      options: List<String>.from(
          map['options'] ?? []), // 🔥 Garante que não será nulo
      imageOptions: List<String>.from(
          map['imageOptions'] ?? []), // 🔥 Garante que não será nulo
      correctIndex: (map['correctIndex'] is int)
          ? map['correctIndex']
          : 0, // 🔥 Segurança contra valores inválidos
      category: map['category'] ?? '',
      difficultyLevel: map['difficultyLevel'] ??
          'Médio', // 🔥 Padrão "Médio" caso não esteja definido
      timeSpent: (map['timeSpent'] is int)
          ? map['timeSpent']
          : null, // 🔥 Garante que seja int ou null
    );
  }
}
