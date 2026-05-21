import 'package:cloud_firestore/cloud_firestore.dart';

import 'enums.dart';

class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final UserSection? section;
  final UserRole role;
  final String? avatarUrl;
  final String? fcmToken;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.section,
    required this.role,
    required this.createdAt,
    this.avatarUrl,
    this.fcmToken,
  });

  bool get hasSection => section != null;
  bool get isAdmin => role == UserRole.admin;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      displayName: (data['displayName'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      section: UserSection.fromKey(data['section'] as String?),
      role: UserRole.fromKey(data['role'] as String?),
      avatarUrl: data['avatarUrl'] as String?,
      fcmToken: data['fcmToken'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'section': section?.key,
      'role': role.key,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? displayName,
    String? email,
    UserSection? section,
    UserRole? role,
    String? avatarUrl,
    String? fcmToken,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      section: section ?? this.section,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt,
    );
  }
}
