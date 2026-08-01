import 'package:flutter/material.dart';

import '../services/branding_service.dart';

/// Global loading widget.
///
/// Shows the branding loading GIF (uploaded from the admin panel) when
/// available, otherwise falls back to a circular progress indicator.
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size = 96,
    this.color,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final gifUrl = BrandingService.instance.loadingGifUrl;

    if (gifUrl != null && gifUrl.isNotEmpty) {
      return Image.network(
        gifUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallback(context),
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
