# PhotoQuest - Quick Setup Guide

## ✅ What's Been Done

Your Flutter app is now fully set up with:

### 📁 Project Structure
```
lib/
├── main.dart                    # App entry point
├── config/
│   └── app_config.dart         # API configuration
├── models/
│   ├── quest.dart              # Quest data model
│   ├── user.dart               # User profile model
│   ├── ai_rating.dart          # AI rating response model
│   ├── leaderboard_entry.dart  # Leaderboard entry model
│   └── photo_submission.dart   # Photo submission model
├── services/
│   ├── api_service.dart        # Backend API calls
│   └── storage_service.dart    # Local data storage
└── screens/
    ├── splash_screen.dart      # Loading screen
    ├── home_screen.dart        # Main dashboard
    ├── camera_screen.dart      # Photo capture
    ├── results_screen.dart     # AI rating results
    └── leaderboard_screen.dart # Rankings
```

### 📦 Installed Packages
- ✅ `http` - API requests
- ✅ `camera` - Camera access
- ✅ `image_picker` - Photo selection
- ✅ `shared_preferences` - Local storage
- ✅ `firebase_core` - Firebase integration
- ✅ `provider` - State management
- ✅ `intl` - Date formatting
- ✅ `flutter_animate` - Animations

## 🚀 Next Steps

### 1. Configure Backend URL

Open `lib/config/app_config.dart` and update:

```dart
static const String apiBaseUrl = 'YOUR_BACKEND_URL/api';
```

**Examples:**
- Local: `http://localhost:3000/api`
- Android Emulator: `http://10.0.2.2:3000/api`
- Deployed: `https://your-app.onrender.com/api`

### 2. Set Up Backend

See `BACKEND_GUIDE.md` for complete backend setup instructions.

Quick backend setup:
```bash
# Install dependencies
npm install express multer openai cors dotenv

# Create .env file
echo "OPENAI_API_KEY=your_key_here" > .env
echo "PORT=3000" >> .env

# Start server
node server.js
```

### 3. Run the App

```bash
# Install Flutter dependencies (already done)
flutter pub get

# Run on device/emulator
flutter run

# Or for specific platform
flutter run -d chrome      # Web
flutter run -d windows     # Windows
flutter run -d android     # Android
flutter run -d ios         # iOS
```

## 🎮 App Flow

1. **Splash Screen** → Auto-creates user if new
2. **Home Screen** → Shows daily quest and user stats
3. **Camera Screen** → User takes/selects photo
4. **Submit to Backend** → Photo sent for AI rating
5. **Results Screen** → Shows score, XP, feedback
6. **Leaderboard** → View global rankings

## 🔧 Testing Without Backend

To test the UI without a backend, you can:

1. Comment out API calls temporarily
2. Return mock data in services
3. Use sample data in screens

Example mock data in `api_service.dart`:

```dart
Future<Quest?> getTodayQuest() async {
  // Mock quest for testing
  return Quest(
    id: 'test-1',
    title: 'Capture Nature',
    description: 'Take a photo of something green',
    topic: 'nature',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(Duration(days: 1)),
    xpReward: 100,
  );
}
```

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: 21 (Android 5.0)
- Camera permissions: ✅ Already configured
- Internet permissions: ✅ Already configured
- Test on emulator: Use `10.0.2.2` for localhost

### iOS
- Minimum iOS: 12.0
- Camera permissions: ✅ Already configured in Info.plist
- Photo library permissions: ✅ Already configured
- For HTTP (dev only): NSAppTransportSecurity configured

### Web
- Camera access requires HTTPS in production
- File upload supported
- Use Chrome for development

## 🐛 Troubleshooting

### Issue: "Couldn't connect to backend"
**Solution:** Check API URL in `app_config.dart`, ensure backend is running

### Issue: Camera not working
**Solution:** Check permissions in device settings, rebuild app

### Issue: "SharedPreferences not found"
**Solution:** Run `flutter pub get` again

### Issue: Build errors
**Solution:** 
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: Android emulator can't reach localhost
**Solution:** Use `http://10.0.2.2:3000` instead of `localhost:3000`

## 📊 Features Overview

### Home Screen
- User profile with level, XP, quests completed
- Today's quest card with title, description, XP reward
- "Take Photo" button to start quest
- Leaderboard navigation

### Camera Screen  
- Take photo with camera
- Select from gallery
- Photo preview
- Submit for AI rating

### Results Screen
- AI score (0-10) with color-coded gradient
- XP earned display
- AI feedback explanation
- Outdoor/Topic match indicators
- Return home button

### Leaderboard
- Top 100 users ranked by XP
- Special styling for top 3
- Shows username, XP, quests completed
- Pull to refresh

## 🎨 Customization

### Change Theme Colors

Edit `lib/main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change this!
    brightness: Brightness.light,
  ),
  ...
)
```

### Modify Quest XP Rewards

Edit `lib/config/app_config.dart`:

```dart
static const int baseXpReward = 100; // Change base XP
```

### Adjust Rating Thresholds

Edit `lib/models/ai_rating.dart`:

```dart
String get rating {
  if (score >= 9.0) return 'Masterpiece!';
  if (score >= 7.5) return 'Excellent!';
  // Modify thresholds here
}
```

## 📈 Future Enhancements

Easy to add:
- [ ] User authentication (Firebase Auth)
- [ ] Photo gallery/history
- [ ] Share results on social media
- [ ] Achievement badges
- [ ] Friends system
- [ ] Push notifications
- [ ] Dark mode
- [ ] Multi-language support

## 💡 Tips for Hackathon Presentation

1. **Demo Flow:**
   - Show splash → home with quest
   - Take a live photo (outdoors if possible!)
   - Submit and show AI rating
   - Show leaderboard

2. **Highlight Features:**
   - Real-time AI analysis
   - Gamification (XP, levels, leaderboard)
   - Clean, modern UI
   - Works on Android & iOS

3. **Technical Points:**
   - Flutter for cross-platform
   - GPT-4 Vision for intelligent rating
   - RESTful API architecture
   - Local storage for offline data

4. **Show Code:**
   - API service structure
   - AI rating model
   - Camera integration

## 📚 Documentation Files

- `README.md` - Main project overview
- `BACKEND_GUIDE.md` - Complete backend setup
- `SETUP_GUIDE.md` - This file!

## ✨ You're Ready!

Your PhotoQuest app is fully configured and ready to run. Just:

1. Set up your backend (see BACKEND_GUIDE.md)
2. Update the API URL in app_config.dart
3. Run `flutter run`
4. Start testing!

Good luck with your hackathon! 🚀📸
