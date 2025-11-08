# Backend Quick Start Guide

## 🚨 SECURITY FIRST!

**YOU POSTED YOUR API KEY PUBLICLY!** Do this NOW:

1. Go to: https://platform.openai.com/api-keys
2. Find key ending in `...6HFPs_8A` 
3. Click **"Revoke"** or **Delete** button
4. Create a **new key**
5. Keep the new key private!

---

## ⚡ Quick Setup (5 Minutes)

### 1. Install Node.js Dependencies

```powershell
# In this directory (Front-End folder)
npm install express multer openai cors dotenv
```

### 2. Create .env File

```powershell
# Copy template
Copy-Item .env.template .env

# Edit .env file and add your NEW API key:
# OPENAI_API_KEY=sk-proj-your-NEW-key-here
```

### 3. Start Backend Server

```powershell
node server.js
```

You should see:
```
🚀 PhotoQuest Backend Server running on port 3000
📸 Ready to analyze outdoor photos with AI!
```

### 4. Update Flutter App

```dart
// lib/config/app_config.dart
static const String apiBaseUrl = 'http://localhost:3000/api';
```

### 5. Test the App!

```powershell
# In a new terminal
flutter run
```

---

## 🤖 How It Works Now

The AI **ONLY determines if the photo is outdoors** (no manual rating):

### AI Response:
```json
{
  "isOutdoors": true,
  "confidence": "high",
  "reasoning": "Clear sky and natural trees visible, clearly outdoor setting",
  "matchesTopic": true,
  "feedback": "Nice outdoor nature photo!"
}
```

### XP Rewards:
- ✅ **Outdoor + Matches Topic** = 100 XP
- ⚠️ **Outdoor + Wrong Topic** = 70 XP  
- ❌ **Indoor Photo** = 20 XP (quest failed)

### The AI Looks For:

**Outdoor Indicators:**
- Sky, clouds, sun
- Natural lighting
- Trees, grass, plants
- Landscapes, horizons
- Outdoor structures

**Indoor Indicators:**
- Walls, ceilings
- Artificial lights
- Indoor furniture
- Windows (you're inside)
- Interior rooms

---

## 🧪 Testing

### Test Outdoor Photo:
```powershell
# Take photo of sky, trees, park → Should detect as outdoor
```

### Test Indoor Photo:
```powershell
# Take photo of plant by window → Should detect as indoor (strict)
```

### Check Logs:
```powershell
# Server will print AI responses:
# AI Response: { isOutdoors: true, confidence: "high", ... }
```

---

## 🔒 Security Checklist

- [ ] Revoked old API key from chat
- [ ] Created new API key
- [ ] Added new key to .env file
- [ ] .env is in .gitignore
- [ ] Never commit .env to GitHub
- [ ] Set billing limit on OpenAI dashboard

---

## 📁 Files You Have

- `server.js` - Backend server with AI detection
- `.env.template` - Template for environment variables
- `.env` - Your actual secrets (CREATE THIS!)
- `BACKEND_GUIDE.md` - Full documentation

---

## ❓ Troubleshooting

**Error: "Invalid API key"**
- Revoke old key and create new one
- Check .env file has correct format
- Restart server after editing .env

**Error: "Module not found"**
- Run: `npm install express multer openai cors dotenv`

**Photos not analyzing**
- Check server is running on port 3000
- Check Flutter app has correct apiBaseUrl
- Check server logs for errors

---

## 🎉 You're Ready!

1. ✅ Revoke old API key
2. ✅ Create new key → add to .env
3. ✅ Run: `npm install`
4. ✅ Run: `node server.js`
5. ✅ Run: `flutter run` (in new terminal)
6. ✅ Take outdoor photo → AI detects it automatically!

**No more manual ratings - AI does everything!** 🤖
