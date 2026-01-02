import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Création du user après inscription
  Future<void> createUser({
    required String role,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final appUser = AppUser(
      uid: user.uid,
      email: user.email ?? '',
      role: role,
      emailVerified: user.emailVerified,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(user.uid).set(appUser.toMap());
  }

  /// Récupérer le user connecté
  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;

    return AppUser.fromDoc(doc);
  }
}
