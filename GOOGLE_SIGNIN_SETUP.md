# Google Sign-In Setup Guide

## Step 1: Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the Google+ API and Google Sign-In API

## Step 2: Configure OAuth Consent Screen

1. Go to "APIs & Services" > "OAuth consent screen"
2. Choose "External" for testing or "Internal" for organization
3. Fill in the required information:
   - App name: "UDB Association"
   - User support email: your email
   - Developer contact: your email

## Step 3: Create OAuth 2.0 Credentials

1. Go to "APIs & Services" > "Credentials"
2. Click "Create Credentials" > "OAuth 2.0 Client IDs"
3. Choose "Web application" for server client ID
4. Add authorized redirect URIs:
   - For development: `http://localhost:3000`
   - For production: your actual domain

## Step 4: Get Your Client IDs

You'll get two client IDs:
- **Web client ID** (for server): Use this as `serverClientId`
- **Android client ID** (for mobile): Use this in `google-services.json`

## Step 5: Update Configuration

1. Open `lib/src/config/google_config.dart`
2. Replace `YOUR_SERVER_CLIENT_ID_HERE.apps.googleusercontent.com` with your actual Web client ID

## Step 6: Android Configuration

1. Download `google-services.json` from Google Console
2. Place it in `android/app/` directory
3. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## Step 7: iOS Configuration (if needed)

1. Download `GoogleService-Info.plist` from Google Console
2. Place it in `ios/Runner/` directory
3. Add to `ios/Runner/Info.plist`:
   ```xml
   <key>CFBundleURLTypes</key>
   <array>
       <dict>
           <key>CFBundleURLName</key>
           <string>REVERSED_CLIENT_ID</string>
           <key>CFBundleURLSchemes</key>
           <array>
               <string>YOUR_REVERSED_CLIENT_ID</string>
           </array>
       </dict>
   </array>
   ```

## Testing

After configuration, your Google Sign-In should work without the client configuration error.
