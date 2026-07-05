import 'dart:convert';

import 'api_manager.dart';

typedef PageFetcher = Future<ApiCallResponse> Function(int currentPage);

const int _kDefaultPerPage = 20;

class PaginationHelper {
  PaginationHelper._();

  static Future<ApiCallResponse> fetchAllPages(
    PageFetcher pageFetcher, {
    int perPage = _kDefaultPerPage,
  }) async {
    final List<dynamic> allRecords = [];
    int currentPage = 1;
    ApiCallResponse lastResponse = ApiCallResponse(null, {}, -1);
    bool hasMore = true;

    while (hasMore) {
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
