import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.placeholder,
    this.helperText,
    this.validator,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String? placeholder;
  final String? helperText;
  final String? Function(String?)? validator;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int? maxLines;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final FocusNode _focusNode;
  String? _errorText;
  bool _obscureText = true;
  bool _hasInteracted = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    _obscureText = widget.isPassword;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChange);
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validate();
    }
    setState(() {});
  }

  void _onTextChange() {
    if (_errorText != null) {
      final error = widget.validator?.call(widget.controller.text);
      if (error == null) {
        setState(() {
          _errorText = null;
        });
      }
    }
  }

  void _validate() {
    _hasInteracted = true;
    final error = widget.validator?.call(widget.controller.text);
    setState(() {
      _errorText = error;
    });
  }

  bool get _isDark {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _surfaceBg() {
    if (!widget.enabled) return AppColors.chipFilterDefaultBg;
    return _isDark ? AppColors.inputBgDark : AppColors.surface;
  }

  Color _textColor() {
    return _isDark ? AppColors.textPrimaryDark : AppColors.primary;
  }

  Color _borderColor() {
    if (!widget.enabled) return AppColors.inputBorder;
    if (_errorText != null) return AppColors.inputBorderError;
    if (_focusNode.hasFocus) return AppColors.inputBorderFocus;
    return _isDark ? AppColors.dividerDark : AppColors.inputBorder;
  }

  Color _labelColor() {
    if (!widget.enabled) return AppColors.textSecondary;
    return _isDark ? AppColors.textPrimaryDark : AppColors.primary;
  }

  Color _placeholderColor() {
    return _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordField = widget.isPassword;
    final showHelperText = widget.helperText != null && _errorText == null;
    final isMultiline = widget.maxLines != null && widget.maxLines! > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.label.copyWith(
            color: _labelColor(),
          ),
        ),
        const SizedBox(height: AppSpacing.space12),
        Container(
          height: isMultiline ? null : 52,
          decoration: BoxDecoration(
            color: _surfaceBg(),
            borderRadius: BorderRadius.circular(AppRadius.radiusMD),
            border: Border.all(
              color: _borderColor(),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: isPasswordField ? _obscureText : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: (value) {
              _validate();
              widget.onSubmitted?.call(value);
            },
            maxLines: isMultiline ? widget.maxLines : 1,
            style: AppTextStyles.body1.copyWith(
              color: _textColor(),
            ),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle: AppTextStyles.body1.copyWith(
                color: _placeholderColor(),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space16,
                vertical: 14,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              suffixIcon: isPasswordField
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: _placeholderColor(),
                      ),
                      onPressed: widget.enabled
                          ? () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            }
                          : null,
                    )
                  : null,
            ),
          ),
        ),
        if (_errorText != null) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            _errorText!,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.error,
            ),
          ),
        ] else if (showHelperText) ...[
          const SizedBox(height: AppSpacing.space4),
          Text(
            widget.helperText!,
            style: AppTextStyles.body2.copyWith(
              color: _placeholderColor(),
            ),
          ),
        ],
      ],
    );
  }
}
