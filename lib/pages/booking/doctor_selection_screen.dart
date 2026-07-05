import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/env_config.dart';
import 'booking_flow_model.dart';

class DoctorSelectionScreenWidget extends StatefulWidget {
  const DoctorSelectionScreenWidget({super.key});

  static const String routeName = 'doctorSelectionScreen';
  static const String routePath = '/doctorSelectionScreen';

  @override
  State<DoctorSelectionScreenWidget> createState() =>
      _DoctorSelectionScreenWidgetState();
}

class _DoctorSelectionScreenWidgetState
    extends State<DoctorSelectionScreenWidget> {
  final BookingFlowModel _bookingModel = BookingFlowModel();

  List<DoctorItem> _doctors = [];
  String? _selectedDoctorId;
  bool _isNoPreference = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await GetproviderCall.call();
      if (response.succeeded) {
        final ids = GetproviderCall.id(response.jsonBody) ?? [];
        final names = GetproviderCall.name(response.jsonBody) ?? [];
        final nrics = GetproviderCall.nric(response.jsonBody) ?? [];

        final doctors = <DoctorItem>[];
        for (int i = 0; i < ids.length; i++) {
          doctors.add(DoctorItem(
            id: i < ids.length ? ids[i] : '',
            name: i < names.length ? names[i] : '',
            specialty: i < nrics.length ? nrics[i] : '',
          ));
        }

        setState(() {
          _doctors = doctors;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error ${response.statusCode}: Failed to load doctors';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = _getErrorMessage(e);
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    return error?.toString() ?? 'An unexpected error occurred';
  }

  void _onNoPreferenceSelected() {
    setState(() {
      _isNoPreference = true;
      _selectedDoctorId = null;
    });
    _bookingModel.selectDoctor(
      id: '',
      name: 'No Preference',
      isNoPreference: true,
    );
  }

  void _onDoctorSelected(DoctorItem doctor) {
    setState(() {
      _isNoPreference = false;
      _selectedDoctorId = doctor.id;
    });
    _bookingModel.selectDoctor(
      id: doctor.id,
      name: doctor.name,
      isNoPreference: false,
    );
  }

  void _onNextPressed() {
    if (_isNoPreference || _selectedDoctorId != null) {
      context.push('/dateTimeSlotSelection');
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFF00C9A7);
    final stepIndicator = _buildStepIndicator(accentColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1B3D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Book Appointment',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF0F1B3D),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: stepIndicator,
          ),
          Expanded(
            child: _buildBody(accentColor),
          ),
          _buildNextButton(accentColor),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(Color accentColor) {
    final steps = [
      _StepData(1, 'Branch', false),
      _StepData(2, 'Doctor', true),
      _StepData(3, 'Date & Time', false),
      _StepData(4, 'Confirm', false),
    ];

    return Row(
      children: steps.map((step) {
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isActive ? accentColor : Colors.white,
                  border: Border.all(
                    color: step.isActive ? accentColor : Colors.white54,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${step.number}',
                  style: TextStyle(
                    color: step.isActive ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: TextStyle(
                  color: step.isActive ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: step.isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBody(Color accentColor) {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }
    if (_hasError) {
      return _buildErrorState(accentColor);
    }
    if (_doctors.isEmpty) {
      return _buildEmptyState();
    }
    return _buildDoctorList(accentColor);
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFE5E7EB),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Color accentColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFEF4444),
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F1B3D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _loadDoctors,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No doctors available for this branch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F1B3D),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check back later or contact the clinic.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorList(Color accentColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 1 + _doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        if (index == 0) {
          return _buildNoPreferenceCard(accentColor);
        }
        final doctor = _doctors[index - 1];
        final isSelected = _selectedDoctorId == doctor.id;
        return _buildDoctorCard(doctor, isSelected, accentColor);
      },
    );
  }

  Widget _buildNoPreferenceCard(Color accentColor) {
    final isSelected = _isNoPreference;
    return GestureDetector(
      onTap: _onNoPreferenceSelected,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.groups,
                size: 28,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Preference',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F1B3D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'We will find the earliest available slot for you',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorCard(
    DoctorItem doctor,
    bool isSelected,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () => _onDoctorSelected(doctor),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE5E7EB),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: const Color(0xFFE5E7EB),
              child: Text(
                doctor.name.isNotEmpty
                    ? doctor.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F1B3D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (doctor.specialty.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(Color accentColor) {
    final isEnabled = _isNoPreference || _selectedDoctorId != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isEnabled ? _onNextPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isEnabled ? accentColor : const Color(0xFFE5E7EB),
              foregroundColor:
                  isEnabled ? Colors.white : const Color(0xFF9CA3AF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Next',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepData {
  final int number;
  final String label;
  final bool isActive;

  _StepData(this.number, this.label, this.isActive);
}

class DoctorItem {
  final String id;
  final String name;
  final String specialty;

  DoctorItem({
    required this.id,
    required this.name,
    required this.specialty,
  });
}
