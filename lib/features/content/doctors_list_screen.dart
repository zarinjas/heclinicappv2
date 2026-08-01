import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/services/doctor_service.dart';
import '../../core/services/models/doctor.dart';
import '../../core/widgets/app_app_bar.dart';
import '../../core/widgets/doctor_card.dart';
import '../../components/doctor_detail_sheet.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  List<Doctor> _doctors = Doctor.fallbackList;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await DoctorService.instance.init();
    if (mounted) setState(() => _doctors = DoctorService.instance.doctors);
  }

  List<Doctor> get _filtered {
    if (_query.isEmpty) return _doctors;
    final q = _query.toLowerCase();
    return _doctors.where((d) =>
      d.name.toLowerCase().contains(q) ||
      d.specialty.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.scaffoldBgDark : AppColors.scaffoldBg;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppAppBar.sub(title: 'Our Doctors'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.radiusMD),
                border: Border.all(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search doctors...',
                        hintStyle: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filtered.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: DoctorCard(
                  variant: DoctorCardVariant.vertical,
                  photoUrl: d.photoUrl,
                  initials: d.initials,
                  avatarGradient: d.avatarGradient,
                  name: d.name,
                  specialty: d.specialty,
                  onTap: () => DoctorDetailSheet.show(
                    context,
                    doctorName: d.name,
                    specialty: d.specialty,
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
