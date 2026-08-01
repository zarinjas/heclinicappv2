import 'package:flutter/material.dart';

class Branch {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final String? whatsappNumber;
  final String? imageUrl;
  final Map<String, String>? operatingHours;
  final String? googleMapsLink;
  final String? platoFacilityId;

  const Branch({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    this.whatsappNumber,
    this.imageUrl,
    this.operatingHours,
    this.googleMapsLink,
    this.platoFacilityId,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: _parseInt(json['id']),
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      whatsappNumber: json['whatsapp_number'] as String?,
      imageUrl: json['image'] as String?,
      operatingHours: _parseHours(json['operating_hours']),
      googleMapsLink: json['google_maps_link'] as String?,
      platoFacilityId: json['plato_facility_id'] as String?,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, String>? _parseHours(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v.toString()));
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'phone': phone,
    'whatsapp_number': whatsappNumber,
    'image': imageUrl,
    'operating_hours': operatingHours,
    'google_maps_link': googleMapsLink,
    'plato_facility_id': platoFacilityId,
  };

  List<Color> get leadingGradient {
    final gradients = [
      const [Color(0xFF131C3C), Color(0xFF1D2B5F)],
      const [Color(0xFF3B8DFF), Color(0xFF2868F5)],
      const [Color(0xFF1D2B5F), Color(0xFF3B8DFF)],
    ];
    return gradients[id % gradients.length];
  }

  static const fallbackList = <Branch>[
    Branch(
      id: 1,
      name: 'TTDI Clinic',
      address: 'Jalan Burhanuddin Helmi',
    ),
    Branch(
      id: 2,
      name: 'Bangsar Village',
      address: 'Jalan Telawi 3',
    ),
    Branch(
      id: 3,
      name: 'Petaling Jaya',
      address: 'Jalan Sultan, PJ State',
    ),
  ];
}
