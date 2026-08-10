import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Central switch for the social sign-in buttons on the login screen.
///
/// Keeping these here (rather than inline in the widgets) means enabling a
/// provider later is a one-line change in a single, obvious place.
class SocialLoginConfig {
  const SocialLoginConfig._();

  /// Google Sign In is DISABLED until the OAuth clients exist.
  ///
  /// As of now the project is not configured for it:
  ///   * `android/app/google-services.json` contains zero `oauth_client`
  ///     entries for either package name.
  ///   * `ios/Runner/GoogleService-Info.plist` has no `CLIENT_ID`.
  ///   * `ios/Runner/Info.plist` still has the empty
  ///     `<!--FF_REVERSED_CLIENT_ID-->` URL-scheme placeholder.
  ///
  /// With that config missing, `GoogleSignIn().signIn()` cannot return an
  /// `idToken`, so the button is guaranteed to fail. Hiding it is better than
  /// showing a dead control.
  ///
  /// TO RE-ENABLE, once the Google Cloud OAuth clients are created and the
  /// refreshed `google-services.json` / `GoogleService-Info.plist` are in
  /// place (and `REVERSED_CLIENT_ID` is pasted into `Info.plist`):
  ///
  ///   1. Flip this to `true`.
  ///   2. Set `GOOGLE_CLIENT_IDS` in the backend `.env` (comma-separated iOS
  ///      + Web client IDs), then run `php artisan config:clear`.
  ///
  /// Step 2 matters: while `GOOGLE_CLIENT_IDS` is empty the backend skips the
  /// audience check, which would accept a Google id_token minted for any other
  /// application.
  static const bool googleEnabled = false;

  /// Apple Sign In is offered on iOS only.
  ///
  /// Web is excluded deliberately: `SignInWithApple` on web requires a
  /// registered Services ID and redirect URI (`webAuthenticationOptions`),
  /// which this app does not configure.
  ///
  /// macOS is not checked because this project has no `macos/` target — it
  /// ships iOS, Android and web. Including it would only cause the flag to
  /// read `true` on a macOS developer machine (including the Flutter test
  /// host), which misrepresents real device behaviour.
  static bool get appleEnabled {
    if (kIsWeb) return false;
    return Platform.isIOS;
  }

  /// True when at least one provider is available, used to decide whether the
  /// "or continue with" divider should be rendered at all.
  static bool get anyEnabled => googleEnabled || appleEnabled;
}
