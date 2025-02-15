class Question {
  final String id; // 🔥 Identificador único da pergunta
  final String questionText;
  final List<String>? options; // 🔥 Agora pode ser texto ou imagem
  final List<String>? imageOptions; // 🔥 Novo campo para imagens
  final int correctIndex;
  final String category;
  final String difficultyLevel; // 🔥 Adicionado nível de dificuldade
  int? timeSpent;

  Question({
    required this.id,
    required this.questionText,
    this.options,
    this.imageOptions,
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
      options: List<String>.from(map['options'] ?? []),
      imageOptions: List<String>.from(map['imageOptions'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
      category: map['category'] ?? '',
      difficultyLevel: map['difficultyLevel'] ?? 'Médio', // 🔥 Padrão "Médio"
      timeSpent: map['timeSpent'],
    );
  }
}
