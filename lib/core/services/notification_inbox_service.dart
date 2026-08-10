import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../app_state.dart';
import '../../env_config.dart';

/// One notification in the patient's inbox.
class InboxNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final String deepLink;
  final String? imageUrl;
  final bool isRead;
  final DateTime? createdAt;

  const InboxNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.deepLink,
    required this.isRead,
    this.imageUrl,
    this.createdAt,
  });

  factory InboxNotification.fromJson(Map<String, dynamic> json) {
    return InboxNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      deepLink: json['deep_link'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal(),
    );
  }

  InboxNotification copyWith({bool? isRead}) => InboxNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        deepLink: deepLink,
        imageUrl: imageUrl,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

class InboxPage {
  final List<InboxNotification> notifications;
  final int unreadCount;

  const InboxPage({required this.notifications, required this.unreadCount});
}

/// Reads the notification inbox from the Laravel API.
///
/// The app previously queried Firestore `historynotif` directly, but those
/// rules require a Firebase Auth uid the app never obtains (it authenticates
/// with Sanctum), so reads were denied. Serving the inbox from our own API
/// removes that dependency and keeps a single source of truth.
class NotificationInboxService {
  NotificationInboxService._();

  static final NotificationInboxService instance = NotificationInboxService._();

  static String get _baseUrl => '${EnvConfig.laravelBaseUrl}/v2/notifications';

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      };

  Future<InboxPage> fetch({int perPage = 30}) async {
    final response = await http
        .get(Uri.parse('$_baseUrl?per_page=$perPage'), headers: _headers)
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Failed to load notifications (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (decoded['notifications'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(InboxNotification.fromJson)
        .toList();

    return InboxPage(
      notifications: items,
      unreadCount: (decoded['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  Future<int> unreadCount() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/unread-count'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return 0;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return (decoded['unread_count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('[Inbox] unreadCount failed: $e');
      return 0;
    }
  }

  /// Returns the remaining unread count, or null if the call failed.
  Future<int?> markRead(int id) async {
    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/$id/read'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return (decoded['unread_count'] as num?)?.toInt() ?? 0;
    } catch (e) {
      debugPrint('[Inbox] markRead failed: $e');
      return null;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final response = await http
          .post(Uri.parse('$_baseUrl/read-all'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[Inbox] markAllRead failed: $e');
      return false;
    }
  }
}
