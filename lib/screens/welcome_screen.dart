import 'package:flutter/material.dart';
import 'category_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6AB3C), // 🔥 Mantendo a paleta de cores
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: GestureDetector(
            onTapDown: (_) {
              setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              setState(() => _isPressed = false);
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const CategorySelectionScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(0.0, 1.0);
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;
                    var tween = Tween(begin: begin, end: end)
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
            child: AnimatedScale(
              scale: _isPressed ? 0.95 : 1.0, // 🔥 Efeito de clique
              duration: const Duration(milliseconds: 150),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🔥 Logo do Quiz - Agora maior (150 de altura)
                  Image.asset(
                    'assets/images/scratch_logo.png',
                    height: 150,
                  ),

                  const SizedBox(height: 20),

                  // 🔥 Nome do App
                  const Text(
                    'LÓGICA MENTEE',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
