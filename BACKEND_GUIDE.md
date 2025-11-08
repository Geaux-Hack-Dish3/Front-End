# Backend Integration Guide

## Overview
This Flutter app needs to communicate with your Node.js/Express backend that uses OpenAI GPT-4 Vision API.

## Required Backend Setup

### 1. Install Dependencies
```bash
npm install express multer openai cors dotenv
```

### 2. Environment Variables
Create `.env` file:
```
OPENAI_API_KEY=your_openai_api_key_here
PORT=3000
```

### 3. Sample Backend Structure

```javascript
// server.js
const express = require('express');
const multer = require('multer');
const OpenAI = require('openai');
const cors = require('cors');
require('dotenv').config();

const app = express();
const upload = multer({ dest: 'uploads/' });
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

app.use(cors());
app.use(express.json());

// Get today's quest
app.get('/api/quests/today', (req, res) => {
  const quest = {
    id: 'quest-' + Date.now(),
    title: 'Capture Nature',
    description: 'Take a photo of something green in nature',
    topic: 'green nature',
    startDate: new Date().toISOString(),
    endDate: new Date(Date.now() + 24*60*60*1000).toISOString(),
    xpReward: 100
  };
  res.json(quest);
});

// Submit photo for AI rating
app.post('/api/submissions', upload.single('photo'), async (req, res) => {
  try {
    const { userId, questId } = req.body;
    const photoPath = req.file.path;
    
    // Get quest details to know the topic
    // In production, fetch from database
    const questTopic = 'green nature'; // Replace with actual quest topic
    
    // Read image as base64
    const fs = require('fs');
    const imageBuffer = fs.readFileSync(photoPath);
    const base64Image = imageBuffer.toString('base64');
    
    // Call OpenAI Vision API - AI ONLY determines if photo is outdoors (no scoring)
    const response = await openai.chat.completions.create({
      model: "gpt-4o",  // GPT-4 with vision (replaces deprecated gpt-4-vision-preview)
      messages: [
        {
          role: "user",
          content: [
            { 
              type: "text", 
              text: `You are an outdoor detection AI. Analyze this photo and determine ONLY if it was taken outdoors or indoors.

Look for these OUTDOOR indicators:
- Open sky, clouds, sun visible
- Natural outdoor lighting
- Trees, grass, plants in natural environment
- Outdoor landscapes, horizons
- Natural terrain, mountains, water bodies
- Outdoor structures (parks, trails, streets)

Look for these INDOOR indicators:
- Ceilings, walls, interior architecture
- Artificial lighting (lamps, fluorescent lights)
- Indoor furniture and decor
- Windows (means you're inside looking out)
- Interior rooms, hallways

Also check if the photo matches the topic: '${questTopic}'

Return ONLY valid JSON in this exact format:
{
  "isOutdoors": <true or false>,
  "confidence": "<high, medium, or low>",
  "reasoning": "<1-2 sentences explaining why it's outdoor or indoor>",
  "matchesTopic": <true or false>,
  "feedback": "<Brief comment about the photo>"
}

Be strict: If you see any indoor elements (walls, ceilings, indoor lighting), mark as indoor.` 
            },
            {
              type: "image_url",
              image_url: { url: `data:image/jpeg;base64,${base64Image}` }
            }
          ]
        }
      ],
      max_tokens: 300
    });
    
    const aiResponse = JSON.parse(response.choices[0].message.content);
    
    // Calculate XP based on outdoor detection and topic match
    let xpEarned = 50; // Base XP for completing quest
    
    if (aiResponse.isOutdoors && aiResponse.matchesTopic) {
      xpEarned = 100; // Full XP for outdoor photo matching topic
    } else if (aiResponse.isOutdoors && !aiResponse.matchesTopic) {
      xpEarned = 70; // Partial XP - outdoor but wrong topic
    } else {
      xpEarned = 20; // Minimal XP - indoor photo (quest failed)
    }
    
    // Auto-generate score for compatibility (optional)
    const score = aiResponse.isOutdoors ? (aiResponse.matchesTopic ? 9 : 6) : 2;
    
    const rating = {
      score: score, // Auto-calculated based on outdoor detection
      feedback: aiResponse.feedback,
      isOutdoors: aiResponse.isOutdoors,
      confidence: aiResponse.confidence,
      reasoning: aiResponse.reasoning,
      matchesTopic: aiResponse.matchesTopic,
      xpEarned: xpEarned
    };
    
    res.json({ rating });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Failed to rate photo' });
  }
});

// Get leaderboard
app.get('/api/leaderboard', (req, res) => {
  // In production, fetch from database
  const leaderboard = [
    {
      userId: '1',
      username: 'NatureExplorer',
      totalXp: 850,
      rank: 1,
      questsCompleted: 15
    },
    {
      userId: '2',
      username: 'PhotoPro',
      totalXp: 720,
      rank: 2,
      questsCompleted: 12
    }
  ];
  res.json(leaderboard);
});

// Get user
app.get('/api/users/:userId', (req, res) => {
  const user = {
    id: req.params.userId,
    username: 'TestUser',
    email: 'test@example.com',
    totalXp: 100,
    questsCompleted: 1,
    createdAt: new Date().toISOString()
  };
  res.json(user);
});

// Register user
app.post('/api/users', (req, res) => {
  const { username, email } = req.body;
  const user = {
    id: 'user-' + Date.now(),
    username,
    email,
    totalXp: 0,
    questsCompleted: 0,
    createdAt: new Date().toISOString()
  };
  res.json(user);
});

app.listen(process.env.PORT, () => {
  console.log(`Server running on port ${process.env.PORT}`);
});
```

## API Endpoints Reference

### GET /api/quests/today
Returns today's active quest.

**Response:**
```json
{
  "id": "quest-123",
  "title": "Capture Nature",
  "description": "Take a photo of something green",
  "topic": "green nature",
  "startDate": "2025-11-08T00:00:00Z",
  "endDate": "2025-11-09T00:00:00Z",
  "xpReward": 100
}
```

### POST /api/submissions
Submit a photo for AI rating.

**Request:**
- Content-Type: multipart/form-data
- Fields:
  - `userId`: string
  - `questId`: string
  - `photo`: file

**Response:**
```json
{
  "rating": {
    "score": 8.5,
    "feedback": "Beautiful capture of nature...",
    "isOutdoors": true,
    "matchesTopic": true,
    "xpEarned": 85
  }
}
```

### GET /api/leaderboard?limit=100
Get top users on leaderboard.

**Response:**
```json
[
  {
    "userId": "1",
    "username": "NatureExplorer",
    "totalXp": 850,
    "rank": 1,
    "questsCompleted": 15
  }
]
```

### GET /api/users/:userId
Get user profile.

**Response:**
```json
{
  "id": "user-123",
  "username": "PhotoExplorer",
  "email": "user@example.com",
  "totalXp": 500,
  "questsCompleted": 8,
  "createdAt": "2025-11-01T00:00:00Z"
}
```

### POST /api/users
Register a new user.

**Request:**
```json
{
  "username": "NewUser",
  "email": "new@example.com"
}
```

**Response:**
```json
{
  "id": "user-456",
  "username": "NewUser",
  "email": "new@example.com",
  "totalXp": 0,
  "questsCompleted": 0,
  "createdAt": "2025-11-08T12:00:00Z"
}
```

### GET /api/submissions/recent?limit=20&excludeUserId=xyz
Get recent photo submissions for community voting feed.

**Query Parameters:**
- `limit` (optional): Number of submissions to return (default: 20)
- `excludeUserId` (optional): Exclude submissions from this user

**Response:**
```json
[
  {
    "id": "photo-123",
    "userId": "user-456",
    "username": "NatureExplorer",
    "questId": "quest-789",
    "questTitle": "Green Nature",
    "photoUrl": "https://...",
    "submittedAt": "2025-11-08T14:30:00Z",
    "score": 8.5,
    "feedback": "Beautiful capture of vibrant greenery!",
    "xpEarned": 85,
    "likes": 12,
    "dislikes": 2,
    "userVote": null
  }
]
```

### POST /api/votes
Vote on a photo (like or dislike).

**Request:**
```json
{
  "photoId": "photo-123",
  "userId": "user-789",
  "isLike": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Vote recorded",
  "xpChange": 5
}
```

**Vote Logic:**
- Each user can only vote once per photo
- Changing vote (like → dislike or vice versa) is allowed
- Likes give photo owner **+5 XP**
- Dislikes deduct **-3 XP** from photo owner
- Store votes in database with userId + photoId as unique key

### DELETE /api/votes?photoId=photo-123&userId=user-789
Remove a vote from a photo.

**Response:**
```json
{
  "success": true,
  "message": "Vote removed",
  "xpChange": -5
}
```

## OpenAI GPT-4 Vision Integration

### How AI Determines Outdoor Photos

The AI analyzes multiple visual cues to determine if a photo was taken outdoors:

**Detection Factors:**
- **Natural elements**: Sky, clouds, sun, natural lighting
- **Environmental indicators**: Trees, grass, landscapes, horizon lines
- **Architectural clues**: Buildings, outdoor structures vs indoor walls/ceilings
- **Lighting analysis**: Natural daylight vs artificial indoor lighting
- **Spatial depth**: Open spaces typical of outdoors vs enclosed indoor spaces

**Scoring Logic:**
- **Outdoor + Topic Match + Quality**: High scores (7-10) + bonus XP
- **Outdoor but poor topic match**: Medium scores (4-6)
- **Indoor photos**: Low scores (0-3) regardless of topic match
- **Ambiguous cases**: AI uses context clues and defaults to conservative scoring

### Prompt Engineering

The AI prompt is structured to:
1. Explicitly ask AI to determine outdoor setting (not user input)
2. Penalize indoor photos heavily
3. Reward high-quality outdoor photos matching the quest topic
4. Provide constructive feedback explaining the rating

### XP Calculation

```javascript
// Base XP from AI rating
const xpEarned = Math.floor(score * 10);

// Bonus for perfect match
if (isOutdoors && matchesTopic && score >= 8) {
  xpEarned += 20;
}
```

## Community Voting System

### Database Schema for Votes

```javascript
// Vote document/table
{
  id: string,
  userId: string,        // Who voted
  photoId: string,       // Photo being voted on
  isLike: boolean,       // true = like, false = dislike
  createdAt: timestamp
}

// Unique constraint: (userId, photoId) - one vote per user per photo
```

### Vote XP Logic

**When user votes on a photo:**
1. Check if user already voted on this photo
2. If changing vote, revert previous XP change
3. Apply new vote:
   - Like: Add +5 XP to photo owner
   - Dislike: Subtract -3 XP from photo owner
4. Update user's total XP in database
5. Update photo's like/dislike counts

**Implementation Example:**
```javascript
app.post('/api/votes', async (req, res) => {
  const { photoId, userId, isLike } = req.body;
  
  // Get photo to find owner
  const photo = await db.photos.findById(photoId);
  const photoOwnerId = photo.userId;
  
  // Check existing vote
  const existingVote = await db.votes.findOne({ userId, photoId });
  
  let xpChange = 0;
  
  if (existingVote) {
    // Revert old vote
    const oldXP = existingVote.isLike ? 5 : -3;
    await db.users.updateXP(photoOwnerId, -oldXP);
    
    // If same vote, remove it (toggle off)
    if (existingVote.isLike === isLike) {
      await db.votes.delete({ userId, photoId });
      return res.json({ success: true, xpChange: -oldXP });
    }
    
    // Update to new vote
    await db.votes.update({ userId, photoId }, { isLike });
  } else {
    // Create new vote
    await db.votes.create({ userId, photoId, isLike });
  }
  
  // Apply new vote XP
  xpChange = isLike ? 5 : -3;
  await db.users.updateXP(photoOwnerId, xpChange);
  
  // Update photo counts
  await db.photos.updateVoteCounts(photoId);
  
  res.json({ success: true, xpChange });
});
```

### Security Considerations

- Prevent users from voting on their own photos
- Rate limit voting to prevent spam (e.g., max 100 votes per hour)
- Validate userId matches authenticated user
- Prevent XP manipulation by verifying vote changes

## Testing the Backend

1. Start your backend:
```bash
node server.js
```

2. Test with curl:
```bash
# Get today's quest
curl http://localhost:3000/api/quests/today

# Get leaderboard
curl http://localhost:3000/api/leaderboard
```

3. Update Flutter app config:
```dart
// lib/config/app_config.dart
static const String apiBaseUrl = 'http://localhost:3000/api';
// Or for Android emulator: 'http://10.0.2.2:3000/api'
```

## Deployment

### Backend Deployment (Render/Heroku/Railway)
1. Push backend to GitHub
2. Connect to hosting service
3. Set environment variables (OPENAI_API_KEY)
4. Deploy

### Update Flutter App
```dart
// Use deployed URL
static const String apiBaseUrl = 'https://your-backend.onrender.com/api';
```

## Database Integration (Optional)

For production, add PostgreSQL/MongoDB:

```javascript
// Example with PostgreSQL
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

// Save submission
await pool.query(
  'INSERT INTO submissions (user_id, quest_id, photo_url, score, xp_earned) VALUES ($1, $2, $3, $4, $5)',
  [userId, questId, photoUrl, rating.score, rating.xpEarned]
);
```

## Troubleshooting

### CORS Issues
Make sure backend has:
```javascript
app.use(cors());
```

### Android Network Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### Local Testing on Android Emulator
Use `10.0.2.2` instead of `localhost`:
```dart
static const String apiBaseUrl = 'http://10.0.2.2:3000/api';
```

### iOS Network Security
For HTTP (dev only), update `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```
