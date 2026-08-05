import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/core/services/branding_service.dart';
import '../lib/core/widgets/app_button.dart';
import '../lib/theme/app_theme.dart';

void main() {
  testWidgets('theme minimumSize is finite', (tester) async {
    final theme = AppTheme.fromBranding(AppBranding.fallback);
    final minSize = theme.elevatedButtonTheme.style?.minimumSize?.resolve({});
    expect(minSize, isNotNull);
    expect(minSize!.width.isFinite, isTrue,
        reason: 'minimumSize width must be finite, got $minSize');
  });

  testWidgets('ghost button survives unbounded width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.fromBranding(AppBranding.fallback),
        home: UnconstrainedBox(
          child: AppButton.ghost(
            label: 'Skip',
            onPressed: () {},
            isFullWidth: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final error = tester.takeException();
    expect(error, isNull, reason: 'no layout exception expected: $error');
  });
}
