# PhotoQuest 📸🌳

**PhotoQuest** is a gamified mobile app that motivates users to go outdoors, complete daily photo challenges, and compete for the best AI-rated pictures!

## 🎯 What is PhotoQuest?

PhotoQuest encourages users to explore nature through fun, daily photo challenges. Each day brings a new quest like "capture something green" or "photograph sunlight through trees." Users take photos, get AI-powered ratings (0-10), earn XP, and climb the leaderboard!

### Key Features
- 📅 **Daily Photo Challenges** - New quests every day
- 📷 **Camera Integration** - Take photos or upload from gallery
- 🤖 **AI-Powered Rating** - GPT-4 Vision scores photos based on quality, topic match, and outdoor setting
- 👥 **Community Voting** - Vote on other users' photos with likes/dislikes
- ⚡ **XP & Leveling System** - Earn experience points and level up (AI rating + community votes)
- 🏆 **Leaderboard** - Compete with other users globally
- 🎨 **Beautiful UI** - Material 3 design with smooth animations

## 🏗️ Architecture

### Frontend (Flutter)
- **Screens**: Home, Camera, Results, Leaderboard, CommunityFeed, Splash
- **Models**: Quest, User, AIRating, LeaderboardEntry, PhotoSubmission, Vote
- **Services**: ApiService (backend communication), StorageService (local data)
- **State Management**: StatefulWidget with local state

### Backend API Integration
The app communicates with your Node.js/Express backend API for:
- Fetching daily quests
- Submitting photos for AI rating
- Retrieving leaderboard data
- User management
- Community voting system (likes/dislikes)

### AI Integration
- Backend uses **OpenAI GPT-4 Vision API** to analyze photos
- **AI automatically determines** if photo was taken outdoors (no user input needed)
- Rates based on:
  - **Outdoor setting** (required for high scores - indoor photos score 0-3)
  - **Topic relevance** (how well it matches quest theme)
  - **Photo quality** and composition
- Returns score (0-10), feedback, outdoor detection result, and XP earned
- Bonus XP awarded for excellent outdoor photos (score ≥7)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.2+)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Backend API running (see backend repo)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Geaux-Hack-Dish3/Front-End.git
   cd Front-End
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoint**
   
   Edit `lib/config/app_config.dart`:
   ```dart
   static const String apiBaseUrl = 'YOUR_BACKEND_URL/api';
   ```
   
   Replace `YOUR_BACKEND_URL` with your actual backend URL (e.g., `http://localhost:3000` for local development or your deployed URL).

4. **Run the app**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Camera permissions are already configured in `AndroidManifest.xml`

#### iOS
- Minimum iOS: 12.0
- Camera and photo library permissions configured in `Info.plist`
- Run `cd ios && pod install` if needed

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk
  http: ^1.2.1                    # HTTP requests
  firebase_core: ^2.20.0          # Firebase integration
  camera: ^0.10.5+5               # Camera functionality
  image_picker: ^1.0.4            # Image selection
  path_provider: ^2.1.1           # File system paths
  shared_preferences: ^2.2.2      # Local storage
  provider: ^6.1.1                # State management
  flutter_animate: ^4.3.0         # Animations
  intl: ^0.18.1                   # Internationalization
  cupertino_icons: ^1.0.8         # iOS icons
```

## 🎮 How to Use

1. **Launch the app** - View your profile stats and today's quest
2. **Tap "Take Photo"** - Open camera or select from gallery
3. **Capture your photo** - Follow the quest guidelines
4. **Submit for rating** - AI analyzes your photo in real-time
5. **View results** - See your score (0-10), XP earned, and AI feedback
6. **Visit Community Feed** - Vote on other users' photos
   - 👍 Like = Give them +5 XP
   - 👎 Dislike = They lose -3 XP
7. **Check leaderboard** - Compare your progress with other users

## 🔧 Configuration

### Backend API Endpoints

The app expects these endpoints on your backend:

**Quests & Submissions:**
- `GET /api/quests/today` - Get today's active quest
- `GET /api/quests` - Get all quests
- `POST /api/submissions` - Submit photo for rating

**Community Voting:**
- `GET /api/submissions/recent?limit=20&excludeUserId=xyz` - Get recent submissions for voting
- `POST /api/votes` - Vote on a photo (like/dislike)
- `DELETE /api/votes?photoId=x&userId=y` - Remove vote

**Leaderboard & Users:**
- `GET /api/leaderboard?limit=100` - Get leaderboard
- `GET /api/users/:userId` - Get user profile
- `POST /api/users` - Register new user

### API Response Formats

**Quest:**
```json
{
  "id": "quest-123",
  "title": "Capture Sunlight",
  "description": "Take a photo of sunlight filtering through trees",
  "topic": "sunlight through trees",
  "startDate": "2025-11-08T00:00:00Z",
  "endDate": "2025-11-09T00:00:00Z",
  "xpReward": 100
}
```

**AI Rating Response:**
```json
{
  "rating": {
    "score": 8.5,
    "feedback": "Great composition! The sunlight effect is well-captured...",
    "isOutdoors": true,
    "matchesTopic": true,
    "xpEarned": 85
  }
}
```

## 📱 Screenshots

*(Add screenshots of your app here)*

## 🎯 Class Project Requirements

✅ **One API per group** - Single PhotoQuest backend API  
✅ **Tech stack flexibility** - Flutter frontend + Node.js backend  
✅ **AI integration** - GPT-4 Vision for photo rating  
✅ **Boilerplate allowed** - Flutter/Express templates used  
✅ **6-minute presentation ready**  
✅ **Deadline compliant** - Sunday @ 12 pm  

## 🤝 Team

**Geaux-Hack-Dish3**

## 📄 License

This project is for educational purposes as part of a class hackathon.

## 🔮 Future Enhancements

- [ ] Social features (friends, photo sharing)
- [ ] Photo gallery history
- [ ] Achievement badges
- [ ] Custom quest creation
- [ ] Push notifications for new quests
- [ ] Offline mode support

---

**Happy questing! 🌟📸**
