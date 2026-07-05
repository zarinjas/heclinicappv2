import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';

class DoctorDetailSheet extends StatelessWidget {
  const DoctorDetailSheet({
    super.key,
    required this.doctorName,
    this.specialty,
    this.branchName,
    this.photoUrl,
    this.bio,
    this.onBookAppointment,
  });

  final String doctorName;
  final String? specialty;
  final String? branchName;
  final String? photoUrl;
  final String? bio;
  final VoidCallback? onBookAppointment;

  static void show(
    BuildContext context, {
    required String doctorName,
    String? specialty,
    String? branchName,
    String? photoUrl,
    String? bio,
    VoidCallback? onBookAppointment,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: MediaQuery.viewInsetsOf(context),
        child: DoctorDetailSheet(
          doctorName: doctorName,
          specialty: specialty,
          branchName: branchName,
          photoUrl: photoUrl,
          bio: bio,
          onBookAppointment: onBookAppointment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 32.0,
            color: Colors.black.withOpacity(0.16),
            offset: const Offset(0.0, -8.0),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandleBar(theme),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatar(context),
                  const SizedBox(height: 12.0),
                  Text(
                    doctorName,
                    textAlign: TextAlign.center,
                    style: theme.headlineMedium.override(
                      fontFamily: theme.headlineMediumFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.headlineMediumIsCustom,
                    ),
                  ),
                  if (specialty != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      specialty!,
                      textAlign: TextAlign.center,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                  if (branchName != null) ...[
                    const SizedBox(height: 4.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.0,
                          color: theme.primary,
                        ),
                        const SizedBox(width: 4.0),
                        Flexible(
                          child: Text(
                            branchName!,
                            textAlign: TextAlign.center,
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (bio != null && bio!.isNotEmpty) ...[
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'About',
                        style: theme.headlineSmall.override(
                          fontFamily: theme.headlineSmallFamily,
                          color: theme.primaryText,
                          letterSpacing: 0.0,
                          useGoogleFonts: !theme.headlineSmallIsCustom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      bio!,
                      style: theme.bodyMedium.override(
                        fontFamily: theme.bodyMediumFamily,
                        color: theme.primaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodyMediumIsCustom,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20.0),
                  FFButtonWidget(
                    onPressed: () {
                      if (onBookAppointment != null) {
                        onBookAppointment!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    text: 'Book Appointment',
                    options: FFButtonOptions(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: 52.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 0.0),
                      color: const Color(0xFF00C9A7),
                      textStyle: theme.titleSmall.override(
                        fontFamily: theme.titleSmallFamily,
                        color: Colors.white,
                        fontSize: 15.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        useGoogleFonts: !theme.titleSmallIsCustom,
                      ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleBar(FlutterFlowTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Container(
        width: 36.0,
        height: 4.0,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(2.0),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFDBE2E7),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(photoUrl!),
            onError: (_, __) {},
          ),
        ),
      );
    }
    return Container(
      width: 100.0,
      height: 100.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          _initialsFromName(doctorName),
          style: theme.headlineLarge.override(
            fontFamily: theme.headlineLargeFamily,
            color: theme.primary,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.headlineLargeIsCustom,
          ),
        ),
      ),
    );
  }

  String _initialsFromName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
