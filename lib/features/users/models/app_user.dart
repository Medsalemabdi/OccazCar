import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final bool emailVerified;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'role': role,
    'emailVerified': emailVerified,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      role: data['role'],
      emailVerified: data['emailVerified'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
