import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapLoginError(e.code));
    }
  }

  // REGISTER
  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapRegisterError(e.code));
    }
  }

  String _mapLoginError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Email invalide';
      case 'too-many-requests':
        return 'Trop de tentatives, réessayez plus tard';
      default:
        return 'Identifiants incorrects';
    }
  }

  String _mapRegisterError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (min 6 caractères)';
      case 'invalid-email':
        return 'Email invalide';
      default:
        return 'Erreur lors de l’inscription';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
