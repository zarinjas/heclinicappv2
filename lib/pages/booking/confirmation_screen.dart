import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/app_state.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'booking_flow_model.dart';

class BookingConfirmationScreenWidget extends StatelessWidget {
  const BookingConfirmationScreenWidget({super.key});

  static const String routeName = 'bookingConfirmation';
  static const String routePath = '/bookingConfirmation';

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      }
    } catch (_) {}
    return time;
  }

  String _getDoctorDisplay(BookingFlowModel model) {
    if (model.isNoPreference) {
      return 'No Preference';
    }
    return model.selectedDoctorName.isNotEmpty
        ? model.selectedDoctorName
        : 'No Preference';
  }

  void _onBookViaWhatsApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'WhatsApp booking will be available in the next update.',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = [
      _StepData(1, 'Branch'),
      _StepData(2, 'Doctor'),
      _StepData(3, 'Date & Time'),
      _StepData(4, 'Confirm'),
    ];

    const accentColor = Color(0xFF00C9A7);

    return Row(
      children: steps.map((step) {
        final isLastStep = step.number == 4;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLastStep ? accentColor : accentColor,
                  border: Border.all(
                    color: accentColor,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                step.label,
                style: TextStyle(
                  color: isLastStep ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight:
                      isLastStep ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final appState = FFAppState();
    final bookingModel = BookingFlowModel();

    final doctorDisplay = _getDoctorDisplay(bookingModel);
    final formattedDate = bookingModel.selectedDate != null
        ? _formatDate(bookingModel.selectedDate!)
        : 'Not selected';
    final formattedTime = bookingModel.selectedTime.isNotEmpty
        ? _formatTime(bookingModel.selectedTime)
        : 'Not selected';
    final patientName = appState.name.isNotEmpty ? appState.name : '—';
    final patientNric = appState.nationalman.isNotEmpty
        ? appState.nationalman
        : '—';

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
            child: _buildStepIndicator(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(
                    bookingModel,
                    doctorDisplay,
                    formattedDate,
                    formattedTime,
                    patientName,
                    patientNric,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoBanner(),
                ],
              ),
            ),
          ),
          _buildBookButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BookingFlowModel model,
    String doctorDisplay,
    String formattedDate,
    String formattedTime,
    String patientName,
    String patientNric,
  ) {
    const primaryColor = Color(0xFF0F1B3D);
    const secondaryColor = Color(0xFF6B7280);
    const dividerColor = Color(0xFFE5E7EB);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Branch',
            model.selectedBranchName.isNotEmpty
                ? model.selectedBranchName
                : '—',
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Doctor',
            doctorDisplay,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Date',
            formattedDate,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Time',
            formattedTime,
            dividerColor,
            secondaryColor,
            primaryColor,
          ),
          _buildSummaryRow(
            'Patient',
            '$patientName, $patientNric',
            dividerColor,
            secondaryColor,
            primaryColor,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    Color dividerColor,
    Color secondaryColor,
    Color primaryColor, {
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF0F1B3D),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 0.5,
            color: dividerColor,
          ),
      ],
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF00C9A7).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00C9A7).withOpacity(0.3),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF00C9A7),
            size: 16,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your preferred slot is not confirmed until our team responds via WhatsApp.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF0F1B3D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookButton() {
    const accentColor = Color(0xFF00C9A7);

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
          child: Builder(
            builder: (context) => ElevatedButton.icon(
              onPressed: () => _onBookViaWhatsApp(context),
              icon: const Icon(Icons.chat, size: 20),
              label: const Text(
                'Book via WhatsApp',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
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

  _StepData(this.number, this.label);
}
