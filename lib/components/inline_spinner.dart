import 'package:flutter/material.dart';
import '/theme/app_theme.dart';

class InlineSpinner extends StatelessWidget {
  final double size;

  const InlineSpinner({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
      ),
    );
  }
}
