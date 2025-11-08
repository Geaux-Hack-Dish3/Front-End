import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quest.dart';

class QuestService {
  static const String _dailyQuestsKey = 'daily_quests';
  static const String _lastResetDateKey = 'last_reset_date';
  static const String _completedQuestsKey = 'completed_quests';

  // All available quest types - outdoor photo challenges
  static final List<Map<String, String>> _allQuestTypes = [
    {
      'id': 'green_nature',
      'title': 'Green Nature',
      'description': 'Capture lush greenery - trees, grass, or plants',
      'icon': '🌳',
    },
    {
      'id': 'flowers',
      'title': 'Blooming Beauty',
      'description': 'Find and photograph colorful flowers',
      'icon': '🌸',
    },
    {
      'id': 'water_scenes',
      'title': 'Water Wonders',
      'description': 'Lakes, rivers, or ocean views',
      'icon': '💧',
    },
    {
      'id': 'mountain_views',
      'title': 'Mountain Majesty',
      'description': 'Capture hills, mountains, or scenic overlooks',
      'icon': '⛰️',
    },
    {
      'id': 'wildlife',
      'title': 'Wildlife Encounter',
      'description': 'Birds, animals, or insects in nature',
      'icon': '🦋',
    },
    {
      'id': 'sunrise_sunset',
      'title': 'Golden Hour',
      'description': 'Sunrise or sunset with outdoor scenery',
      'icon': '🌅',
    },
    {
      'id': 'forest_trail',
      'title': 'Forest Path',
      'description': 'Woodland trails, forest scenes, or tree canopies',
      'icon': '🌲',
    },
    {
      'id': 'garden',
      'title': 'Garden Glory',
      'description': 'Garden landscapes with plants and flowers',
      'icon': '🏡',
    },
    {
      'id': 'park_life',
      'title': 'Park Adventure',
      'description': 'Public parks with grass, trees, or playgrounds',
      'icon': '🎡',
    },
    {
      'id': 'autumn_leaves',
      'title': 'Fall Foliage',
      'description': 'Autumn colors - red, orange, and yellow leaves',
      'icon': '🍂',
    },
    {
      'id': 'desert_landscape',
      'title': 'Desert Beauty',
      'description': 'Desert plants, cacti, or sandy landscapes',
      'icon': '🌵',
    },
    {
      'id': 'beach_scene',
      'title': 'Beach Vibes',
      'description': 'Sandy beaches, dunes, or coastal plants',
      'icon': '🏖️',
    },
    {
      'id': 'wetlands',
      'title': 'Wetland Wilderness',
      'description': 'Marshes, swamps, or wetland vegetation',
      'icon': '🦆',
    },
    {
      'id': 'meadow',
      'title': 'Meadow Magic',
      'description': 'Open fields with wildflowers or tall grass',
      'icon': '🌾',
    },
    {
      'id': 'tropical',
      'title': 'Tropical Paradise',
      'description': 'Palm trees, tropical plants, or exotic flowers',
      'icon': '🌴',
    },
  ];

  // Check if it's a new day in Eastern Time and reset quests if needed
  Future<bool> checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetDate = prefs.getString(_lastResetDateKey);
    
    // Get current date in Eastern Time
    final now = DateTime.now().toUtc();
    final easternTime = now.subtract(const Duration(hours: 5)); // EST is UTC-5
    final today = '${easternTime.year}-${easternTime.month}-${easternTime.day}';
    
    if (lastResetDate != today) {
      // New day! Reset quests
      await _generateDailyQuests();
      await prefs.setString(_lastResetDateKey, today);
      await prefs.remove(_completedQuestsKey); // Clear completed quests
      return true;
    }
    
    return false;
  }

  // Generate 3 random unique quests for the day
  Future<void> _generateDailyQuests() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get yesterday's quests to avoid repetition
    final previousQuestIds = prefs.getStringList(_dailyQuestsKey) ?? [];
    
    // Filter out yesterday's quests
    final availableQuests = _allQuestTypes
        .where((q) => !previousQuestIds.contains(q['id']))
        .toList();
    
    // If we filtered out too many, just use all quests
    final questPool = availableQuests.length >= 3 ? availableQuests : _allQuestTypes;
    
    // Shuffle and pick 3
    final shuffled = List<Map<String, String>>.from(questPool)..shuffle(Random());
    final selectedQuests = shuffled.take(3).toList();
    
    // Save quest IDs
    final questIds = selectedQuests.map((q) => q['id']!).toList();
    await prefs.setStringList(_dailyQuestsKey, questIds);
  }

  // Get today's quests
  Future<List<Quest>> getTodaysQuests() async {
    await checkAndResetDaily(); // Always check for reset first
    
    final prefs = await SharedPreferences.getInstance();
    final questIds = prefs.getStringList(_dailyQuestsKey) ?? [];
    
    if (questIds.isEmpty) {
      // First time, generate quests
      await _generateDailyQuests();
      return getTodaysQuests(); // Recursive call to get the new quests
    }
    
    // Get completed quest IDs
    final completedIds = prefs.getStringList(_completedQuestsKey) ?? [];
    
    // Build Quest objects
    final quests = <Quest>[];
    for (int i = 0; i < questIds.length; i++) {
      final questData = _allQuestTypes.firstWhere(
        (q) => q['id'] == questIds[i],
        orElse: () => _allQuestTypes[0],
      );
      
      quests.add(Quest(
        id: questData['id']!,
        title: questData['title']!,
        description: questData['description']!,
        xpReward: 100,
        isCompleted: completedIds.contains(questData['id']),
      ));
    }
    
    return quests;
  }

  // Mark a quest as completed
  Future<void> completeQuest(String questId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedIds = prefs.getStringList(_completedQuestsKey) ?? [];
    
    if (!completedIds.contains(questId)) {
      completedIds.add(questId);
      await prefs.setStringList(_completedQuestsKey, completedIds);
    }
  }

  // Get time until next reset (midnight Eastern Time)
  Duration getTimeUntilReset() {
    final now = DateTime.now().toUtc();
    final easternTime = now.subtract(const Duration(hours: 5));
    
    // Calculate next midnight Eastern
    final nextMidnight = DateTime(
      easternTime.year,
      easternTime.month,
      easternTime.day + 1,
      0, 0, 0,
    );
    
    final resetTime = nextMidnight.add(const Duration(hours: 5)); // Convert back to UTC
    return resetTime.difference(now);
  }

  // Get formatted time until reset
  String getTimeUntilResetFormatted() {
    final duration = getTimeUntilReset();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return '${hours}h ${minutes}m';
  }
}
