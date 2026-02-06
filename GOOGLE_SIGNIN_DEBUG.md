# Google Sign-In Debug Guide

## Current Issue
The logs show that credentials are being cleared immediately after Google Sign-In attempts, causing authentication to fail.

## Possible Causes

### 1. Missing Google Services Configuration
- **Check**: Is `google-services.json` properly placed in `android/app/`?
- **Check**: Is the `google-services` plugin added to `android/app/build.gradle`?

### 2. Incorrect Client ID Configuration
- **Check**: Is the `serverClientId` in `google_config.dart` correct?
- **Check**: Does the client ID match the one in Google Console?

### 3. Android Manifest Issues
- **Check**: Are the required permissions added to `android/app/src/main/AndroidManifest.xml`?

### 4. Google Console Configuration
- **Check**: Is the app properly configured in Google Cloud Console?
- **Check**: Are the SHA-1 fingerprints added correctly?

## Debug Steps

1. **Check Google Services File**:
   ```bash
   ls -la android/app/google-services.json
   ```

2. **Check Build Gradle**:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

3. **Check Client ID**:
   - Open `lib/src/config/google_config.dart`
   - Verify the `serverClientId` is correct

4. **Test with Minimal Configuration**:
   - Try with a simple Google Sign-In setup
   - Remove any custom configuration

## Next Steps
If the issue persists, we may need to:
1. Reconfigure Google Sign-In from scratch
2. Check Android-specific Google Sign-In setup
3. Verify Google Console configuration
