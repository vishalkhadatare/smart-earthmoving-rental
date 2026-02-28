# Firebase Phone Authentication (OTP) Setup Guide

## Problem
OTP SMS is not being received on your phone when clicking "Send OTP".

## Required Steps to Enable Phone OTP

### 1. ✅ COMPLETED - AndroidManifest.xml Permissions
The following permissions have been added to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```

### 2. 🔴 REQUIRED - Add SHA-1 and SHA-256 Fingerprints to Firebase

Firebase Phone Authentication **REQUIRES** SHA certificates to be added to your Firebase project. Without these, OTP will not be sent.

#### Steps to Add SHA Certificates:

**Step A: Generate SHA Fingerprints**

Open PowerShell in your project directory and run:

```powershell
# For Debug Build (Development)
cd android
./gradlew signingReport
```

This will output SHA-1 and SHA-256 fingerprints. Look for the **debug** variant output like:
```
Variant: debug
Config: debug
Store: C:\Users\YourName\.android\debug.keystore
Alias: androiddebugkey
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:11:22:33:44
SHA-256: 11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF
```

**Step B: Add to Firebase Console**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click the **Settings (gear icon)** → **Project Settings**
4. Scroll to **Your apps** section
5. Find your Android app (com.example.flutter_application_1)
6. Click **Add fingerprint**
7. Copy and paste **both SHA-1 and SHA-256** from the terminal output
8. Click **Save**
9. **IMPORTANT**: Download the new `google-services.json` file
10. Replace `android/app/google-services.json` with the new file

### 3. 🔴 REQUIRED - Enable Phone Authentication in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** → **Sign-in method**
4. Find **Phone** in the list
5. Click **Enable**
6. Click **Save**

### 4. 🔴 REQUIRED - Configure SMS Provider (for Production)

Firebase has different tiers for SMS:

**Test Mode (Free - Limited)**
- Firebase provides free test phone numbers
- Limited to specific test numbers only
- Good for development

**Production Mode (Paid)**
- Requires enabling **Google Cloud Identity Platform**
- Need to set up billing in Google Cloud Console
- SMS charges apply (varies by country)

#### To Use Test Numbers (Free):

1. In Firebase Console → **Authentication** → **Sign-in method** → **Phone**
2. Scroll to **Phone numbers for testing**
3. Add test phone numbers with their verification codes:
   - Phone: `+1234567890` → Code: `123456`
   - Phone: `+919876543210` → Code: `654321`
4. Use these test numbers in your app for development

#### To Enable Real SMS (Production):

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Enable **Identity Platform API**
4. Go to **Billing** → Add payment method
5. Return to Firebase Console
6. Authentication will now send real SMS to any phone number

### 5. Configure Android App Verification

Firebase uses **SafetyNet** or **Google Play Integrity** for app verification:

**Option A: SafetyNet (Deprecated but still works)**
- Requires SHA certificates (Step 2)
- Works automatically once SHA is added

**Option B: Google Play Integrity (Recommended)**
1. In Firebase Console → **Project Settings** → **App Check**
2. Click **Register** for your Android app
3. Select **Play Integrity** as the provider
4. Follow the prompts to enable

### 6. 🔴 REQUIRED - Test on Real Device

**IMPORTANT**: Phone OTP **does not work on emulators** for real SMS. You must:
- Use a **real Android device** connected via USB
- Enable **USB Debugging** on your phone
- Run: `flutter run`
- Select your physical device

**For Emulator Testing**:
- You can only use **test phone numbers** configured in Firebase
- Real SMS will NOT work on emulators

### 7. Verify Your Phone Number Format

The app is configured to send phone numbers in international format:
```
Country Code + Phone Number
Example: +919876543210 (India)
Example: +12345678901 (US)
```

Make sure:
- You select the correct country from dropdown
- Enter phone number WITHOUT the + or country code
- App will automatically combine them

### 8. Check Firebase Quota Limits

Firebase has daily SMS limits:
- **Free Tier**: 10-50 SMS per day (varies by region)
- **Paid Tier**: Higher limits, pay-per-use

If you've exceeded quota:
1. Go to Firebase Console → **Authentication** → **Usage**
2. Check if you've hit the limit
3. Wait 24 hours or enable billing

## Debugging Checklist

If OTP still doesn't arrive, check:

- [ ] SHA-1 and SHA-256 fingerprints added to Firebase Console
- [ ] New `google-services.json` downloaded and replaced in `android/app/`
- [ ] Phone authentication **Enabled** in Firebase Console
- [ ] Testing on a **real Android device** (not emulator)
- [ ] Phone number format is correct (+CountryCode + Number)
- [ ] Not exceeded Firebase SMS quota for the day
- [ ] Internet connection is active on your phone
- [ ] Google Cloud billing enabled (for production SMS)

## Testing Steps

1. **Clean and rebuild the app**:
   ```powershell
   flutter clean
   flutter pub get
   flutter run -d <your-device-id>
   ```

2. **Monitor logs**:
   - Watch the terminal output for Firebase errors
   - Look for "verificationFailed" callbacks

3. **Try a test number first**:
   - Add a test number in Firebase Console
   - Use that test number with its test code
   - If this works, the issue is with production SMS setup

## Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| `app-not-authorized` | SHA certificate missing | Add SHA-1/SHA-256 to Firebase |
| `invalid-phone-number` | Wrong format | Use +CountryCode format |
| `quota-exceeded` | Too many SMS sent | Wait 24h or enable billing |
| `missing-phone-number` | Empty field | Enter phone number |
| `captcha-check-failed` | App verification failed | Add SHA certificates |

## Quick Fix For Testing (Free)

If you need to test immediately without billing:

1. Add test numbers in Firebase Console
2. Use test number: `+15555551234` with code: `123456`
3. Test the flow with this test number
4. Once working, enable billing for real SMS

## Current Code Status

The code implementation is **correct** and ready to use:
- ✅ Country code selector implemented
- ✅ Phone number validation
- ✅ Firebase verifyPhoneNumber called correctly
- ✅ OTP input and verification logic working
- ✅ Error handling implemented

The issue is purely with **Firebase project configuration**, not the code.

## Next Steps

1. **Get SHA certificates**: Run `cd android && ./gradlew signingReport`
2. **Add to Firebase**: Add SHA-1 and SHA-256 in Firebase Console
3. **Download new google-services.json**: Replace in android/app/
4. **Rebuild**: Run `flutter clean && flutter pub get`
5. **Test on real device**: Deploy to physical Android phone
6. **Monitor**: Check terminal for Firebase callback messages

Need help with any step? Let me know!
