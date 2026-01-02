# WeatherKit Authentication Error - Code 2 Fix

**Error:** `WeatherDaemon.WDSJWTAuthenticatorServiceListener.Errors Code=2`  
**Meaning:** JWT Authentication failure - WeatherKit cannot authenticate your app  
**Status:** ⚠️ **CONFIGURATION ISSUE - Not a code problem**

---

## What This Error Means

The error `Code=2` from `WDSJWTAuthenticatorServiceListener` means:
- **WeatherKit capability is added** ✅
- **But the authentication/entitlement is not properly configured** ❌

This happens when:
1. Bundle ID doesn't match Apple Developer Portal configuration
2. App ID doesn't have WeatherKit enabled in the portal
3. Provisioning profile doesn't include WeatherKit entitlement
4. Running on simulator with incorrect configuration

---

## Solution Steps

### Step 1: Verify Bundle ID in Apple Developer Portal

1. Go to https://developer.apple.com/account
2. Click "Certificates, Identifiers & Profiles"
3. Click "Identifiers"
4. Find your app's Bundle ID (e.g., `com.yourname.Tempestas`)

**If it doesn't exist, create it:**
- Click "+" to create new Identifier
- Select "App IDs"
- Description: "Tempestas"
- Bundle ID: `com.yourname.Tempestas` (must match Xcode exactly)
- Scroll down and **CHECK "WeatherKit"**
- Click "Continue" and "Register"

**If it exists:**
- Click on it
- Scroll to "WeatherKit"
- Make sure it's **CHECKED**
- If not checked, check it and click "Save"

### Step 2: Verify Bundle ID in Xcode Matches Exactly

1. In Xcode, select Tempestas project
2. Select Tempestas target
3. Go to "General" tab
4. Check "Bundle Identifier" - should be something like: `com.yourname.Tempestas`

**Copy this exact Bundle ID and make sure it matches the one in Apple Developer Portal!**

### Step 3: Fix WeatherKit Entitlement

1. In Xcode, select Tempestas target
2. Go to "Signing & Capabilities" tab
3. **Remove** the existing WeatherKit capability (click the X)
4. Click "+ Capability"
5. Add "WeatherKit" again
6. Make sure your Team is selected in the Signing section

### Step 4: Clean and Rebuild

1. In Xcode menu: Product → Clean Build Folder (⌘⇧K)
2. Close Xcode completely
3. Delete DerivedData:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Tempestas-*
   ```
4. Reopen Xcode
5. Build (⌘B)

### Step 5: Try on a Real Device

**IMPORTANT:** WeatherKit authentication sometimes has issues in simulators.

1. Connect your iPhone via USB
2. In Xcode, select your iPhone as the run destination
3. Build and run (⌘R)
4. Real devices have more reliable WeatherKit authentication

---

## Alternative: Use a Different Bundle ID

If you're still having issues, try creating a completely new Bundle ID:

1. In Xcode, go to General tab
2. Change Bundle Identifier to something unique:
   - `com.[yourname].TempestasWeather`
   - `com.[yourname].WeatherAppTest`
3. Go to Apple Developer Portal
4. Create NEW App ID with this Bundle ID
5. Enable WeatherKit on the new App ID
6. Remove and re-add WeatherKit capability in Xcode
7. Clean and rebuild

---

## Verify Your Configuration

Run this checklist:

**In Xcode:**
- [ ] Bundle ID is set (e.g., `com.yourname.Tempestas`)
- [ ] Signing Team is selected
- [ ] "Automatically manage signing" is checked
- [ ] WeatherKit capability is listed under Signing & Capabilities
- [ ] No signing errors shown

**In Apple Developer Portal:**
- [ ] App ID exists with your Bundle ID
- [ ] WeatherKit is enabled on that App ID
- [ ] You have a paid Developer account ($99/year)

**Both match:**
- [ ] Bundle ID in Xcode = Bundle ID in Portal (exact match!)

---

## Quick Test Command

Check your current Bundle ID:
```bash
cd /Users/garygarrison/projects/Tempestas
grep -A 2 "PRODUCT_BUNDLE_IDENTIFIER" Tempestas.xcodeproj/project.pbxproj | head -5
```

This will show you what Bundle ID Xcode is using.

---

## Why This Happens

WeatherKit uses JWT (JSON Web Token) authentication that requires:
1. Valid Bundle ID registered with Apple
2. WeatherKit entitlement enabled on that Bundle ID
3. Proper signing with your Developer account
4. Matching configuration between Xcode and Apple's servers

The Code=2 error means Apple's WeatherKit servers are **rejecting** the authentication because one of these doesn't match.

---

## Expected Output After Fix

Once properly configured, you should see:
```
🔍 Starting location setup...
📍 Location authorization status: 3
✅ Got location: 37.7749, -122.4194
🌐 Fetching current weather from WeatherKit...
✅ Got current weather: 68.5°
✅ Got 10 hourly forecasts
✅ Got 3 daily forecasts
```

**No more JWT authentication errors!**

---

## If Still Not Working

1. **Check Apple System Status:**
   - Go to https://developer.apple.com/system-status/
   - Verify "WeatherKit" is green (operational)

2. **Wait 10-15 minutes:**
   - After making changes in Developer Portal
   - Apple's servers need time to propagate the changes

3. **Try a different network:**
   - Some corporate/school networks block WeatherKit
   - Try personal hotspot or home wifi

4. **Contact Apple Developer Support:**
   - If everything is configured correctly
   - They can check your account's WeatherKit access

---

**Next Steps:**
1. Verify Bundle ID matches in Xcode and Apple Developer Portal
2. Remove and re-add WeatherKit capability
3. Clean build and rebuild
4. Try on a real device
5. Check Apple Developer Portal that WeatherKit is enabled on your App ID

The code is now correct - this is purely a configuration/entitlement issue!
