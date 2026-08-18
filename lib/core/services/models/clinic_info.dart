class ClinicInfo {
  final int id;
  final String imageUrl;

  const ClinicInfo({
    required this.id,
    required this.imageUrl,
  });

  factory ClinicInfo.fromJson(Map<String, dynamic> json) {
    return ClinicInfo(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': imageUrl,
  };

  static const fallbackList = <ClinicInfo>[];
}
