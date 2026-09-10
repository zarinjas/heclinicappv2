import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/app_dialog.dart';
import 'package:image_picker/image_picker.dart';

import '../../backend/api_requests/api_calls.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/branch_picker_sheet.dart';
import '../../core/widgets/document_item.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import 'document_viewer_screen.dart';

/// A document belonging to the logged-in patient, as returned by
/// `GET /api/v2/patients/{id}/documents`.
class _PatientDocument {
  final int id;
  final String name;
  final String url;
  final String uploadedAt;
  final String? adminNote;
  final int sizeBytes;
  final String? mimeType;
  final String source;

  const _PatientDocument({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedAt,
    required this.sizeBytes,
    required this.source,
    this.adminNote,
    this.mimeType,
  });

  DocumentFileType get fileType {
    final mime = (mimeType ?? '').toLowerCase();
    if (mime.contains('pdf')) return DocumentFileType.pdf;
    if (mime.startsWith('image/')) return DocumentFileType.image;
    return DocumentFileType.other;
  }

  /// Label shown under the file name: the admin's note when present, otherwise
  /// who uploaded the file.
  String get typeLabel {
    final note = adminNote?.trim() ?? '';
    if (note.isNotEmpty && note != '—') return note;
    return source == 'patient' ? 'Uploaded by you' : 'Uploaded by clinic';
  }

  /// `uploaded_at` is an ISO 8601 string; fall back to the raw value if it
  /// cannot be parsed so we never show an empty date.
  String get formattedDate {
    final parsed = DateTime.tryParse(uploadedAt);
    if (parsed == null) return uploadedAt;
    final local = parsed.toLocal();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${local.day} ${months[local.month - 1]} ${local.year}';
  }
}

class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isUploading = false;
  List<_PatientDocument> _documents = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDocuments());
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final patientId = FFAppState().idplato;

      // Without a Plato id there is no patient to scope the request to.
      if (patientId.isEmpty) {
        if (mounted) {
          setState(() {
            _documents = const [];
            _isLoading = false;
          });
        }
        return;
      }

      final response = await GetPatientDocumentsCall.call(
        patientId: patientId,
        forceRefresh: true,
      );

      if (!mounted) return;

      if (!response.succeeded) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      setState(() {
        _documents = _parse(response.jsonBody);
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  List<_PatientDocument> _parse(dynamic body) {
    final names = GetPatientDocumentsCall.names(body);
    if (names == null || names.isEmpty) return const [];

    final ids = GetPatientDocumentsCall.ids(body);
    final urls = GetPatientDocumentsCall.urls(body);
    final uploadedAts = GetPatientDocumentsCall.uploadedAt(body);
    final adminNotes = GetPatientDocumentsCall.adminNotes(body);
    final sizes = GetPatientDocumentsCall.sizeBytes(body);
    final mimeTypes = GetPatientDocumentsCall.mimeTypes(body);
    final sources = GetPatientDocumentsCall.sources(body);

    T? at<T>(List<T>? list, int i) =>
        list != null && i < list.length ? list[i] : null;

    return [
      for (var i = 0; i < names.length; i++)
        _PatientDocument(
          id: at(ids, i) ?? 0,
          name: names[i],
          url: at(urls, i) ?? '',
          uploadedAt: at(uploadedAts, i) ?? '',
          adminNote: at(adminNotes, i),
          sizeBytes: at(sizes, i) ?? 0,
          mimeType: at(mimeTypes, i),
          source: at(sources, i) ?? 'admin',
        ),
    ];
  }

  /// Signed document URLs expire (default 60 min), so re-fetch a fresh one for
  /// [documentId] right before opening. Returns null when a fresh URL can't be
  /// obtained, in which case the caller falls back to the cached URL.
  Future<String?> _fetchFreshUrl(int documentId) async {
    final patientId = FFAppState().idplato;
    if (patientId.isEmpty) return null;

    try {
      final response = await GetPatientDocumentsCall.call(
        patientId: patientId,
        forceRefresh: true,
      );
      if (!response.succeeded) return null;

      final ids = GetPatientDocumentsCall.ids(response.jsonBody);
      final urls = GetPatientDocumentsCall.urls(response.jsonBody);
      if (ids == null || urls == null) return null;

      final idx = ids.indexOf(documentId);
      if (idx < 0 || idx >= urls.length) return null;

      final url = urls[idx];
      return (url.isNotEmpty && Uri.tryParse(url) != null) ? url : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openDocument(_PatientDocument doc) async {
    var url = doc.url;
    if (url.isEmpty) {
      _showMessage('This document has no file attached.');
      return;
    }

    // Re-fetch a fresh signed URL when we have a valid id (the cached one may
    // have expired since the list was loaded).
    if (doc.id > 0) {
      final fresh = await _fetchFreshUrl(doc.id);
      if (fresh != null) url = fresh;
    }

    if (!mounted) return;

    if (Uri.tryParse(url) == null) {
      _showMessage('This document link is invalid.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          name: doc.name,
          url: url,
          mimeType: doc.mimeType ?? '',
        ),
      ),
    );
  }

  Future<void> _onUploadDocument() async {
    if (_isUploading) return;

    // Step 1: Patient selects which branch they're from.
    final branchResult = await BranchPickerSheet.show(context);
    if (branchResult == null || !mounted) return;

    // Step 2: Patient picks file type (PDF or photo).
    final source = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radiusXL)),
        ),
        padding: const EdgeInsets.all(AppSpacing.space16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadius.radiusFull),
                ),
              ),
              const SizedBox(height: AppSpacing.space16),
              Text(
                'Upload Document',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.space8),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
                title: const Text('PDF file'),
                subtitle: const Text('Blood test, MC, lab report...'),
                onTap: () => Navigator.pop(sheetContext, 'file'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_outlined, color: AppColors.accent),
                title: const Text('Photo from gallery'),
                subtitle: const Text('Photo of a report or scan'),
                onTap: () => Navigator.pop(sheetContext, 'image'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    FFUploadedFile? file;

    if (source == 'file') {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif', 'webp'],
        withData: true,
      );
      final picked = (result != null && result.files.isNotEmpty)
          ? result.files.first
          : null;
      if (picked == null || picked.bytes == null) return;
      file = FFUploadedFile(
        name: picked.name,
        bytes: picked.bytes,
        originalFilename: picked.name,
      );
    } else if (source == 'image') {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      file = FFUploadedFile(
        name: picked.name,
        bytes: bytes,
        originalFilename: picked.name,
      );
    }

    if (file == null || !mounted) return;

    final patientId = FFAppState().idplato;

    setState(() {
      _isUploading = true;
    });

    // Use the filename as the document title so it's not blank.
    final title = file.name ?? '';

    final response = await UploadPatientDocumentCall.call(
      patientId: patientId,
      document: file,
      title: title,
      branchId: branchResult.branchId,
    );

    if (!mounted) return;

    setState(() {
      _isUploading = false;
    });

    if (response.succeeded) {
      _showMessage('Document uploaded successfully');
      await _loadDocuments();
    } else {
      _showMessage('Upload failed. Please try again.');
    }
  }

  Future<void> _onDeleteDocument(_PatientDocument doc) async {
    // Guard against invalid IDs before showing confirm dialog.
    if (doc.id <= 0) {
      _showMessage('Unable to delete this document.');
      return;
    }

    final confirmed = await AppDialog.confirm(
      context,
      title: 'Delete document?',
      message: 'Delete "${doc.name}"? This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    final patientId = FFAppState().idplato;
    final response = await DeletePatientDocumentCall.call(
      patientId: patientId,
      documentId: doc.id,
    );

    if (!mounted) return;

    if (response.succeeded) {
      setState(() {
        _documents = _documents.where((d) => d.id != doc.id).toList();
      });
      AppToast.success(context, message: 'Document deleted');
    } else {
      AppToast.error(context, message: 'Failed to delete document');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    AppToast.info(context, message: message);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildSkeleton();
    if (_hasError) {
      return AppErrorState(
        title: 'Failed to load documents',
        subtitle: 'Please check your connection and try again',
        onRetry: _loadDocuments,
      );
    }
    return _buildContent();
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.space16),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.space12),
      itemBuilder: (_, i) => AppSkeleton.listItem(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Upload button
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space16,
            AppSpacing.space16,
            AppSpacing.space16,
            0,
          ),
          child: SizedBox(
            width: double.infinity,
            child: _isUploading
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2.5,
                    ),
                  )
                : FilledButton.icon(
                    onPressed: _onUploadDocument,
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: const Text('Upload Document'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.radiusFull),
                      ),
                    ),
                  ),
          ),
        ),
        // Document list or empty state
        Expanded(
          child: _documents.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadDocuments,
                  color: AppColors.accent,
                  child: ListView(
                    children: const [
                      SizedBox(height: AppSpacing.space48),
                      AppEmptyState(
                        icon: Icons.description_outlined,
                        title: 'No documents yet',
                        subtitle:
                            'Upload a document or wait for your clinic to share one',
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDocuments,
                  color: AppColors.accent,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.space16),
                    itemCount: _documents.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.space12),
                    itemBuilder: (_, i) {
                      final doc = _documents[i];
                      return DocumentItem(
                        name: doc.name,
                        fileType: doc.fileType,
                        typeLabel: doc.typeLabel,
                        uploadedAt: doc.formattedDate,
                        sizeBytes: doc.sizeBytes,
                        canDelete: doc.source == 'patient' && doc.id > 0,
                        onTap: () => _openDocument(doc),
                        onDelete: () => _onDeleteDocument(doc),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
