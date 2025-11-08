class User {
  final String id;
  final String username;
  final String email;
  final int totalXp;
  final int questsCompleted;
  final DateTime createdAt;
  final String? avatarUrl;
  final int votesReceived;
  final int votesGiven;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.totalXp,
    required this.questsCompleted,
    required this.createdAt,
    this.avatarUrl,
    this.votesReceived = 0,
    this.votesGiven = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      totalXp: json['totalXp'] as int,
      questsCompleted: json['questsCompleted'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      avatarUrl: json['avatarUrl'] as String?,
      votesReceived: json['votesReceived'] as int? ?? 0,
      votesGiven: json['votesGiven'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'totalXp': totalXp,
      'questsCompleted': questsCompleted,
      'createdAt': createdAt.toIso8601String(),
      'avatarUrl': avatarUrl,
      'votesReceived': votesReceived,
      'votesGiven': votesGiven,
    };
  }

  int get level => (totalXp / 100).floor() + 1;
  
  int get xpForNextLevel => (level * 100) - totalXp;
}
