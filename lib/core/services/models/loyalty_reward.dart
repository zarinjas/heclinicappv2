class LoyaltyReward {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String type; // product | service | discount
  final int pointsCost;
  final int? stock;
  final String? ctaText;
  final int? servicePackageId;
  final String? servicePackageName;

  const LoyaltyReward({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    this.type = 'product',
    this.pointsCost = 0,
    this.stock,
    this.ctaText,
    this.servicePackageId,
    this.servicePackageName,
  });

  factory LoyaltyReward.fromJson(Map<String, dynamic> json) {
    final pkg = json['service_package'] as Map<String, dynamic>?;
    return LoyaltyReward(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image'] as String?,
      type: json['type'] as String? ?? 'product',
      pointsCost: json['points_cost'] as int? ?? 0,
      stock: json['stock'] as int?,
      ctaText: json['cta_text'] as String?,
      servicePackageId: pkg?['id'] as int?,
      servicePackageName: pkg?['name'] as String?,
    );
  }

  bool get isService => type == 'service';
  bool get isProduct => type == 'product';
  bool get isDiscount => type == 'discount';

  bool get isOutOfStock => isProduct && stock != null && stock! <= 0;

  String get ctaLabel => ctaText?.isNotEmpty == true ? ctaText! : 'Redeem';

  String get stockLabel => isProduct
      ? (stock == null ? 'Unlimited stock' : '$stock left')
      : '';
}
