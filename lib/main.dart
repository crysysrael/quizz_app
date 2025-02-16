import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'controllers/quiz_controller.dart';
import 'controllers/auth_controller.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';

// 🔥 Definindo a chave global para navegação
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase
        .initializeApp(); // 🔥 Inicializa Firebase antes de rodar o app
  } catch (e) {
    print("❌ Erro ao inicializar o Firebase: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuizController()),
        ChangeNotifierProvider(create: (_) => AuthController()), // 🔥 Corrigido
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
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'LOGICAMENTEE',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: _buildInitialScreen(),
    );
  }

  // 🔥 Define a tela inicial com base no status do login
  Widget _buildInitialScreen() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // 🔥 Mantém a autenticação em tempo real
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child:
                    CircularProgressIndicator()), // 🔄 Tela de carregamento enquanto verifica login
          );
        }

        final User? user = snapshot.data;
        return user == null ? const LoginScreen() : const WelcomeScreen();
      },
    );
  }
}
