# 🚀 Quick Start Guide - Add Files to Xcode

**Time Required:** 20 minutes  
**Goal:** Get your Tempestas app building and running

---

## Step-by-Step Visual Guide

### Step 1: Open Xcode (1 minute)
```bash
cd /Users/garygarrison/projects/Tempestas
open Tempestas.xcodeproj
```

Or double-click `Tempestas.xcodeproj` in Finder.

---

### Step 2: Add Source Files (10 minutes)

#### 2.1 Open Add Files Dialog
1. In Xcode's left sidebar (Project Navigator)
2. Find the **"Tempestas"** folder (blue icon)
3. **Right-click** on it
4. Select **"Add Files to Tempestas..."**

```
📁 Tempestas (blue folder)
   ├── TempestasApp.swift
   ├── ContentView.swift
   ├── Item.swift
   └── Assets.xcassets
```

#### 2.2 Select Folders to Add
Navigate to your project folder and select these 5 folders:
- ✅ **Models/**
- ✅ **Services/**
- ✅ **ViewModels/**
- ✅ **Views/**
- ✅ **Extensions/**

**Pro Tip:** Hold ⌘ (Command) key to select multiple folders at once.

#### 2.3 Configure Import Options
In the import dialog, make sure:

| Option | Setting |
|--------|---------|
| "Copy items if needed" | ❌ **UNCHECKED** |
| "Create groups" | ✅ **SELECTED** (not "Create folder references") |
| "Add to targets" | ✅ **Tempestas CHECKED** |

Then click **"Add"**.

#### 2.4 Verify Files Were Added
Your Project Navigator should now look like this:

```
📁 Tempestas
   ├── TempestasApp.swift
   ├── ContentView.swift
   ├── Item.swift
   ├── 📁 Models
   │   ├── CacheEntry.swift
   │   ├── CurrentWeather.swift
   │   ├── DailyForecast.swift
   │   ├── HourlyForecast.swift
   │   ├── UserPreferences.swift
   │   └── WeatherLocation.swift
   ├── 📁 Services
   │   ├── CacheService.swift
   │   ├── LocationService.swift
   │   ├── StorageService.swift
   │   └── WeatherService.swift
   ├── 📁 ViewModels
   │   ├── SettingsViewModel.swift
   │   └── WeatherViewModel.swift
   ├── 📁 Views
   │   ├── AddLocationView.swift
   │   ├── CurrentLocationCard.swift
   │   ├── HomeView.swift
   │   ├── SavedLocationCard.swift
   │   ├── SettingsView.swift
   │   └── WeatherDetailView.swift
   ├── 📁 Extensions
   │   ├── DateFormatter+Extensions.swift
   │   ├── TemperatureFormatter.swift
   │   └── WindFormatter.swift
   └── Assets.xcassets
```

**Total files added: 21**

---

### Step 3: Add Info.plist (2 minutes)

#### 3.1 Add Info.plist to Project
1. Right-click on **"Tempestas"** folder
2. Select **"Add Files to Tempestas..."**
3. Select **"Info.plist"** (in the Tempestas folder)
4. Make sure "Tempestas" target is checked
5. Click **"Add"**

#### 3.2 Configure Info.plist in Target Settings
1. Click on **Tempestas project** (top of Project Navigator)
2. Select **Tempestas target**
3. Go to **"Info"** tab
4. Look for **"Custom iOS Target Properties"**
5. If you see a dropdown that says "Info.plist File", set it to: `Tempestas/Info.plist`

---

### Step 4: Enable WeatherKit Capability (3 minutes)

#### 4.1 Add WeatherKit
1. Still in Tempestas target settings
2. Go to **"Signing & Capabilities"** tab
3. Click **"+ Capability"** button (top left)
4. Type **"WeatherKit"** in search
5. Click **"WeatherKit"** to add it

You should see a new "WeatherKit" section appear.

#### 4.2 Configure Signing
Make sure you're signed in:
1. In **"Signing & Capabilities"** tab
2. Under **"Team"** dropdown
3. Select your Apple Developer account
4. ✅ Check **"Automatically manage signing"**

**Note:** You need a **paid Apple Developer account** ($99/year) for WeatherKit.

---

### Step 5: Build the Project (2 minutes)

#### 5.1 First Build
1. Select a simulator (e.g., **iPhone 15 Pro**)
2. Press **⌘B** (or Product → Build)
3. Wait for build to complete

**Expected Result:** ✅ Build Succeeded

If you see errors, check the troubleshooting section below.

---

### Step 6: Run the App (2 minutes)

#### 6.1 Launch App
1. Press **⌘R** (or Product → Run)
2. Wait for simulator to launch
3. App should open

#### 6.2 Grant Location Permission
When prompted:
1. Select **"Allow While Using App"**
2. Wait a moment for location to be detected
3. Weather should load!

**Expected Result:** ✅ App running with weather data

---

## 🎉 Success Checklist

After completing all steps, you should see:

- ✅ App launches without crashing
- ✅ Location permission requested
- ✅ Current location weather displayed
- ✅ Can tap "Add Location" to search
- ✅ Can open Settings
- ✅ Weather data is real (from WeatherKit)

---

## 🐛 Troubleshooting

### Build Error: "No such module 'WeatherKit'"
**Solution:** 
1. Go to Signing & Capabilities
2. Make sure WeatherKit capability is added
3. Make sure you're signed in with Apple Developer account
4. Clean build folder: Product → Clean Build Folder (⌘⇧K)

### Build Error: "Cannot find 'WeatherLocation' in scope"
**Solution:** 
1. Make sure all files are added to Tempestas target
2. Check each file in Project Navigator
3. Click on file, check "Target Membership" in File Inspector (right sidebar)
4. Make sure "Tempestas" is checked

### Runtime Error: "Location services not authorized"
**Solution:** 
1. In Simulator: Features → Location → Custom Location
2. Enter coordinates (e.g., 37.7749, -122.4194 for San Francisco)
3. Or allow location in Settings app

### WeatherKit Error: "Unauthorized"
**Solution:** 
1. Make sure you have a paid Apple Developer account
2. Make sure WeatherKit capability is added
3. Make sure Bundle ID is registered in developer portal
4. Try running on a real device (WeatherKit has better support)

### App Crashes on Launch
**Solution:** 
1. Check Xcode console for error messages
2. Make sure Info.plist is properly linked
3. Make sure all files compiled successfully
4. Try Clean Build Folder (⌘⇧K) and rebuild

---

## 📝 Quick Command Reference

| Action | Shortcut |
|--------|----------|
| Build | ⌘B |
| Run | ⌘R |
| Clean Build Folder | ⌘⇧K |
| Open Project Navigator | ⌘1 |
| Open File Inspector | ⌘⌥1 |

---

## 🎯 What to Test After Setup

1. **Current Location Weather**
   - [ ] Temperature displays correctly
   - [ ] Weather icon shows
   - [ ] High/Low temperatures visible
   - [ ] "Feels like" temperature shown

2. **Add Location**
   - [ ] Search for "New York"
   - [ ] Results appear
   - [ ] Can add location (up to 3)
   - [ ] Location appears on home screen

3. **Settings**
   - [ ] Can change temperature unit (°F/°C)
   - [ ] Unit changes reflected immediately
   - [ ] Can change wind speed unit
   - [ ] Can change time format

4. **Pull to Refresh**
   - [ ] Pull down on home screen
   - [ ] Loading indicator appears
   - [ ] Weather data refreshes
   - [ ] "Updated Xm ago" timestamp updates

---

## 🚀 Next Steps After Setup

Once the app is running:

1. **Test all features thoroughly**
2. **Check WeatherKit API usage** (in Apple Developer portal)
3. **Add navigation** from HomeView to WeatherDetailView
4. **Implement SavedLocationCard weather fetching**
5. **Add error handling UI**
6. **Polish animations and transitions**
7. **Test on real device**
8. **Add app icon**
9. **Test accessibility features**
10. **Prepare for TestFlight**

---

## 💡 Pro Tips

1. **Save WeatherKit API calls**: The app has caching built in, but avoid unnecessary refreshes during development

2. **Test on real device**: WeatherKit works better on actual iPhones vs. simulators

3. **Monitor console**: Watch Xcode console for any errors or warnings

4. **Use breakpoints**: Set breakpoints in WeatherService to debug API calls

5. **Check cache**: The app caches data—if weather seems stale, clean app data or wait for cache to expire

---

## 📞 Need Help?

If you run into issues:

1. Check the **APP_STATUS.md** file for detailed status
2. Review **IMPLEMENTATION_GUIDE.md** for architecture details
3. Check Xcode console for error messages
4. Verify all requirements are met (paid Apple Developer account, etc.)

---

**Ready to start?** Follow the steps above and you'll have a working weather app in 20 minutes! 🎉

**Current Time Investment:**
- ✅ Planning & Design: Complete
- ✅ Code Implementation: Complete
- ⏱️ Xcode Integration: 20 minutes (this guide)
- ⏱️ Testing & Polish: 2-4 hours
- ⏱️ App Store Prep: 1-2 hours

**Total to working MVP: ~20 minutes from now!**
