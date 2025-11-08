import 'package:flutter/material.dart';
import '../models/quest.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'camera_screen.dart';
import 'leaderboard_screen.dart';
import 'community_feed_screen.dart';
import 'photo_history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  
  Quest? _todayQuest;
  User? _currentUser;
  bool _isLoading = true;
  bool _hasCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load user data
    final userId = await _storageService.getUserId();
    if (userId != null) {
      _currentUser = await _apiService.getUser(userId);
    }
    
    // Load today's quest
    _todayQuest = await _apiService.getTodayQuest();
    
    // Check if completed today
    _hasCompletedToday = await _storageService.hasCompletedTodayQuest();
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PhotoQuest'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Photo History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PhotoHistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Statistics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatisticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // User Stats Card
                      _buildUserStatsCard(),
                      const SizedBox(height: 20),
                      
                      // Community Feed Button
                      _buildCommunityFeedButton(),
                      const SizedBox(height: 20),
                      
                      // Today's Quest Card
                      _buildTodayQuestCard(),
                      const SizedBox(height: 20),
                      
                      // Take Photo Button
                      if (_todayQuest != null && !_hasCompletedToday)
                        _buildTakePhotoButton(),
                      
                      if (_hasCompletedToday)
                        _buildCompletedMessage(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildUserStatsCard() {
    final user = _currentUser;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade700,
              child: Text(
                user?.username.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 32, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user?.username ?? 'Guest',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Level', '${user?.level ?? 1}', Icons.star),
                _buildStatItem('XP', '${user?.totalXp ?? 0}', Icons.bolt),
                _buildStatItem('Quests', '${user?.questsCompleted ?? 0}', Icons.task_alt),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.green.shade700, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTodayQuestCard() {
    if (_todayQuest == null) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text('No quest available today. Check back tomorrow!'),
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green.shade700, Colors.green.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.white, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    "Today's Quest",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _todayQuest!.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _todayQuest!.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.bolt, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    'Earn up to ${_todayQuest!.xpReward} XP',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTakePhotoButton() {
    return ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(quest: _todayQuest!),
          ),
        );
        
        if (result == true) {
          await _storageService.markTodayQuestCompleted();
          _loadData();
        }
      },
      icon: const Icon(Icons.camera_alt, size: 28),
      label: const Text(
        'Take Photo',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildCommunityFeedButton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CommunityFeedScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, color: Colors.white, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Community Feed',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vote on photos and earn bonus XP!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedMessage() {
    return Card(
      elevation: 4,
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Quest completed! Come back tomorrow for a new challenge!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
