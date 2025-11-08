class Vote {
  final String id;
  final String userId;
  final String photoId;
  final bool isLike; // true = like, false = dislike
  final DateTime createdAt;

  Vote({
    required this.id,
    required this.userId,
    required this.photoId,
    required this.isLike,
    required this.createdAt,
  });

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'],
      userId: json['userId'],
      photoId: json['photoId'],
      isLike: json['isLike'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'photoId': photoId,
      'isLike': isLike,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
