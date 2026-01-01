import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // REGISTER
  Future<void> register(String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Envoi email de vérification
      await cred.user?.sendEmailVerification();

      // Déconnexion immédiate (sécurité)
      await _auth.signOut();

    } on FirebaseAuthException catch (e) {
      throw Exception(_mapRegisterError(e.code));
    }
  }

  // LOGIN
  Future<void> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Vérification email
      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        throw Exception('Veuillez vérifier votre email avant de vous connecter');
      }

    } on FirebaseAuthException catch (e) {
      throw Exception(_mapLoginError(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String _mapLoginError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Email invalide';
      default:
        return 'Erreur de connexion';
    }
  }

  String _mapRegisterError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible';
      case 'invalid-email':
        return 'Email invalide';
      default:
        return 'Erreur lors de l’inscription';
    }
  }
}
