class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  final bool isPro;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
    this.isPro = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      isPro: map['isPro'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'isPro': isPro,
    };
  }
}