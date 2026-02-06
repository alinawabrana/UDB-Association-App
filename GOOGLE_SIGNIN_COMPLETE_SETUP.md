# 🔧 Complete Google Sign-In Setup Guide

## 🚨 **Current Issue**
You're getting "Account reauth failed" because Google Sign-In is not properly configured. You need:

1. ✅ **Google Cloud Console project**
2. ✅ **OAuth credentials (Android + Web)**
3. ✅ **google-services.json file**
4. ✅ **Updated client ID in code**

---

## 📋 **Step-by-Step Setup**

### **Step 1: Create Google Cloud Project**

1. **Go to [Google Cloud Console](https://console.cloud.google.com/)**
2. **Create a new project**:
   - Click "Select a project" → "New Project"
   - Name: "UDB Association" (or any name)
   - Click "Create"

### **Step 2: Enable Google Sign-In API**

1. **Go to "APIs & Services" → "Library"**
2. **Search for "Google Sign-In API"**
3. **Click "Enable"**

### **Step 3: Get SHA-1 Fingerprint**

Run this command in your terminal:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Copy the SHA-1 fingerprint** (it looks like: `AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD`)

### **Step 4: Create OAuth Credentials**

1. **Go to "APIs & Services" → "Credentials"**
2. **Click "Create Credentials" → "OAuth 2.0 Client IDs"**

#### **A. Create Android Client ID:**
- **Application type**: Android
- **Name**: "UDB Association Android"
- **Package name**: `com.example.udb_association`
- **SHA-1 certificate fingerprint**: (paste the SHA-1 from Step 3)
- **Click "Create"**

#### **B. Create Web Client ID:**
- **Application type**: Web application
- **Name**: "UDB Association Web"
- **Authorized redirect URIs**: (leave empty for now)
- **Click "Create"**

### **Step 5: Download google-services.json**

1. **Go to "APIs & Services" → "Credentials"**
2. **Find your Android client ID**
3. **Click the download button** (⬇️ icon)
4. **Save the file as `google-services.json`**
5. **Place it in**: `android/app/google-services.json`

### **Step 6: Update Android Build Configuration**

Add Google Services plugin to your `android/app/build.gradle.kts`:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}

// Add this at the bottom of the file:
apply(plugin = "com.google.gms.google-services")
```

### **Step 7: Update Project-Level Build Configuration**

Add Google Services classpath to `android/build.gradle.kts`:

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0") // Add this line
    }
}
```

### **Step 8: Update Your Client ID**

1. **Copy your Web Client ID** from Google Console
2. **Replace the placeholder** in `lib/src/config/google_config.dart`:

```dart
class GoogleConfig {
  // Replace with your actual Web client ID from Google Console
  static const String serverClientId = 'YOUR_ACTUAL_WEB_CLIENT_ID_HERE.apps.googleusercontent.com';
  
  static const List<String> scopes = ['email', 'profile'];
}
```

### **Step 9: Clean and Rebuild**

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🧪 **Testing**

After setup, test Google Sign-In:

1. **Run the app**
2. **Click "Continue with Google"**
3. **Select your Google account**
4. **Should redirect to home screen**

---

## 🔍 **Troubleshooting**

### **If you still get "Account reauth failed":**

1. **Check SHA-1 fingerprint** - Make sure it matches your debug keystore
2. **Verify package name** - Must be exactly `com.example.udb_association`
3. **Check google-services.json** - Make sure it's in the right location
4. **Clear app data** - Uninstall and reinstall the app

### **If you get "Client configuration error":**

1. **Check serverClientId** - Must be your Web client ID, not Android client ID
2. **Verify Google Services plugin** - Make sure it's added to build.gradle

### **Common Issues:**

- ❌ **Wrong SHA-1**: Use debug keystore SHA-1, not release keystore
- ❌ **Wrong package name**: Must match `applicationId` in build.gradle
- ❌ **Missing google-services.json**: File must be in `android/app/`
- ❌ **Wrong client ID**: Use Web client ID for `serverClientId`

---

## 📞 **Need Help?**

If you're still having issues:

1. **Check Google Console** - Make sure all credentials are created
2. **Verify file locations** - google-services.json in correct place
3. **Test with different Google account** - Sometimes account-specific issues occur
4. **Check Android logs** - Look for specific error messages

The key is getting the **SHA-1 fingerprint** and **package name** exactly right in Google Console!
