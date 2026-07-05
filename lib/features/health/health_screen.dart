import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/app_chip.dart';
import 'documents_tab.dart';
import 'records_tab.dart';
import 'vitals_tab.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _currentTab = 0;

  static const _tabs = ['Records', 'Vitals', 'Documents'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(
        title: 'Health',
        onBack: () {},
      ),
      body: Column(
        children: [
          _buildTabSwitcher(),
          Expanded(child: _buildTabContent()),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space16,
        AppSpacing.space12,
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isLast = i == _tabs.length - 1;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : AppSpacing.space8),
              child: AppChip(
                label: _tabs[i],
                type: AppChipType.filter,
                isSelected: _currentTab == i,
                onTap: () {
                  if (_currentTab != i) {
                    setState(() => _currentTab = i);
                  }
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent() {
    return IndexedStack(
      index: _currentTab,
      children: const [
        RecordsTab(),
        VitalsTab(),
        DocumentsTab(),
      ],
    );
  }
}
