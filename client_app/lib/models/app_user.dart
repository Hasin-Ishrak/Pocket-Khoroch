class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? university;
  final String? profession;
  final DateTime createdAt;
  final bool isPro;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.university,
    this.profession,
    required this.createdAt,
    this.isPro = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      university: map['university'] as String?,
      profession: map['profession'] as String?,
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
      'university': university,
      'profession': profession,
      'createdAt': createdAt.toIso8601String(),
      'isPro': isPro,
    };
  }

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    String? university,
    String? profession,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      university: university ?? this.university,
      profession: profession ?? this.profession,
      createdAt: createdAt,
      isPro: isPro,
    );
  }
}