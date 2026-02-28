# 🔥 Firebase Backend Setup Guide

## 📋 Prerequisites

1. **Flutter SDK** - Ensure Flutter is properly installed
2. **Firebase Account** - Create a free Firebase account at https://console.firebase.google.com
3. **Firebase Project** - Create a new project in Firebase console

## 🚀 Setup Instructions

### **1. Create Firebase Project**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project"
3. Enter project name: `heavyequip-pro`
4. Click "Create project"

### **2. Enable Authentication**

1. In Firebase console, go to **Authentication** → **Get started**
2. Enable **Email/Password** authentication
3. Click "Save"

### **3. Setup Firestore Database**

1. Go to **Firestore Database** → **Create database**
2. Choose **Start in test mode**
3. Select a location (choose closest to your users)
4. Click "Create database"

### **4. Configure Firebase for Flutter**

#### **Option A: Using Firebase CLI (Recommended)**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your Flutter project
cd flutter_application_1
firebase init flutter

# Deploy Firebase configuration
firebase deploy --only functions
```

#### **Option B: Manual Configuration**

1. Download Firebase configuration files:
   - Go to Project Settings → General
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)

2. Add to your Flutter project:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```

### **5. Update Flutter Project**

The Firebase service is already implemented in `lib/services/firebase_service.dart` with these features:

- ✅ User Registration
- ✅ User Login/Authentication  
- ✅ User Profile Management
- ✅ Password Reset
- ✅ Firestore Integration
- ✅ Error Handling

## 🔧 Configuration Files

### **android/app/google-services.json**
```json
{
  "project_info": {
    "project_number": "YOUR_PROJECT_NUMBER",
    "project_id": "heavyequip-pro"
  }
}
```

### **ios/Runner/GoogleService-Info.plist**
```xml
<key>FirebaseAppDelegate</key>
<dict>
  <key>ISAnalyticsEnabled</key>
  <false/>
  <key>GoogleAppID</key>
  <string>YOUR_GOOGLE_APP_ID</string>
</dict>
```

## 📱 Testing the App

### **1. Install Dependencies**
```bash
flutter pub get
```

### **2. Run the App**
```bash
flutter run
```

### **3. Test Features**

#### **Registration Test**
1. Open app
2. Click "Sign Up"
3. Enter:
   - Email: `test@example.com`
   - Password: `password123`
   - Name: `Test User`
   - Phone: `1234567890`
4. Click "Sign Up"
5. Should see success message and return to login

#### **Login Test**
1. On login screen, enter:
   - Email: `test@example.com`
   - Password: `password123`
2. Click "Sign In"
3. Should see success message

## 🔍 Firebase Console Verification

### **Check Authentication**
1. Go to Firebase Console → Authentication → Users
2. Verify new users appear after registration

### **Check Firestore Database**
1. Go to Firestore Database
2. Verify `users` collection contains user documents
3. Check document structure matches expected schema

## 📊 Expected Database Schema

### **Users Collection**
```json
{
  "uid": "firebase_user_id",
  "email": "user@example.com",
  "name": "Full Name",
  "phone": "1234567890",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "isActive": true,
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

## 🛡️ Security Rules

### **Firestore Rules**
Add these security rules in Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### **Authentication Rules**
- Email/password authentication enabled
- Email verification (optional but recommended)
- Password strength requirements

## 🚨 Troubleshooting

### **Common Issues**

1. **"Firebase initialization failed"**
   - Check `google-services.json` is in `android/app/`
   - Verify Firebase project configuration
   - Run `flutter clean` then `flutter pub get`

2. **"Authentication failed"**
   - Enable Email/Password auth in Firebase console
   - Check internet connection
   - Verify Firebase project settings

3. **"Firestore permission denied"**
   - Update Firestore security rules
   - Ensure user is authenticated
   - Check collection/document names

4. **"Platform not supported"**
   - Update Flutter SDK
   - Run `flutter doctor`
   - Check platform-specific setup

### **Debug Commands**
```bash
# Check Flutter environment
flutter doctor

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase configuration
flutterfire config
```

## 📱 Production Checklist

- [ ] Firebase project created
- [ ] Authentication enabled
- [ ] Firestore database created
- [ ] Security rules configured
- [ ] Configuration files added
- [ ] App tested on multiple devices
- [ ] Error handling verified
- [ ] Performance optimized

## 🔗 Useful Links

- [Firebase Console](https://console.firebase.google.com)
- [Flutter Firebase Documentation](https://firebase.google.com/docs/flutter/setup)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

## 🎯 Next Steps

After setup is complete:

1. **Test thoroughly** with different user scenarios
2. **Add additional features** like profile pictures, user roles
3. **Implement session management** for persistent login
4. **Add analytics** to track user behavior
5. **Setup CI/CD** for automated deployment

---

**Note**: This Firebase backend replaces the previous Python/Flask backend. All user data will now be stored in Firebase Firestore instead of MongoDB.
