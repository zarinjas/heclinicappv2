import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:he_clinic/core/config/social_login_config.dart';
import 'package:he_clinic/features/auth/login_screen.dart';

/// Pins the social sign-in gating on the login screen.
///
/// Google is currently disabled because the project has no OAuth clients
/// configured (empty `oauth_client` in google-services.json, no CLIENT_ID in
/// GoogleService-Info.plist). These tests fail loudly if the button is
/// re-enabled without that groundwork, and guard against the divider being
/// left stranded above an empty space.
void main() {
  test('Google stays disabled until OAuth clients are configured', () {
    expect(SocialLoginConfig.googleEnabled, isFalse);
  });

  test('anyEnabled is the union of the provider flags', () {
    expect(
      SocialLoginConfig.anyEnabled,
      SocialLoginConfig.googleEnabled || SocialLoginConfig.appleEnabled,
    );
  });

  testWidgets('no Google button and no dangling divider on the login screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Continue with Google'), findsNothing);

    // The "or continue with" divider must only appear when a provider does.
    expect(
      find.text('or continue with'),
      SocialLoginConfig.anyEnabled ? findsOneWidget : findsNothing,
    );
  });
}
