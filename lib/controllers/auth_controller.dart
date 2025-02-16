import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔥 Verifica se o usuário está logado
  User? get currentUser => _auth.currentUser;

  // 🔥 Verifica se o usuário fez login com Google ou Email/Senha
  bool isGoogleUser() {
    final User? user = _auth.currentUser;
    return user?.providerData.any((info) => info.providerId == "google.com") ??
        false;
  }

  // 🔥 Login com e-mail e senha
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners(); // 🔥 Atualiza UI após login
      return true;
    } catch (e) {
      print("❌ Erro ao fazer login com email: $e");
      return false;
    }
  }

  // 🔥 Criar conta com e-mail e senha
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      notifyListeners(); // 🔥 Atualiza UI após criação da conta
      return true;
    } catch (e) {
      print("❌ Erro ao criar conta com email: $e");
      return false;
    }
  }

  // 🔥 Recuperar senha
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("❌ Erro ao recuperar senha: $e");
      return false;
    }
  }

  // 🔥 Login com Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Usuário cancelou login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      notifyListeners(); // 🔥 Atualiza UI após login
      return userCredential.user;
    } catch (e) {
      print("❌ Erro ao fazer login com Google: $e");
      return null;
    }
  }

  // 🔥 Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      notifyListeners(); // 🔥 Atualiza UI após logout
    } catch (e) {
      print("❌ Erro ao fazer logout: $e");
    }
  }
}
