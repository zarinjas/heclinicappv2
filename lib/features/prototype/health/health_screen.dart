import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _selectedMain = 0;
  int _selectedRecord = 0;

  static const _mainFilters = ['Records', 'Vitals', 'Profile'];
  static const _recordFilters = [
    'All',
    'Lab',
    'Radiology',
    'MC',
    'Letter',
    'Report',
  ];

  static const _records = [
    _RecordData(
      title: 'X-Ray Report (Chest)',
      doctor: 'Dr. Ahmad Rizal',
      date: '14 Jul 2025',
      type: 'Radiology',
      icon: Icons.image_outlined,
    ),
    _RecordData(
      title: 'Full Blood Count Results',
      doctor: 'Dr. Sarah Lim',
      date: '10 Jul 2025',
      type: 'Lab',
      icon: Icons.science_outlined,
    ),
    _RecordData(
      title: 'Medical Certificate (2 Days)',
      doctor: 'Dr. Tan Wei Ming',
      date: '05 Jul 2025',
      type: 'MC',
      icon: Icons.description_outlined,
    ),
    _RecordData(
      title: 'Referral Letter - Cardiology',
      doctor: 'Dr. Wong Mei Ling',
      date: '03 Jun 2025',
      type: 'Letter',
      icon: Icons.mail_outlined,
    ),
    _RecordData(
      title: 'Annual Health Screening Report',
      doctor: 'Dr. Ahmad Rizal',
      date: '15 May 2025',
      type: 'Report',
      icon: Icons.assignment_outlined,
    ),
    _RecordData(
      title: 'COVID-19 Vaccination Certificate',
      doctor: 'Admin',
      date: '01 Jan 2024',
      type: 'Certificate',
      icon: Icons.verified_outlined,
    ),
  ];

  List<_RecordData> get _filteredRecords {
    if (_selectedRecord == 0) return _records;
    final filterLabel = _recordFilters[_selectedRecord];
    return _records.where((r) => r.type == filterLabel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'My Health',
          style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.scaffoldBg,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main filter chips
            Row(
              children: List.generate(_mainFilters.length, (i) {
                final isSelected = _selectedMain == i;
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _mainFilters.length - 1
                        ? AppSpacing.space8
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedMain = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.space16,
                        vertical: AppSpacing.space8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.divider,
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusFull),
                      ),
                      child: Text(
                        _mainFilters[i],
                        style: AppTextStyles.label.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.space20),
            // Content based on selected tab
            if (_selectedMain == 0) _buildRecordsSection(),
            if (_selectedMain == 1) _buildVitalsSection(),
            if (_selectedMain == 2) _buildProfileSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsSection() {
    final records = _filteredRecords;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Record filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_recordFilters.length, (i) {
              final isSelected = _selectedRecord == i;
              return Padding(
                padding: EdgeInsets.only(
                  right: i < _recordFilters.length - 1
                      ? AppSpacing.space8
                      : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRecord = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: AppSpacing.space4,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius:
                          BorderRadius.circular(AppRadius.radiusFull),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      _recordFilters[i],
                      style: AppTextStyles.caption.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.space16),
        // Records list
        ...records.map((record) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.space12),
              child: _buildRecordCard(record),
            )),
      ],
    );
  }

  Widget _buildRecordCard(_RecordData record) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Opening document...'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.space16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.radiusLG),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.radiusSM),
              ),
              child: Icon(
                record.icon,
                size: 20,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.title,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    '${record.doctor} • ${record.date}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.space8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.space8,
                vertical: AppSpacing.space4,
              ),
              decoration: BoxDecoration(
                color: AppColors.chipFilterDefaultBg,
                borderRadius: BorderRadius.circular(AppRadius.radiusFull),
              ),
              child: Text(
                record.type,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.chipFilterDefaultText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 2x2 grid of vital cards
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                label: 'Heart Rate',
                value: '72 bpm',
                icon: Icons.favorite,
                gradient: const [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _buildVitalCard(
                label: 'Blood Pressure',
                value: '120/80',
                icon: Icons.monitor_heart,
                gradient: const [Color(0xFFF5A623), Color(0xFFF54636)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        Row(
          children: [
            Expanded(
              child: _buildVitalCard(
                label: 'Weight',
                value: '68.5 kg',
                icon: Icons.fitness_center,
                gradient: const [Color(0xFF27F5A3), Color(0xFF2868F5)],
              ),
            ),
            const SizedBox(width: AppSpacing.space12),
            Expanded(
              child: _buildVitalCard(
                label: 'Blood Glucose',
                value: '5.6 mmol/L',
                icon: Icons.water_drop,
                gradient: const [Color(0xFF2868F5), Color(0xFF131C3C)],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.space12),
        Center(
          child: Text(
            'Last updated: 14 Jul 2025',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.space24),
        // Allergies section
        Text(
          'Allergies',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.space12),
        Wrap(
          spacing: AppSpacing.space8,
          runSpacing: AppSpacing.space8,
          children: ['Penicillin', 'Peanuts', 'Shellfish']
              .map((allergy) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                      vertical: AppSpacing.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.chipCancelledBg,
                      borderRadius:
                          BorderRadius.circular(AppRadius.radiusFull),
                    ),
                    child: Text(
                      allergy,
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.chipCancelledText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpacing.space24),
        // Conditions section
        Text(
          'Conditions',
          style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: AppSpacing.space12),
        ...['Hypertension (controlled)', 'Mild Asthma'].map(
          (condition) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.space8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.space12),
                Text(
                  condition,
                  style:
                      AppTextStyles.body1.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVitalCard({
    required String label,
    required String value,
    required IconData icon,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.space16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: AppSpacing.space12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    const profileData = [
      _ProfileRow(label: 'Blood Type', value: 'A+'),
      _ProfileRow(label: 'Height', value: '168 cm'),
      _ProfileRow(label: 'Weight', value: '68.5 kg'),
      _ProfileRow(label: 'NRIC', value: '900101-14-1234'),
      _ProfileRow(
          label: 'Emergency Contact',
          value: 'Ahmad Rahman (+60 12 987 6543)'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.radiusLG),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: List.generate(profileData.length, (i) {
          final row = profileData[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.space16,
                  vertical: AppSpacing.space16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        row.label,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        row.value,
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              if (i < profileData.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.divider,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _RecordData {
  final String title;
  final String doctor;
  final String date;
  final String type;
  final IconData icon;

  const _RecordData({
    required this.title,
    required this.doctor,
    required this.date,
    required this.type,
    required this.icon,
  });
}

class _ProfileRow {
  final String label;
  final String value;

  const _ProfileRow({required this.label, required this.value});
}
