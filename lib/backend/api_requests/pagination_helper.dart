import 'dart:convert';

import 'api_manager.dart';

typedef PageFetcher = Future<ApiCallResponse> Function(int currentPage);

const int _kDefaultPerPage = 20;

class PaginationHelper {
  PaginationHelper._();

  static Future<ApiCallResponse> fetchAllPages(
    PageFetcher pageFetcher, {
    int perPage = _kDefaultPerPage,
    int maxPages = 200,
  }) async {
    final List<dynamic> allRecords = [];
    int currentPage = 1;
    ApiCallResponse lastResponse = ApiCallResponse(null, {}, -1);
    bool hasMore = true;

    // Guards against an endpoint that ignores `current_page` and keeps
    // returning the same full page: without this the loop would never end.
    String? previousPageSignature;

    while (hasMore && currentPage <= maxPages) {
      final response = await pageFetcher(currentPage);

      if (!response.succeeded) {
        if (currentPage == 1) {
          return response;
        }
        hasMore = false;
        break;
      }

      lastResponse = response;

      final body = response.jsonBody;
      final List<dynamic> records = _extractRecords(body);

      final signature = json.encode(records);
      if (previousPageSignature != null && signature == previousPageSignature) {
        // The server repeated the previous page — stop instead of looping.
        hasMore = false;
        break;
      }
      previousPageSignature = signature;

      allRecords.addAll(records);

      if (records.length < perPage) {
        hasMore = false;
      } else {
        currentPage++;
      }
    }

    final mergedHeaders = lastResponse.statusCode >= 0
        ? lastResponse.headers
        : <String, String>{};

    return ApiCallResponse(
      allRecords,
      mergedHeaders,
      lastResponse.statusCode >= 200 && lastResponse.statusCode < 300
          ? lastResponse.statusCode
          : 200,
      response: lastResponse.response,
    );
  }

  static List<dynamic> _extractRecords(dynamic body) {
    if (body is List) {
      return body;
    }
    if (body is String) {
      try {
        final decoded = json.decode(body);
        if (decoded is List) {
          return decoded;
        }
        return [decoded];
      } catch (_) {
        return [];
      }
    }
    if (body is Map) {
      return [body];
    }
    return [];
  }
}
