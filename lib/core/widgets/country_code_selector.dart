import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CountryCode {
  final String code;
  final String flag;
  final String name;

  const CountryCode(this.code, this.flag, this.name);

  String get display => '+$code $name';

  static const List<CountryCode> common = [
    CountryCode('60', '🇲🇾', 'Malaysia'),
    CountryCode('62', '🇮🇩', 'Indonesia'),
    CountryCode('65', '🇸🇬', 'Singapore'),
    CountryCode('66', '🇹🇭', 'Thailand'),
    CountryCode('63', '🇵🇭', 'Philippines'),
    CountryCode('673', '🇧🇳', 'Brunei'),
    CountryCode('84', '🇻🇳', 'Vietnam'),
    CountryCode('95', '🇲🇲', 'Myanmar'),
    CountryCode('855', '🇰🇭', 'Cambodia'),
    CountryCode('856', '🇱🇦', 'Laos'),
    CountryCode('91', '🇮🇳', 'India'),
    CountryCode('86', '🇨🇳', 'China'),
    CountryCode('81', '🇯🇵', 'Japan'),
    CountryCode('82', '🇰🇷', 'South Korea'),
    CountryCode('61', '🇦🇺', 'Australia'),
    CountryCode('1', '🇺🇸', 'USA / Canada'),
    CountryCode('44', '🇬🇧', 'United Kingdom'),
    CountryCode('966', '🇸🇦', 'Saudi Arabia'),
    CountryCode('971', '🇦🇪', 'UAE'),
    CountryCode('20', '🇪🇬', 'Egypt'),
  ];

  static CountryCode fromCode(String code) {
    return common.firstWhere(
      (c) => c.code == code,
      orElse: () => common.first,
    );
  }

  static const String defaultCode = '60';
}

class CountryCodeSelector extends StatelessWidget {
  const CountryCodeSelector({
    super.key,
    required this.selectedCode,
    required this.onChanged,
    this.enabled = true,
  });

  final String selectedCode;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = CountryCode.fromCode(selectedCode);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.inputBgDark : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.radiusMD),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.inputBorder,
          width: 1.5,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCode,
          isExpanded: true,
          icon: const Icon(Icons.expand_more, size: 20),
          iconEnabledColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          iconDisabledColor: AppColors.textSecondary,
          style: AppTextStyles.body1.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          ),
          selectedItemBuilder: (context) {
            return CountryCode.common.map((c) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '+${c.code}',
                    style: AppTextStyles.body1.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList();
          },
          items: CountryCode.common.map((c) {
            return DropdownMenuItem<String>(
              value: c.code,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                ),
                child: Text(
                  '${c.flag}  +${c.code}  ${c.name}',
                  style: AppTextStyles.body1.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: enabled
              ? (value) {
                  if (value != null) onChanged(value);
                }
              : null,
        ),
      ),
    );
  }
}
