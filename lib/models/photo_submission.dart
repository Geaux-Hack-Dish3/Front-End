class PhotoSubmission {
  final String id;
  final String userId;
  final String username;
  final String questId;
  final String questTitle;
  final String photoUrl;
  final DateTime submittedAt;
  final double? score;
  final String? feedback;
  final int? xpEarned;
  final int likes;
  final int dislikes;
  final bool? userVote; // true = liked, false = disliked, null = not voted

  PhotoSubmission({
    required this.id,
    required this.userId,
    required this.username,
    required this.questId,
    required this.questTitle,
    required this.photoUrl,
    required this.submittedAt,
    this.score,
    this.feedback,
    this.xpEarned,
    this.likes = 0,
    this.dislikes = 0,
    this.userVote,
  });

  factory PhotoSubmission.fromJson(Map<String, dynamic> json) {
    return PhotoSubmission(
      id: json['id'] as String,
      userId: json['userId'] as String,
      username: json['username'] as String? ?? 'Anonymous',
      questId: json['questId'] as String,
      questTitle: json['questTitle'] as String? ?? 'Unknown Quest',
      photoUrl: json['photoUrl'] as String,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
      xpEarned: json['xpEarned'] as int?,
      likes: json['likes'] as int? ?? 0,
      dislikes: json['dislikes'] as int? ?? 0,
      userVote: json['userVote'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'questId': questId,
      'questTitle': questTitle,
      'photoUrl': photoUrl,
      'submittedAt': submittedAt.toIso8601String(),
      'score': score,
      'feedback': feedback,
      'xpEarned': xpEarned,
      'likes': likes,
      'dislikes': dislikes,
      'userVote': userVote,
    };
  }

  int get totalVotes => likes + dislikes;
  
  double get likeRatio => totalVotes == 0 ? 0 : (likes / totalVotes) * 100;
}
