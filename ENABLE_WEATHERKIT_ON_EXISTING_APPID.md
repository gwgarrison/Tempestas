# App ID Already Exists - Enable WeatherKit

**Issue:** `An App ID with Identifier 'com.manicmutt.Tempestas' is not available`  
**Meaning:** ✅ The App ID already exists in your Apple Developer Portal  
**Solution:** Enable WeatherKit on the existing App ID

---

## ✅ Steps to Enable WeatherKit on Existing App ID

### 1. Find Your Existing App ID

1. **Go to:** https://developer.apple.com/account
2. **Sign in** with your Apple Developer account
3. **Click:** "Certificates, Identifiers & Profiles"
4. **Click:** "Identifiers" (in the left sidebar)
5. **Look for:** `com.manicmutt.Tempestas` in the list
   - You should see it listed
   - Click on it to open the details

### 2. Enable WeatherKit

Once you open the App ID details:

1. **Scroll down** through the list of capabilities
2. **Find:** "WeatherKit" in the list
3. **Check the box** next to "WeatherKit" ✅
4. **Click:** "Save" button (top right)
5. **Confirm** by clicking "Save" again in the dialog

**That's it!** WeatherKit is now enabled on your App ID.

---

## 🔧 Update Xcode Configuration

Now that WeatherKit is enabled in the Portal, update Xcode:

### Step 1: Remove WeatherKit Capability

1. Open Xcode
2. Select **Tempestas** project in Project Navigator
3. Select **Tempestas** target
4. Go to **"Signing & Capabilities"** tab
5. Find **"WeatherKit"** section
6. Click the **"X"** button to remove it

### Step 2: Clean Build

1. In Xcode menu: **Product → Clean Build Folder** (⌘⇧K)
2. Wait for it to complete

### Step 3: Re-add WeatherKit Capability

1. Still in **"Signing & Capabilities"** tab
2. Click **"+ Capability"** button (top left)
3. Search for **"WeatherKit"**
4. Click **"WeatherKit"** to add it
5. Make sure your **Team** is selected in the Signing section

### Step 4: Delete DerivedData (Important!)

Close Xcode and run this command:

```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Tempestas-*
```

This clears Xcode's cache so it gets the new entitlement configuration.

### Step 5: Rebuild

1. **Reopen** Xcode
2. **Build** the project (⌘B)
3. **Run** the app (⌘R)

---

## 📱 Try on Real Device (Highly Recommended)

Simulators can be unreliable with WeatherKit authentication. If you have an iPhone:

1. **Connect** your iPhone via USB cable
2. **Unlock** the iPhone and trust the computer if prompted
3. In Xcode, **select your iPhone** from the device dropdown (next to the play button)
4. **Build and Run** (⌘R)
5. On iPhone, tap **"Trust"** if it asks about the developer

Real devices have **much better** WeatherKit authentication!

---

## ⏱️ Wait 5-10 Minutes (If Still Not Working)

After enabling WeatherKit in the Developer Portal:
- Apple's servers need time to propagate the changes
- Usually takes 5-10 minutes
- Sometimes up to 15 minutes

**What to do while waiting:**
1. Close Xcode completely
2. Wait 10 minutes
3. Delete DerivedData again: `rm -rf ~/Library/Developer/Xcode/DerivedData/Tempestas-*`
4. Reopen Xcode and try again

---

## ✅ Expected Result After Fix

Once properly configured, the console should show:

```
🔍 Starting location setup...
📍 Location authorization status: 3
✅ Got location: 37.7749, -122.4194
📍 Updating current location...
🌤️ Fetching weather for: Current Location
🌐 Fetching current weather from WeatherKit...
✅ Got current weather: 68.5°
🌐 Fetching hourly forecast...
✅ Got 10 hourly forecasts
🌐 Fetching daily forecast...
✅ Got 3 daily forecasts
🏁 Weather fetch complete. Loading: false
```

**No more JWT authentication errors!**

---

## 🔍 Verify WeatherKit is Enabled

To confirm WeatherKit is enabled on your App ID:

1. Go back to https://developer.apple.com/account
2. Click "Identifiers"
3. Click on `com.manicmutt.Tempestas`
4. Look for "WeatherKit" in the list
5. It should show: **"WeatherKit ✓"** (with a checkmark)

If you don't see the checkmark, it's not enabled yet!

---

## 🎯 Quick Checklist

- [ ] Found `com.manicmutt.Tempestas` in Apple Developer Portal
- [ ] Opened the App ID details
- [ ] Checked the box next to "WeatherKit"
- [ ] Clicked "Save"
- [ ] Removed WeatherKit capability in Xcode
- [ ] Cleaned build folder (⌘⇧K)
- [ ] Deleted DerivedData folder
- [ ] Re-added WeatherKit capability in Xcode
- [ ] Rebuilt the app (⌘B)
- [ ] Ran on real device (iPhone) if available
- [ ] Waited 5-10 minutes if still not working

---

## 📊 What This Fixes

**Before:** Apple's WeatherKit servers reject your app because the App ID doesn't have WeatherKit permission

**After:** Apple's servers see that `com.manicmutt.Tempestas` has WeatherKit enabled and allow API calls

**The JWT Error Code 2 means:** "This Bundle ID is not authorized for WeatherKit" - enabling it in the portal fixes this!

---

## 🚨 If Still Getting Error After All Steps

1. **Verify signing:**
   - In Xcode → Signing & Capabilities
   - Make sure "Automatically manage signing" is checked
   - Make sure your Team is selected
   - Look for any signing errors (red text)

2. **Check Apple System Status:**
   - Go to https://developer.apple.com/system-status/
   - Make sure "WeatherKit" shows green (operational)

3. **Try completely different Bundle ID:**
   - Change to `com.manicmutt.TempestasWeather` in Xcode
   - Create NEW App ID in Portal with this name
   - Enable WeatherKit on the new one

4. **Network issues:**
   - Try different WiFi network
   - Try personal hotspot
   - Some corporate/school networks block WeatherKit

---

**Next Action:** Go to Apple Developer Portal → Identifiers → Click `com.manicmutt.Tempestas` → Check "WeatherKit" → Save

Then follow the Xcode steps above to refresh the configuration!
