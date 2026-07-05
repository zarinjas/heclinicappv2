import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/components/skeleton_loaders.dart';
import '/components/empty_state_widget.dart';
import '/components/error_state_widget.dart';

class PaymentHistoryScreenWidget extends StatefulWidget {
  const PaymentHistoryScreenWidget({super.key});

  static String routeName = 'PaymentHistoryScreen';
  static String routePath = '/payment-history';

  @override
  State<PaymentHistoryScreenWidget> createState() =>
      _PaymentHistoryScreenWidgetState();
}

class _PaymentHistoryScreenWidgetState
    extends State<PaymentHistoryScreenWidget> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _payments = [];
  int _currentPage = 1;
  int? _lastPage;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPayments());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        (_lastPage == null || _currentPage < _lastPage!)) {
      _loadMore();
    }
  }

  Future<void> _loadPayments({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _payments.clear();
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await _fetchPayments();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _currentPage++;
    await _fetchPayments(isLoadMore: true);
    setState(() => _isLoadingMore = false);
  }

  Future<void> _fetchPayments({bool isLoadMore = false}) async {
    try {
      final result = await GetPaymentHistoryCall.call(
        page: _currentPage,
        limit: 20,
      );

      if (result.succeeded) {
        final data = GetPaymentHistoryCall.data(result.jsonBody);
        _lastPage = GetPaymentHistoryCall.lastPage(result.jsonBody);

        final parsed = <Map<String, dynamic>>[];
        if (data != null) {
          for (final item in data) {
            if (item is Map<String, dynamic>) {
              parsed.add(item);
            }
          }
        }

        safeSetState(() {
          if (isLoadMore) {
            _payments.addAll(parsed);
          } else {
            _payments.clear();
            _payments.addAll(parsed);
          }
          _isLoading = false;
          _hasError = false;
        });
      } else {
        safeSetState(() {
          _isLoading = false;
          _hasError = !isLoadMore;
          if (!isLoadMore && result.statusCode != 404) {
            _errorMessage = 'Failed to fetch payment history.';
          }
        });
      }
    } catch (_) {
      safeSetState(() {
        _isLoading = false;
        _hasError = !isLoadMore;
        _errorMessage = 'Something went wrong. Please try again.';
      });
    }
  }

  String _field(dynamic item, String key, {String defaultValue = '—'}) {
    if (item is! Map) return defaultValue;
    final value = item[key];
    if (value == null) return defaultValue;
    return value.toString();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textInverse),
        title: Text(
          'Payment History',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textInverse,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeleton();
    }

    if (_hasError && _payments.isEmpty) {
      return ErrorStateWidget(
        message: _errorMessage ?? 'Something went wrong',
        onRetry: () => _loadPayments(refresh: true),
      );
    }

    if (_payments.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.receipt_long_outlined,
        title: 'No Payment History',
        subtitle:
            'You don\'t have any payment records yet.\nYour payment history will appear here when available.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadPayments(refresh: true),
      color: AppColors.accent,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _payments.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _payments.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildPaymentCard(_payments[index]);
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: const SkeletonListTile(),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final invoiceNumber = _field(payment, 'invoice_number');
    final amount = _field(payment, 'amount', defaultValue: '0.00');
    final method = _field(payment, 'payment_method');
    final status = _field(payment, 'status', defaultValue: 'unknown');
    final createdAt = _field(payment, 'created_at');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.low],
      ),
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: AppColors.accent.withAlpha(25),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.accent,
              size: 22.0,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoiceNumber,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'RM $amount',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.credit_card, size: 14.0, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      method,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Icon(Icons.access_time, size: 14.0, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      createdAt.length > 10 ? createdAt.substring(0, 10) : createdAt,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _statusColor(status).withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: _statusColor(status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
