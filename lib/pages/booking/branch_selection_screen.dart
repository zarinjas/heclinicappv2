import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/env_config.dart';
import 'booking_flow_model.dart';

class BranchSelectionScreenWidget extends StatefulWidget {
  const BranchSelectionScreenWidget({super.key});

  static const String routeName = 'branchSelectionScreen';
  static const String routePath = '/branchSelectionScreen';

  @override
  State<BranchSelectionScreenWidget> createState() =>
      _BranchSelectionScreenWidgetState();
}

class _BranchSelectionScreenWidgetState
    extends State<BranchSelectionScreenWidget> {
  final BookingFlowModel _bookingModel = BookingFlowModel();

  List<BranchItem> _branches = [];
  String? _selectedBranchId;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    if (_bookingModel.selectedBranchId.isNotEmpty) {
      _selectedBranchId = _bookingModel.selectedBranchId;
    }
    _loadBranches();
  }

  Future<void> _loadBranches() async {
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

        final branches = <BranchItem>[];
        for (int i = 0; i < ids.length; i++) {
          branches.add(BranchItem(
            id: i < ids.length ? ids[i] : '',
            name: i < names.length ? names[i] : '',
            address: i < nrics.length ? nrics[i] : '',
            image: '',
            hours: '',
          ));
        }

        setState(() {
          _branches = branches;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error ${response.statusCode}: Failed to load branches';
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

  void _onBranchSelected(BranchItem branch) {
    setState(() {
      _selectedBranchId = branch.id;
    });
    _bookingModel.selectBranch(
      id: branch.id,
      name: branch.name,
      image: branch.image,
      address: branch.address,
      hours: branch.hours,
    );
  }

  void _onNextPressed() {
    if (_selectedBranchId != null) {
      context.push('/doctorSelectionScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    const accentColor = Color(0xFF00C9A7);
    final stepIndicator = _buildStepIndicator(theme, accentColor);

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
            child: _buildBody(theme, accentColor),
          ),
          _buildNextButton(theme, accentColor),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(FlutterFlowTheme theme, Color accentColor) {
    final steps = [
      _StepData(1, 'Branch', true),
      _StepData(2, 'Doctor', false),
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

  Widget _buildBody(FlutterFlowTheme theme, Color accentColor) {
    if (_isLoading) {
      return _buildSkeletonLoader();
    }
    if (_hasError) {
      return _buildErrorState(theme, accentColor);
    }
    if (_branches.isEmpty) {
      return _buildEmptyState(theme);
    }
    return _buildBranchList(theme, accentColor);
  }

  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.separated(
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, __) => Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 100,
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 160,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 120,
                        height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(FlutterFlowTheme theme, Color accentColor) {
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
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F1B3D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _loadBranches,
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

  Widget _buildEmptyState(FlutterFlowTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: const Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 16),
            const Text(
              'No branches available',
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

  Widget _buildBranchList(FlutterFlowTheme theme, Color accentColor) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _branches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final branch = _branches[index];
        final isSelected = _selectedBranchId == branch.id;
        return _buildBranchCard(branch, isSelected, theme, accentColor);
      },
    );
  }

  Widget _buildBranchCard(
    BranchItem branch,
    bool isSelected,
    FlutterFlowTheme theme,
    Color accentColor,
  ) {
    return GestureDetector(
      onTap: () => _onBranchSelected(branch),
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
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
              child: SizedBox(
                width: 100,
                height: 120,
                child: branch.image.isNotEmpty
                    ? Image.network(
                        branch.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      branch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F1B3D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (branch.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              branch.address,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (branch.hours.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.hours,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.check_circle,
                  color: accentColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFE5E7EB),
      child: const Center(
        child: Icon(
          Icons.store,
          size: 32,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildNextButton(FlutterFlowTheme theme, Color accentColor) {
    final isEnabled = _selectedBranchId != null;
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
              backgroundColor: isEnabled ? accentColor : const Color(0xFFE5E7EB),
              foregroundColor: isEnabled ? Colors.white : const Color(0xFF9CA3AF),
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

class BranchItem {
  final String id;
  final String name;
  final String address;
  final String image;
  final String hours;

  BranchItem({
    required this.id,
    required this.name,
    required this.address,
    required this.image,
    required this.hours,
  });
}
