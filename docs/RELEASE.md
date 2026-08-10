# Release Guide

Two stores, two different situations:

| | iOS | Android |
|---|---|---|
| Identifier | `com.hemedgroup.heclinicapps` (unchanged) | `com.hemedgroup.heclinic` (**new**) |
| Store action | Version update to the existing listing | **Brand new listing** |
| Reason | Existing App Store listing is fine | Previous Play developer account was blocked |
| Existing users | Get a normal update | Must install the new app manually |

Current version: `1.0.0+38` (see `pubspec.yaml`).

The build number continues from 37 rather than restarting at 1. App Store
Connect rejects any upload whose build number is not higher than the previous
one, and both platforms read this single value.

---

## One-time setup

### 1. Firebase — register the new Android app

The build fails until this is done:

```
No matching client found for package name 'com.hemedgroup.heclinic'
```

`google-services.json` only contains the two old package names, so Firebase
has no configuration for the new one.

1. https://console.firebase.google.com → project **`heclinicapps-8be27`**
2. Project Settings → *Your apps* → **Add app** → **Android**
3. Package name: `com.hemedgroup.heclinic`
4. Add SHA-1 fingerprints (see below)
5. Download the new `google-services.json` → replace `android/app/google-services.json`

Keep the old entries in the file. One `google-services.json` can serve several
package names, and leaving them intact avoids breaking older local branches.

**SHA-1 for debug builds:**

```
BF:53:F9:F1:1F:12:3C:67:57:62:75:98:D0:01:B8:11:67:28:10:99
```

Regenerate at any time with:

```bash
keytool -list -v -keystore ~/.android/debug.keystore \
  -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

Also add the **release** keystore SHA-1 (step 2) and, once Play App Signing is
active, the SHA-1 that Google shows under *Play Console → Setup → App signing*.
Push notifications and any future Google Sign-In will not work on the Play
build without that last one.

### 2. Android release keystore

`android/key.properties` does not exist, so release builds currently fall back
to debug keys. **Play Store rejects debug-signed uploads.**

Generate an upload key — keep it safe, losing it means you cannot update the
app again:

```bash
keytool -genkey -v -keystore ~/heclinic-upload.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/Users/<you>/heclinic-upload.jks
```

This file is gitignored and must never be committed.

Then read its SHA-1 and add it to Firebase as well:

```bash
keytool -list -v -keystore ~/heclinic-upload.jks -alias upload | grep SHA1
```

### 3. iOS — Sign in with Apple

Already enabled on the App ID, and `ios/Runner/Runner.entitlements` carries
`com.apple.developer.applesignin`. To build for a device you still need a
registered device on the team — connect an iPhone and let Xcode generate the
provisioning profile.

### 4. Backend `.env`

```properties
APPLE_CLIENT_IDS=com.hemedgroup.heclinicapps
GOOGLE_CLIENT_IDS=
```

`APPLE_CLIENT_IDS` stays on the **iOS bundle ID** — Apple tokens are issued to
the iOS app, and the Android applicationId change does not affect it.

`GOOGLE_CLIENT_IDS` is empty because Google Sign-In has never been configured
(no OAuth clients exist). The button is hidden in the app via
`SocialLoginConfig.googleEnabled`. **While this is empty the backend skips the
Google audience check**, so fill it in before ever enabling that button.

Apply with `php artisan config:clear`.

---

## Building

```bash
flutter clean && flutter pub get

# Android — App Bundle is what Play wants
flutter build appbundle --release

# iOS
flutter build ipa --release
```

Verify the Android build is not debug-signed before uploading:

```bash
unzip -p build/app/outputs/bundle/release/app-release.aab \
  META-INF/*.RSA | keytool -printcert | grep -i "owner"
```

`Owner: CN=Android Debug` means `key.properties` was missing — do not upload.

---

## Play Store: new listing

Because the applicationId changed, Play treats this as an unrelated app.
Ratings, reviews and install counts do **not** carry over.

1. Play Console → **Create app**
2. Complete Data safety, Content rating, Privacy policy, Target audience
3. Upload the `.aab` to Internal testing first
4. Promote to Production once verified

The app declares `USE_BIOMETRIC`, `CAMERA` and `POST_NOTIFICATIONS`. The Data
safety form must state that biometric data never leaves the device — the app
only asks the OS to verify the user, and stores a session token in the
Android Keystore.

### Existing Android users

They are on the old listing under the blocked account and will not receive
this as an update. They must install the new app and sign in again. There is
no way to migrate them automatically; plan an out-of-band announcement.

---

## What existing users will notice

**Biometric login is reset on both platforms.**

The old build stored the account password base64-encoded in
SharedPreferences, which is encoding rather than encryption. That value is now
purged on first launch. Anyone who used biometric login must:

1. Sign in once with their password (or use *Forgot password*)
2. Re-enable biometric login when prompted

From then on only a session token is kept, inside the Keychain/Keystore, and
the password is never written to the device.

Suggested release note:

> For your security, biometric login needs to be set up again. Sign in once
> with your password and you'll be prompted to re-enable Face ID or
> fingerprint.

---

## Pre-flight checklist

- [ ] Firebase Android app registered for `com.hemedgroup.heclinic`
- [ ] New `google-services.json` in place
- [ ] `android/key.properties` created, keystore backed up somewhere safe
- [ ] Release SHA-1 added to Firebase
- [ ] Play App Signing SHA-1 added to Firebase (after first upload)
- [ ] `APPLE_CLIENT_IDS` set on the production backend
- [ ] Production database backed up
- [ ] `php artisan migrate --pretend` reviewed, then `php artisan migrate`
- [ ] `flutter analyze` reports no errors
- [ ] `flutter test` passes
- [ ] Verified on a real device: Face ID / fingerprint, Sign in with Apple, push
- [ ] Release notes mention the biometric reset
