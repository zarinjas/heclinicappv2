class ClaimedVoucher {
  final int id;
  final String code;
  final String status;
  final DateTime? claimedAt;
  final DateTime? usedAt;
  final DateTime? expiresAt;
  final int? promotionId;
  final String title;
  final String description;
  final String? discount;

  const ClaimedVoucher({
    required this.id,
    required this.code,
    required this.status,
    this.claimedAt,
    this.usedAt,
    this.expiresAt,
    this.promotionId,
    this.title = '',
    this.description = '',
    this.discount,
  });

  bool get isActive => status == 'active';
  bool get isUsed => status == 'used';

  factory ClaimedVoucher.fromJson(Map<String, dynamic> json) {
    final promo = json['promotion'] as Map<String, dynamic>?;
    return ClaimedVoucher(
      id: json['id'] as int? ?? 0,
      code: json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      claimedAt: DateTime.tryParse(json['claimed_at'] as String? ?? ''),
      usedAt: DateTime.tryParse(json['used_at'] as String? ?? ''),
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      promotionId: promo?['id'] as int?,
      title: promo?['title'] as String? ?? '',
      description: promo?['description'] as String? ?? '',
      discount: promo?['cta_text'] as String?,
    );
  }
}
