import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorageService {
  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/quiz_results.json');
  }

  static Future<void> saveResults({
    required String userId,
    required int correctAnswers,
    required int wrongAnswers,
    required int totalTime,
    required List<int> timePerQuestion,
    required String difficulty,
    required String usability,
  }) async {
    final file = await _getFile();
    List<dynamic> data = [];

    if (await file.exists()) {
      String content = await file.readAsString();
      data = jsonDecode(content);
    }

    data.add({
      "userId": userId,
      "correctAnswers": correctAnswers,
      "wrongAnswers": wrongAnswers,
      "totalTime": totalTime,
      "timePerQuestion": timePerQuestion,
      "difficulty": difficulty,
      "usability": usability,
      "timestamp": DateTime.now().toIso8601String(),
    });

    await file.writeAsString(jsonEncode(data));
  }

  static Future<List<dynamic>> getResults() async {
    final file = await _getFile();
    if (!(await file.exists())) return [];

    String content = await file.readAsString();
    return jsonDecode(content);
  }
}
