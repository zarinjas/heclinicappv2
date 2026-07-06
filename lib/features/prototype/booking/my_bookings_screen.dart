import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/appointment_card.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _showUpcoming = true;

  static const _upcoming = [
    _BookingData('Dr. Ahmad Rizal', 'GP', 'TTDI Branch', '14 Jul 2025', '10:30 AM', StatusChipVariant.confirmed, 'AR', [Color(0xFF2868F5), Color(0xFF131C3C)]),
    _BookingData('Dr. Sarah Lim', 'Cardiologist', 'Bangsar', '20 Jul 2025', '2:00 PM', StatusChipVariant.confirmed, 'SL', [Color(0xFF3B8DFF), Color(0xFF27F5A3)]),
    _BookingData('Dr. Tan Wei Ming', 'Dermatologist', 'PJ', '28 Jul 2025', '11:00 AM', StatusChipVariant.pending, 'TW', [Color(0xFFF5A623), Color(0xFFF54636)]),
  ];

  static const _past = [
    _BookingData('Dr. Wong Mei Ling', 'Pediatrician', 'TTDI', '03 Jun 2025', '9:30 AM', StatusChipVariant.completed, 'WM', [Color(0xFF27F5A3), Color(0xFF2868F5)]),
    _BookingData('Dr. Ahmad Rizal', 'GP', 'TTDI', '15 May 2025', '4:00 PM', StatusChipVariant.completed, 'AR', [Color(0xFF2868F5), Color(0xFF131C3C)]),
  ];

  @override
  Widget build(BuildContext context) {
    final bookings = _showUpcoming ? _upcoming : _past;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Bookings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20, vertical: AppSpacing.space12),
            child: Row(
              children: [
                AppChip(
                  label: 'Upcoming',
                  type: AppChipType.filter,
                  isSelected: _showUpcoming,
                  onTap: () => setState(() => _showUpcoming = true),
                ),
                const SizedBox(width: AppSpacing.space8),
                AppChip(
                  label: 'Past',
                  type: AppChipType.filter,
                  isSelected: !_showUpcoming,
                  onTap: () => setState(() => _showUpcoming = false),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookings.isEmpty
                ? AppEmptyState.noAppointments
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.space20),
                    itemCount: bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
                    itemBuilder: (context, index) {
                      final b = bookings[index];
                      return AppointmentCard(
                        doctorName: b.doctorName,
                        specialty: b.specialty,
                        branchName: b.branchName,
                        date: b.date,
                        time: b.time,
                        status: b.status,
                        doctorInitials: b.doctorInitials,
                        doctorGradient: b.doctorGradient,
                        onTap: () => Navigator.pushNamed(context, '/appointment-detail'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookingData {
  final String doctorName;
  final String specialty;
  final String branchName;
  final String date;
  final String time;
  final StatusChipVariant status;
  final String doctorInitials;
  final List<Color> doctorGradient;

  const _BookingData(this.doctorName, this.specialty, this.branchName, this.date, this.time, this.status, this.doctorInitials, this.doctorGradient);
}
