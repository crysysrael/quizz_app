import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/quiz_controller.dart';
import 'screens/welcome_screen.dart';

// 🔥 Definindo a chave global para navegação
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // 🔥 Garante inicialização correta do Flutter
  await Firebase.initializeApp(); // 🔥 Inicializa Firebase antes de rodar o app

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 🔥 Adicionando a chave de navegação
      debugShowCheckedModeBanner: false,
      title: 'LOGICAMENTEE',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const WelcomeScreen(),
    );
  }
}
