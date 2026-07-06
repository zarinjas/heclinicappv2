import 'package:flutter/material.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_spacing.dart';
import '/core/widgets/app_chip.dart';
import '/core/widgets/app_empty_state.dart';
import '/core/widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0;
  static const _tabs = ['Upcoming', 'Past'];

  static const _upcomingAppointments = [
    _AppointmentData(
      doctorName: 'Dr. Ahmad Rizal',
      specialty: 'General Practitioner',
      branchName: 'TTDI',
      date: '14 Jul 2025',
      time: '10:30 AM',
      status: StatusChipVariant.confirmed,
      initials: 'AR',
      gradient: [Color(0xFF2868F5), Color(0xFF131C3C)],
    ),
    _AppointmentData(
      doctorName: 'Dr. Sarah Lim',
      specialty: 'Cardiologist',
      branchName: 'Bangsar',
      date: '20 Jul 2025',
      time: '2:00 PM',
      status: StatusChipVariant.confirmed,
      initials: 'SL',
      gradient: [Color(0xFF3B8DFF), Color(0xFF27F5A3)],
    ),
    _AppointmentData(
      doctorName: 'Dr. Tan Wei Ming',
      specialty: 'Dermatologist',
      branchName: 'PJ',
      date: '28 Jul 2025',
      time: '11:00 AM',
      status: StatusChipVariant.pending,
      initials: 'TW',
      gradient: [Color(0xFFF5A623), Color(0xFFF54636)],
    ),
  ];

  static const _pastAppointments = [
    _AppointmentData(
      doctorName: 'Dr. Wong Mei Ling',
      specialty: 'Pediatrician',
      branchName: 'TTDI',
      date: '03 Jun 2025',
      time: '9:30 AM',
      status: StatusChipVariant.completed,
      initials: 'WM',
    ),
    _AppointmentData(
      doctorName: 'Dr. Ahmad Rizal',
      specialty: 'General Practitioner',
      branchName: 'TTDI',
      date: '15 May 2025',
      time: '4:00 PM',
      status: StatusChipVariant.completed,
      initials: 'AR',
    ),
  ];

  List<_AppointmentData> get _currentList =>
      _selectedTab == 0 ? _upcomingAppointments : _pastAppointments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Appointments'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.space16,
              vertical: AppSpacing.space12,
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < _tabs.length - 1 ? AppSpacing.space8 : 0,
                  ),
                  child: AppChip(
                    label: _tabs[i],
                    type: AppChipType.filter,
                    isSelected: _selectedTab == i,
                    onTap: () => setState(() => _selectedTab = i),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _currentList.isEmpty
                ? AppEmptyState.noAppointments
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    itemCount: _currentList.length,
                    itemBuilder: (context, index) {
                      final a = _currentList[index];
                      final isFirstUpcoming =
                          _selectedTab == 0 && index == 0;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < _currentList.length - 1
                              ? AppSpacing.space12
                              : 0,
                        ),
                        child: AppointmentCard(
                          doctorInitials: a.initials,
                          doctorGradient: a.gradient,
                          doctorName: a.doctorName,
                          specialty: a.specialty,
                          branchName: a.branchName,
                          date: a.date,
                          time: a.time,
                          status: a.status,
                          countdownDueAt: isFirstUpcoming
                              ? DateTime.now().add(const Duration(
                                  days: 2, hours: 14))
                              : null,
                          onTap: () => Navigator.pushNamed(
                              context, '/appointment-detail'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppointmentData {
  final String doctorName;
  final String specialty;
  final String branchName;
  final String date;
  final String time;
  final StatusChipVariant status;
  final String initials;
  final List<Color>? gradient;

  const _AppointmentData({
    required this.doctorName,
    required this.specialty,
    required this.branchName,
    required this.date,
    required this.time,
    required this.status,
    required this.initials,
    this.gradient,
  });
}
