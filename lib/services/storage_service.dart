import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _totalXpKey = 'total_xp';
  static const String _questsCompletedKey = 'quests_completed';
  static const String _lastQuestDateKey = 'last_quest_date';

  // Save user ID
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  // Get user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Save username
  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }

  // Get username
  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Save total XP
  Future<void> saveTotalXp(int xp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_totalXpKey, xp);
  }

  // Get total XP
  Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXpKey) ?? 0;
  }

  // Save quests completed
  Future<void> saveQuestsCompleted(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_questsCompletedKey, count);
  }

  // Get quests completed
  Future<int> getQuestsCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_questsCompletedKey) ?? 0;
  }

  // Check if user completed today's quest
  Future<bool> hasCompletedTodayQuest() async {
    final prefs = await SharedPreferences.getInstance();
    final lastQuestDate = prefs.getString(_lastQuestDateKey);
    
    if (lastQuestDate == null) return false;
    
    final lastDate = DateTime.parse(lastQuestDate);
    final today = DateTime.now();
    
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }

  // Mark today's quest as completed
  Future<void> markTodayQuestCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastQuestDateKey, DateTime.now().toIso8601String());
  }

  // Clear all data (for logout)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
