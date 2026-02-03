# H2O Water Tracker - Google Play Store Release Guide

## ✅ Release Build Complete

**Release File Location:**
```
c:\Projects\Water Tracker\build\app\outputs\bundle\release\app-release.aab
```

**File Size:** 45.1 MB

---

## 🔐 Important Credentials

### Keystore Information
**⚠️ CRITICAL: Keep these credentials safe - you'll need them for ALL future app updates!**

- **Keystore File:** `c:\Projects\Water Tracker\android\app\upload-keystore.jks`
- **Password File:** `c:\Projects\Water Tracker\android\keystore_password.txt`
- **Password:** `bQWuY9TIxjZKAkaC`
- **Key Alias:** `upload`
- **Certificate Name:** H2O Water Tracker
- **Organization:** Personal Developer
- **Validity:** 10,000 days

### SHA-1 Fingerprints

**Debug SHA-1** (already added to Firebase):
```
8D:7B:A9:28:EF:3D:71:6B:71:8F:2D:3C:0D:86:D4:15:E4:AC:11:AC
```

**Release SHA-1** (⚠️ MUST be added to Firebase):
```
6E:93:8D:22:6F:39:B8:10:0C:E2:9F:77:7F:41:0D:C7:F0:FC:1D:63
```

---

## 🔥 Firebase Configuration - IMPORTANT!

### Add Release SHA-1 to Firebase (Required for Google Sign-In)

1. Go to: https://console.firebase.google.com/project/water-logging-98b3e/settings/general
2. Scroll to "Your apps" section
3. Click on your Android app (`com.saajid.waterlog`)
4. Click "Add fingerprint"
5. Paste the **Release SHA-1**: `6E:93:8D:22:6F:39:B8:10:0C:E2:9F:77:7F:41:0D:C7:F0:FC:1D:63`
6. Click "Save"

**⚠️ Without this step, Google Sign-In will NOT work in production!**

---

## 📱 App Information

- **App Name:** H2O
- **Package Name:** com.saajid.waterlog
- **Version:** 1.0.0 (Build 1)
- **Min SDK:** Android 5.0 (API 21) - via Flutter
- **Target SDK:** Latest (via Flutter)

---

## 📋 Google Play Console Submission Steps

### 1. Create Play Console Account
- Go to: https://play.google.com/console
- Pay one-time $25 registration fee (if not already registered)

### 2. Create New App
1. Click "Create app"
2. **App name:** H2O
3. **Default language:** English (United States)
4. **App or game:** App
5. **Free or paid:** Free

### 3. Set Up App Content
Complete all required sections:

#### Privacy Policy (✅ Complete)
- **File Created**: `PRIVACY_POLICY.md` and `docs/privacy-policy.html`
- **Hosting**: GitHub Pages (see `PRIVACY_POLICY_HOSTING.md` for setup)
- **URL Format**: `https://your-username.github.io/water-tracker/privacy-policy.html`
- **Content Includes**:
  - ✓ Email collection via Google Sign-In
  - ✓ Water intake data storage in Firebase
  - ✓ Google/Firebase authentication details
  - ✓ Data security measures
  - ✓ User rights (access, deletion, export)
  - ✓ Third-party services (Firebase, Google)
  - ✓ Contact information
- **Action Required**: 
  1. Replace `[your-email@example.com]` with your actual email
  2. Push to GitHub and enable Pages (see `PRIVACY_POLICY_HOSTING.md`)
  3. Use the GitHub Pages URL in Play Console

#### App Access
- All features available to all users
- No special access needed

#### Ads
- Does your app contain ads? **No** (unless you've added them)

#### Content Rating
- Complete questionnaire
- App category: **Health & Fitness**

#### Target Audience
- Age group: **18+**
- Appeals to children: **No**

#### Data Safety
Required information about data collection:
- **Location:** No
- **Personal info:** Yes (Email, Name)
- **Health & Fitness:** Yes (Water intake logs)
- **Financial info:** No
- **Photos/videos:** No
- **Device/other IDs:** No

Data handling:
- **Collected:** Email, Name, Water intake data
- **Shared:** No
- **Ephemeral:** No
- **Optional:** Name is optional
- **Purpose:** App functionality, Account management

### 4. Store Listing

#### App Details
- **App name:** H2O
- **Short description:** (50 chars max)
  ```
  Track your daily water intake and stay hydrated
  ```

- **Full description:** (4000 chars max)
  ```
  H2O - Your Personal Hydration Companion

  Stay healthy and hydrated with H2O, the simple and beautiful water tracking app designed for your lifestyle.

  ✨ Key Features:
  • Smart daily hydration goals based on your weight and activity level
  • Quick water logging with customizable cup sizes
  • Beautiful visualizations of your hydration progress
  • 7-day hydration trends and statistics
  • Complete history of all your water intake
  • Personalized reminders to drink water
  • Dark mode design for comfortable viewing
  • Google Sign-In for easy account sync

  📊 Track Your Progress:
  Monitor your daily water intake with intuitive charts and statistics. See your hydration patterns over time and stay motivated to reach your goals.

  🎯 Personalized Goals:
  Set your daily water intake target based on your weight, activity level, and sleep schedule. H2O calculates the perfect hydration goal for you.

  🔔 Smart Reminders:
  Never forget to drink water with customizable reminders. Enable smart tuning to automatically adjust intervals based on your drinking patterns.

  🌙 Beautiful Dark Design:
  Enjoy a modern, iOS-inspired dark theme that's easy on the eyes and looks great on any device.

  📱 Sync Across Devices:
  Sign in with Google to keep your hydration data synced and never lose your progress.

  Start your journey to better hydration today with H2O!
  ```

- **App icon:** Already set (Frame 28.png - 512x512px)

- **Feature graphic:** (Required - 1024w x 500h)
  - Create a banner with app name and tagline
  - Use your brand colors (purple #896CFE, black background)

- **Screenshots:** (Minimum 2, up to 8)
  - Phone screenshots (at least 2)
  - Take screenshots of:
    1. Home screen with hydration status
    2. Stats page with graphs
    3. History page with calendar
    4. Settings page
    5. Onboarding flow (optional)

#### Contact Details
- **Email:** your-email@example.com
- **Website:** (Optional)
- **Phone:** (Optional)

#### Category
- **App category:** Health & Fitness
- **Tags:** water, hydration, health, tracker, fitness

### 5. Upload App Bundle
1. Go to "Production" → "Create new release"
2. Upload: `app-release.aab`
3. Add release notes:
   ```
   Initial release of H2O Water Tracker
   
   Features:
   - Track daily water intake
   - Personalized hydration goals
   - Smart reminders
   - 7-day statistics and trends
   - Complete intake history
   - Google Sign-In support
   - Beautiful dark mode design
   ```

### 6. Content Rating
- Complete the questionnaire
- App will likely receive: **Everyone**

### 7. Pricing & Distribution
- **Countries:** Select all or specific countries
- **Price:** Free
- **Contains ads:** No (unless you added them)

### 8. Review & Publish
- Complete all required tasks (green checkmarks)
- Click "Send for review"
- Wait 1-7 days for Google's review

---

## 🎨 Required Graphics

### App Icon (✅ Complete)
- Size: 512x512px
- Format: PNG (32-bit)
- Already created from Frame 28.png

### Feature Graphic (⚠️ Needed)
- Size: 1024w x 500h
- Format: PNG or JPEG
- No transparency
- Suggestion: Create banner with "H2O" text and water drop icon on dark background

### Screenshots (⚠️ Needed)
- Minimum 2 screenshots
- Dimensions: Between 320px and 3840px
- Format: PNG or JPEG
- Recommended: Take from your phone or emulator

---

## 🔒 Security Reminders

1. **BACKUP your keystore files:**
   - `upload-keystore.jks`
   - `keystore_password.txt`
   - `key.properties`
   - Store in multiple secure locations (cloud backup, external drive)

2. **NEVER:**
   - Commit keystore to Git
   - Share your keystore password
   - Lose your keystore (you can NEVER update your app without it)

3. **Add to .gitignore** (if not already):
   ```
   /android/app/upload-keystore.jks
   /android/key.properties
   /android/keystore_password.txt
   ```

---

## 📝 Post-Launch Checklist

After your app is published:

- [ ] Verify Google Sign-In works in production
- [ ] Test all features with production build
- [ ] Monitor crash reports in Play Console
- [ ] Respond to user reviews
- [ ] Monitor app ratings

---

## 🔄 Future Updates

To release updates:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version name + build number
   ```

2. Build new AAB:
   ```bash
   flutter build appbundle --release
   ```

3. Upload to Play Console
4. Same keystore and signing config will be used automatically

---

## 📞 Support

If you encounter issues:

1. **Build issues:** Check Flutter/Gradle logs
2. **Signing issues:** Verify keystore password and alias
3. **Play Console rejections:** Read rejection reasons carefully
4. **Firebase issues:** Verify SHA-1 fingerprints are added

---

## ✅ Quick Launch Checklist

Before submitting:

- [x] Release AAB built successfully
- [x] Keystore created and backed up
- [ ] Release SHA-1 added to Firebase
- [ ] Feature graphic created (1024x500)
- [ ] Screenshots taken (minimum 2)
- [x] Privacy policy created (needs hosting)
- [x] App description written
- [ ] Content rating completed
- [ ] Data safety form completed
- [ ] All Play Console sections completed

**Good luck with your app launch! 🚀**
