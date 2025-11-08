import 'package:flutter/material.dart';
import '../models/photo_submission.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  List<PhotoSubmission> _submissions = [];
  bool _isLoading = true;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    
    _userId = await _storage.getUserId();
    final submissions = await _apiService.getRecentSubmissions(
      limit: 30,
      excludeUserId: _userId, // Don't show user's own photos
    );

    setState(() {
      _submissions = submissions;
      _isLoading = false;
    });
  }

  Future<void> _handleVote(PhotoSubmission submission, bool isLike) async {
    if (_userId == null) return;

    // Optimistic update
    setState(() {
      final index = _submissions.indexWhere((s) => s.id == submission.id);
      if (index != -1) {
        final current = _submissions[index];
        
        // If changing vote, remove old vote
        int newLikes = current.likes;
        int newDislikes = current.dislikes;
        
        if (current.userVote != null) {
          if (current.userVote == true) {
            newLikes--;
          } else {
            newDislikes--;
          }
        }
        
        // If clicking same vote, remove it. Otherwise add new vote
        bool? newUserVote;
        if (current.userVote == isLike) {
          // Remove vote
          newUserVote = null;
        } else {
          // Add new vote
          newUserVote = isLike;
          if (isLike) {
            newLikes++;
          } else {
            newDislikes++;
          }
        }
        
        _submissions[index] = PhotoSubmission(
          id: current.id,
          userId: current.userId,
          username: current.username,
          questId: current.questId,
          questTitle: current.questTitle,
          photoUrl: current.photoUrl,
          submittedAt: current.submittedAt,
          score: current.score,
          feedback: current.feedback,
          xpEarned: current.xpEarned,
          likes: newLikes,
          dislikes: newDislikes,
          userVote: newUserVote,
        );
      }
    });

    // Send to backend
    bool success;
    if (submission.userVote == isLike) {
      // Remove vote
      success = await _apiService.removeVote(
        photoId: submission.id,
        userId: _userId!,
      );
    } else {
      // Add or change vote
      success = await _apiService.voteOnPhoto(
        photoId: submission.id,
        userId: _userId!,
        isLike: isLike,
      );
    }

    if (!success) {
      // Revert on failure
      _loadFeed();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to vote. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _submissions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_library_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No submissions yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to complete a quest!',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFeed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _submissions.length,
                    itemBuilder: (context, index) {
                      final submission = _submissions[index];
                      return _buildPhotoCard(submission);
                    },
                  ),
                ),
    );
  }

  Widget _buildPhotoCard(PhotoSubmission submission) {
    final scoreColor = submission.score != null
        ? submission.score! >= 8
            ? Colors.purple
            : submission.score! >= 6
                ? Colors.green
                : submission.score! >= 4
                    ? Colors.orange
                    : Colors.red
        : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  child: Text(
                    submission.username[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        submission.questTitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (submission.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: scoreColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scoreColor),
                    ),
                    child: Text(
                      '${submission.score!.toStringAsFixed(1)}/10',
                      style: TextStyle(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Photo
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: Colors.grey[300],
              child: submission.photoUrl.startsWith('http')
                  ? Image.network(
                      submission.photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.image,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
          ),

          // Vote buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Like button
                InkWell(
                  onTap: () => _handleVote(submission, true),
                  child: Row(
                    children: [
                      Icon(
                        submission.userVote == true
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        color: submission.userVote == true
                            ? Colors.green
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.likes}',
                        style: TextStyle(
                          color: submission.userVote == true
                              ? Colors.green
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Dislike button
                InkWell(
                  onTap: () => _handleVote(submission, false),
                  child: Row(
                    children: [
                      Icon(
                        submission.userVote == false
                            ? Icons.thumb_down
                            : Icons.thumb_down_outlined,
                        color: submission.userVote == false
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.dislikes}',
                        style: TextStyle(
                          color: submission.userVote == false
                              ? Colors.red
                              : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Vote percentage
                if (submission.totalVotes > 0)
                  Text(
                    '${submission.likeRatio.toStringAsFixed(0)}% like',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // AI Feedback (if available)
          if (submission.feedback != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                submission.feedback!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
