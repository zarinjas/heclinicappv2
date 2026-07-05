import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class DoctorCardWidget extends StatelessWidget {
  const DoctorCardWidget({
    super.key,
    required this.doctorName,
    this.specialty,
    this.branchName,
    this.photoUrl,
    this.onTap,
    this.compact = false,
  });

  final String doctorName;
  final String? specialty;
  final String? branchName;
  final String? photoUrl;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final tokens = theme.designToken;

    if (compact) {
      return _buildCompactCard(context, theme);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 140.0,
          margin: const EdgeInsets.only(right: 12.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: theme.secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [tokens.shadow.sm],
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAvatar(context, 64.0),
              const SizedBox(height: 8.0),
              Text(
                doctorName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.bodyMedium.override(
                  fontFamily: theme.bodyMediumFamily,
                  color: theme.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.0,
                  letterSpacing: 0.0,
                  useGoogleFonts: !theme.bodyMediumIsCustom,
                ),
              ),
              if (specialty != null) ...[
                const SizedBox(height: 2.0),
                Text(
                  specialty!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodySmall.override(
                    fontFamily: theme.bodySmallFamily,
                    color: theme.secondaryText,
                    fontSize: 11.0,
                    letterSpacing: 0.0,
                    useGoogleFonts: !theme.bodySmallIsCustom,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, FlutterFlowTheme theme) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildAvatar(context, 48.0),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctorName,
                    style: theme.titleSmall.override(
                      fontFamily: theme.titleSmallFamily,
                      color: theme.primaryText,
                      letterSpacing: 0.0,
                      useGoogleFonts: !theme.titleSmallIsCustom,
                    ),
                  ),
                  if (specialty != null) ...[
                    const SizedBox(height: 2.0),
                    Text(
                      specialty!,
                      style: theme.bodySmall.override(
                        fontFamily: theme.bodySmallFamily,
                        color: theme.secondaryText,
                        letterSpacing: 0.0,
                        useGoogleFonts: !theme.bodySmallIsCustom,
                      ),
                    ),
                  ],
                  if (branchName != null) ...[
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14.0,
                          color: theme.secondaryText,
                        ),
                        const SizedBox(width: 2.0),
                        Flexible(
                          child: Text(
                            branchName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.bodySmall.override(
                              fontFamily: theme.bodySmallFamily,
                              color: theme.secondaryText,
                              fontSize: 11.0,
                              letterSpacing: 0.0,
                              useGoogleFonts: !theme.bodySmallIsCustom,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.secondaryText,
              size: 20.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    final theme = FlutterFlowTheme.of(context);
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          _initialsFromName(doctorName),
          style: theme.headlineSmall.override(
            fontFamily: theme.headlineSmallFamily,
            color: theme.primary,
            fontSize: size * 0.4,
            letterSpacing: 0.0,
            useGoogleFonts: !theme.headlineSmallIsCustom,
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
