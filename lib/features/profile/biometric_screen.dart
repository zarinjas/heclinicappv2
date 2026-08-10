import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../core/services/biometric_auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_app_bar.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key});

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  final _bio = BiometricAuthService.instance;

  bool _loading = true;
  bool _busy = false;
  bool _available = false;
  bool _enabled = false;
  String _label = 'Biometrics';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await _bio.isAvailable();
    final enabled = available && await _bio.isEnabled();
    final label = available ? await _bio.biometricLabel() : 'Biometrics';

    if (!mounted) return;
    setState(() {
      _available = available;
      _enabled = enabled;
      _label = label;
      _loading = false;
    });
  }

  Future<void> _onToggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      if (value) {
        final token = FFAppState().tokenauth;
        if (token.isEmpty) {
          _snack('Please sign in again before enabling $_label login.');
          return;
        }

        // enable() runs a real biometric prompt and only stores the session
        // token in the keystore once the user passes it.
        final ok = await _bio.enable(token: token);
        if (!mounted) return;

        setState(() => _enabled = ok);
        FFAppState().fingerprint = ok;
        _snack(ok
            ? '$_label login enabled.'
            : 'Could not verify your identity. $_label login is still off.');
      } else {
        await _bio.disable();
        if (!mounted) return;

        setState(() => _enabled = false);
        FFAppState().fingerprint = false;
        _snack('$_label login disabled.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;
    final tc = isDark ? AppColors.textPrimaryDark : AppColors.primary;
    final sc = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppAppBar.sub(title: 'Biometric Login'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    _label.contains('Face')
                        ? Icons.face_retouching_natural
                        : Icons.fingerprint,
                    size: 80,
                    color: _available ? AppColors.accent : sc,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _available ? '$_label Login' : 'Biometric Login',
                    style: AppTextStyles.heading2.copyWith(color: tc),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _available
                        ? 'Log in quickly and securely using $_label. '
                            'Your password is never stored on this device.'
                        : 'Biometrics are not set up on this device. '
                            'Add a fingerprint or face in your device settings first.',
                    style: AppTextStyles.body1.copyWith(color: sc),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SwitchListTile(
                    title: Text(
                      'Enable Biometric Login',
                      style: AppTextStyles.body1.copyWith(
                        color: _available ? tc : sc,
                      ),
                    ),
                    subtitle: Text(
                      _available
                          ? 'Use $_label to log in'
                          : 'Unavailable on this device',
                      style: AppTextStyles.body2.copyWith(color: sc),
                    ),
                    value: _enabled,
                    activeColor: AppColors.accent,
                    onChanged: (_available && !_busy) ? _onToggle : null,
                    secondary: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                  ),
                  if (_enabled) ...[
                    const SizedBox(height: 8),
                    Text(
                      'This stays on after you log out, so you can sign back in '
                      'with $_label. Turn it off to remove the saved session '
                      'from this device.',
                      style: AppTextStyles.caption.copyWith(color: sc),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
