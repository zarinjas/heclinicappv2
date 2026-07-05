import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:flutter/material.dart';
import 'doctor_card_widget.dart';
import 'doctor_detail_sheet.dart';

class DoctorListWidget extends StatefulWidget {
  const DoctorListWidget({
    super.key,
    this.layout = DoctorListLayout.vertical,
    this.maxItems,
    this.showSeeAll = false,
    this.onSeeAll,
  });

  final DoctorListLayout layout;
  final int? maxItems;
  final bool showSeeAll;
  final VoidCallback? onSeeAll;

  @override
  State<DoctorListWidget> createState() => _DoctorListWidgetState();
}

enum DoctorListLayout { horizontal, vertical }

class _DoctorListWidgetState extends State<DoctorListWidget> {
  List<Map<String, dynamic>>? _doctors;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDoctors();
    });
  }

  Future<void> _fetchDoctors() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await GetproviderCall.call();
      if (response.succeeded && response.jsonBody != null) {
        final data = response.jsonBody;
        if (data is List) {
          final doctors = data.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>) return item;
            return <String, dynamic>{};
          }).where((d) {
            final visible = d['is_visible_in_app'];
            if (visible == null) return true;
            return visible == true;
          }).toList();
          setState(() {
            _doctors = doctors;
            _loading = false;
          });
        } else {
          setState(() {
            _doctors = [];
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = response.bodyText.isNotEmpty
              ? response.bodyText
              : 'Failed to load doctors';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildSkeleton();
    if (_error != null) return _buildError();
    if (_doctors == null || _doctors!.isEmpty) return _buildEmpty();

    final displayDoctors = widget.maxItems != null && _doctors!.length > widget.maxItems!
        ? _doctors!.sublist(0, widget.maxItems)
        : _doctors!;

    if (widget.layout == DoctorListLayout.horizontal) {
      return _buildHorizontalList(displayDoctors);
    }

    return _buildVerticalList(_doctors!);
  }

  String _getDoctorName(Map<String, dynamic> doctor) {
    return doctor['name']?.toString() ?? 'Unknown';
  }

  String _getDoctorId(Map<String, dynamic> doctor) {
    return doctor['_id']?.toString() ?? '';
  }

  Widget _buildHorizontalList(List<Map<String, dynamic>> doctors) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showSeeAll) _buildSectionHeader(),
        SizedBox(
          height: 180.0,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 4.0),
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return DoctorCardWidget(
                doctorName: _getDoctorName(doctor),
                onTap: () => _showDoctorDetail(doctor),
                compact: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalList(List<Map<String, dynamic>> doctors) {
    final theme = FlutterFlowTheme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCardWidget(
          doctorName: _getDoctorName(doctor),
          onTap: () => _showDoctorDetail(doctor),
          compact: true,
        );
      },
    );
  }

  Widget _buildSectionHeader() {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Our Doctors',
            style: theme.headlineSmall.override(
              fontFamily: theme.headlineSmallFamily,
              color: theme.primaryText,
              letterSpacing: 0.0,
              useGoogleFonts: !theme.headlineSmallIsCustom,
            ),
          ),
          GestureDetector(
            onTap: widget.onSeeAll,
            child: Text(
              'See All',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: const Color(0xFF00C9A7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    final theme = FlutterFlowTheme.of(context);
    if (widget.layout == DoctorListLayout.horizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showSeeAll) _buildSectionHeader(),
          SizedBox(
            height: 180.0,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 4,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (context, index) {
                return Container(
                  width: 140.0,
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.secondaryBackground,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        width: 80.0,
                        height: 12.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Container(
                        width: 60.0,
                        height: 10.0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 10.0),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E7EB),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 120.0,
                      height: 14.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                    const SizedBox(height: 6.0),
                    Container(
                      width: 80.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 40.0,
              color: theme.error,
            ),
            const SizedBox(height: 12.0),
            Text(
              'Something went wrong',
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                color: theme.primaryText,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
              ),
            ),
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: _fetchDoctors,
              icon: const Icon(Icons.refresh, color: Color(0xFF00C9A7)),
              label: Text(
                'Try Again',
                style: TextStyle(color: const Color(0xFF00C9A7)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final theme = FlutterFlowTheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64.0,
              color: theme.secondaryText.withOpacity(0.5),
            ),
            const SizedBox(height: 12.0),
            Text(
              'No doctors available',
              style: theme.headlineSmall.override(
                fontFamily: theme.headlineSmallFamily,
                color: theme.primaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.headlineSmallIsCustom,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Check back soon for our doctor directory',
              style: theme.bodyMedium.override(
                fontFamily: theme.bodyMediumFamily,
                color: theme.secondaryText,
                letterSpacing: 0.0,
                useGoogleFonts: !theme.bodyMediumIsCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetail(Map<String, dynamic> doctor) {
    DoctorDetailSheet.show(
      context,
      doctorName: _getDoctorName(doctor),
    );
  }
}
