# Community Voting System - Implementation Summary

## ✅ Features Implemented

### 1. **Vote Model** (`lib/models/vote.dart`)
- Tracks individual votes with userId, photoId, and isLike (boolean)
- Includes timestamp for vote tracking
- JSON serialization for API communication

### 2. **Enhanced Photo Submission Model** (`lib/models/photo_submission.dart`)
- Added fields: `username`, `questTitle`, `likes`, `dislikes`, `userVote`
- Computed properties: `totalVotes`, `likeRatio` (percentage)
- Supports tracking current user's vote status

### 3. **API Service Extensions** (`lib/services/api_service.dart`)
- `getRecentSubmissions()` - Fetch community photos for voting
  - Optional parameters: limit, excludeUserId
- `voteOnPhoto()` - Submit like/dislike vote
- `removeVote()` - Remove existing vote (toggle off)

### 4. **Community Feed Screen** (`lib/screens/community_feed_screen.dart`)
- Card-based feed showing recent photo submissions
- User info header with avatar and username
- AI score badge with color coding
- Interactive like/dislike buttons with counts
- Optimistic UI updates (instant feedback)
- Pull-to-refresh functionality
- Vote percentage display
- Empty state for no submissions

### 5. **Results Screen Enhancement** (`lib/screens/results_screen.dart`)
- Added community voting info card
- Displays XP rewards for likes (+5) and dislikes (-3)
- Informs users their photo will appear in community feed

### 6. **Home Screen Integration** (`lib/screens/home_screen.dart`)
- New "Community Feed" button with gradient design
- Prominent placement between user stats and daily quest
- Clear messaging about voting and bonus XP

### 7. **User Model Update** (`lib/models/user.dart`)
- Added `votesReceived` field (total votes on user's photos)
- Added `votesGiven` field (total votes cast by user)
- Future stats tracking capability

### 8. **Backend Documentation** (`BACKEND_GUIDE.md`)
- Complete API endpoint specifications
- Vote logic implementation examples
- Database schema for votes
- XP calculation formulas
- Security considerations

### 9. **README Updates** (`README.md`)
- Community voting feature highlighted
- API endpoints documented
- User flow updated with voting step

## 🎮 How It Works

### User Experience Flow:
1. **Complete a quest** → Submit photo → Get AI rating
2. **Visit Community Feed** → See other users' submissions
3. **Vote on photos** → Like (👍) or Dislike (👎)
4. **Earn from votes** → Receive +5 XP per like, -3 XP per dislike on your photos

### Voting Rules:
- ✅ Can vote once per photo
- ✅ Can change vote (like → dislike or vice versa)
- ✅ Can remove vote by clicking same button again
- ❌ Cannot vote on own photos (excluded from feed)
- ⚡ Instant UI feedback (optimistic updates)

### XP System:
**From AI Rating:**
- Base: score × 10 XP
- Bonus: +20 XP for outdoor photos scoring ≥7 with topic match

**From Community Votes:**
- Each Like received: +5 XP
- Each Dislike received: -3 XP
- Encourages high-quality submissions

## 📡 Backend Requirements

### New Endpoints Needed:

#### `GET /api/submissions/recent?limit=20&excludeUserId=xyz`
Returns recent photo submissions with:
- User info (username, avatar)
- Quest info (title)
- AI rating (score, feedback)
- Vote counts (likes, dislikes)
- Current user's vote status

#### `POST /api/votes`
Request body:
```json
{
  "photoId": "photo-123",
  "userId": "user-456",
  "isLike": true
}
```

Logic:
1. Check for existing vote
2. If exists and same: remove vote, revert XP
3. If exists and different: update vote, adjust XP
4. If new: create vote, apply XP
5. Update photo owner's totalXp
6. Update vote counts on photo

#### `DELETE /api/votes?photoId=x&userId=y`
Removes vote and reverts XP change

### Database Schema:

**Votes Table:**
```javascript
{
  id: string,
  userId: string,      // Voter
  photoId: string,     // Photo being voted on
  isLike: boolean,
  createdAt: timestamp,
  // Unique constraint: (userId, photoId)
}
```

**Photos Table - Add Fields:**
```javascript
{
  ...existing fields,
  likes: number,
  dislikes: number,
  username: string,    // Photo owner's name
  questTitle: string   // Quest name
}
```

## 🔒 Security Considerations

1. **Prevent Self-Voting**: Exclude user's own photos from feed
2. **Rate Limiting**: Max 100 votes per hour per user
3. **Vote Validation**: Ensure userId matches authenticated user
4. **XP Integrity**: Server-side validation of all XP changes
5. **Duplicate Prevention**: Unique constraint on (userId, photoId)

## 🎨 UI/UX Features

- **Color-Coded Scores**: Purple (8+), Green (6+), Orange (4+), Red (<4)
- **Interactive Buttons**: Filled icons for active votes, outlined for inactive
- **Vote Statistics**: Shows like percentage when votes exist
- **Smooth Animations**: Card hover effects, button press feedback
- **Empty States**: Friendly messaging when no content available
- **Error Handling**: Graceful fallback for failed votes with user notification
- **Optimistic Updates**: Instant UI feedback before server confirmation

## 🚀 Testing Checklist

- [ ] Vote on a photo (like)
- [ ] Change vote (like → dislike)
- [ ] Remove vote (click same button)
- [ ] Verify XP changes in real-time
- [ ] Check vote counts update correctly
- [ ] Test pull-to-refresh
- [ ] Verify own photos excluded from feed
- [ ] Test with multiple users
- [ ] Verify empty state displays
- [ ] Test error handling (offline mode)

## 📊 Future Enhancements

- [ ] Vote activity feed
- [ ] Top voted photos showcase
- [ ] Voting streak rewards
- [ ] Voting power based on level
- [ ] Comment system
- [ ] Photo categories/filters
- [ ] Vote notifications
- [ ] Popular photos leaderboard

## 🎓 Class Requirements Met

✅ **Gamification**: Like/dislike voting adds social competition  
✅ **User Engagement**: Community interaction beyond solo quests  
✅ **XP System**: Multiple ways to earn/lose points  
✅ **Social Features**: Users interact and judge each other's work  
✅ **Real-time Feedback**: Instant vote updates  
✅ **Quality Control**: Community moderates content quality  

---

**Ready to implement!** Backend needs to add 3 endpoints, frontend is complete and functional.
