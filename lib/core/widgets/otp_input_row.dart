import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class OtpInputRow extends StatefulWidget {
  const OtpInputRow({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.hasError = false,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool hasError;

  @override
  State<OtpInputRow> createState() => _OtpInputRowState();
}

class _OtpInputRowState extends State<OtpInputRow> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final List<String> _digits;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _digits = List.filled(widget.length, '');
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onPaste(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length == widget.length) {
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = digits[i];
        _digits[i] = digits[i];
      }
      _notifyChanged();
      _focusNodes[widget.length - 1].requestFocus();
      final otp = _digits.join();
      if (otp.length == widget.length) {
        widget.onCompleted?.call(otp);
      }
    }
  }

  void _onChanged(String value, int index) {
    if (value.length > 1) {
      _onPaste(value);
      return;
    }

    if (value.isNotEmpty) {
      _digits[index] = value.characters.last;
      _controllerText(index);
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      _digits[index] = '';
    }
    _notifyChanged();

    final otp = _digits.join();
    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _digits[index].isEmpty &&
        index > 0) {
      _controllers[index - 1].text = '';
      _digits[index - 1] = '';
      _notifyChanged();
      _focusNodes[index - 1].requestFocus();
      _controllerText(index - 1);
    }
  }

  void _controllerText(int index) {
    final controller = _controllers[index];
    final text = _digits[index];
    controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _notifyChanged() {
    widget.onChanged?.call(_digits.join());
  }

  Color _borderColor(bool isFocused) {
    if (widget.hasError) return AppColors.error;
    if (isFocused) return AppColors.accent;
    return AppColors.inputBorder;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxBg = isDark ? AppColors.surfaceDark : AppColors.surface;
    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 52,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyEvent(event, index),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: boxBg,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  borderSide: const BorderSide(color: AppColors.inputBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
              ),
              style: AppTextStyles.heading3.copyWith(color: textColor),
              onChanged: (value) => _onChanged(value, index),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        );
      }),
    );
  }
}
