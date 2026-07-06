import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/branch_card.dart';
import '../../../core/widgets/step_indicator.dart';

class BookingBranchScreen extends StatefulWidget {
  const BookingBranchScreen({super.key});

  @override
  State<BookingBranchScreen> createState() => _BookingBranchScreenState();
}

class _BookingBranchScreenState extends State<BookingBranchScreen> {
  int _selectedIndex = -1;

  static const _branches = [
    _BranchData('TTDI Clinic', 'Jalan Burhanuddin Helmi', [Color(0xFF131C3C), Color(0xFF1D2B5F)]),
    _BranchData('Bangsar Village', 'Jalan Telawi 3', [Color(0xFF3B8DFF), Color(0xFF2868F5)]),
    _BranchData('Petaling Jaya', 'Jalan Sultan', [Color(0xFF1D2B5F), Color(0xFF3B8DFF)]),
    _BranchData('Cheras', 'Jalan Peel', [Color(0xFF27F5A3), Color(0xFF2868F5)]),
    _BranchData('Subang Jaya', 'SS15', [Color(0xFFF5A623), Color(0xFFF54636)]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Book Appointment'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.space24,
              AppSpacing.space16,
              AppSpacing.space24,
              AppSpacing.space16,
            ),
            child: const StepIndicator(
              currentStep: 1,
              totalSteps: 4,
              labels: ['Branch', 'Doctor', 'Time', 'Confirm'],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
              itemCount: _branches.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
              itemBuilder: (context, index) {
                final branch = _branches[index];
                return BranchCard(
                  name: branch.name,
                  address: branch.address,
                  leadingGradient: branch.gradient,
                  leadingLabel: 'Clinic',
                  isSelected: _selectedIndex == index,
                  onTap: () => setState(() => _selectedIndex = index),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.space16),
          child: AppButton.primary(
            label: 'Next',
            onPressed: _selectedIndex >= 0
                ? () => Navigator.pushNamed(context, '/booking-doctor')
                : null,
          ),
        ),
      ),
    );
  }
}

class _BranchData {
  final String name;
  final String address;
  final List<Color> gradient;

  const _BranchData(this.name, this.address, this.gradient);
}
