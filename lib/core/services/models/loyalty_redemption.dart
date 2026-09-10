class LoyaltyRedemption {
  final int id;
  final String code;
  final int points;
  final double? discountValue;
  final String status;
  final DateTime? expiresAt;
  final DateTime? fulfilledAt;
  final DateTime? createdAt;
  final String? rewardName;
  final String? rewardType;

  const LoyaltyRedemption({
    required this.id,
    required this.code,
    required this.points,
    this.discountValue,
    this.status = 'pending',
    this.expiresAt,
    this.fulfilledAt,
    this.createdAt,
    this.rewardName,
    this.rewardType,
  });

  factory LoyaltyRedemption.fromJson(Map<String, dynamic> json) {
    final reward = json['reward'] as Map<String, dynamic>?;
    return LoyaltyRedemption(
      id: json['id'] as int? ?? 0,
      code: json['redemption_code'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'pending',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      fulfilledAt: DateTime.tryParse(json['fulfilled_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      rewardName: reward?['name'] as String?,
      rewardType: reward?['type'] as String?,
    );
  }

  bool get isPending => status == 'pending';
  bool get isFulfilled => status == 'fulfilled';
  bool get isCancelled => status == 'cancelled';

  String get title => rewardName?.isNotEmpty == true ? rewardName! : 'Points discount';

  String get pointsLabel => '${points.abs()} pts';

  String get discountLabel => discountValue != null
      ? 'RM ${discountValue!.toStringAsFixed(2)} off'
      : (rewardType?.isNotEmpty == true ? _capitalize(rewardType!) : '');

  static String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}
