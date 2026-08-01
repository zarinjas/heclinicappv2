import '/flutter_flow/flutter_flow_util.dart';
import '/env_config.dart';
import '/backend/api_requests/api_manager.dart';

export '/backend/api_requests/api_manager.dart' show ApiCallResponse;

/// Loyalty Points API group — points to Laravel backend (Patient Appreciation Points).
class LoyaltyApi {
  static String get baseUrl => '${EnvConfig.laravelBaseUrl}/v2/loyalty';

  static final GetLoyaltyBalanceCall getLoyaltyBalanceCall = GetLoyaltyBalanceCall();
  static final GetLoyaltyTransactionsCall getLoyaltyTransactionsCall = GetLoyaltyTransactionsCall();
  static final RedeemLoyaltyPointsCall redeemLoyaltyPointsCall = RedeemLoyaltyPointsCall();
}

// ---------------------------------------------------------------------------
// GET /v2/loyalty/balance
// Returns the current patient's points balance + redemption config.
// ---------------------------------------------------------------------------
class GetLoyaltyBalanceCall {
  Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetLoyaltyBalance',
      apiUrl: '${LoyaltyApi.baseUrl}/balance',
      callType: ApiCallType.GET,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      },
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? status(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.status'''));

  static int? balance(dynamic response) {
    final value = getJsonField(response, r'''$.balance''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static double? redemptionRate(dynamic response) {
    final value = getJsonField(response, r'''$.config.redemption_rate''');
    return value is num ? value.toDouble() : castToType<double>(value);
  }

  static int? minRedemption(dynamic response) {
    final value = getJsonField(response, r'''$.config.min_redemption''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static int? maxPerTxn(dynamic response) {
    final value = getJsonField(response, r'''$.config.max_per_txn''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static int? expiryWarningPoints(dynamic response) {
    final value = getJsonField(response, r'''$.expiry_warning.points''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static String? expiryWarningDate(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.expiry_warning.date'''));
}

// ---------------------------------------------------------------------------
// GET /v2/loyalty/transactions?type=&page=
// Paginated transaction history for the current patient.
// ---------------------------------------------------------------------------
class GetLoyaltyTransactionsCall {
  Future<ApiCallResponse> call({
    String? type = '',
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
    };
    if (type != null && type.isNotEmpty) {
      params['type'] = type.toLowerCase();
    }

    return ApiManager.instance.makeApiCall(
      callName: 'GetLoyaltyTransactions',
      apiUrl: '${LoyaltyApi.baseUrl}/transactions',
      callType: ApiCallType.GET,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      },
      params: params,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? types(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].type''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static List<int>? points(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].points''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => x is num ? x.toInt() : castToType<int>(x))
          .withoutNulls
          .toList();

  static List<String>? invoiceRefs(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].invoice_ref''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static List<String>? reasons(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].reason''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static List<String>? createdAt(dynamic response) => (getJsonField(
        response,
        r'''$.data[:].created_at''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();

  static int? total(dynamic response) {
    final value = getJsonField(response, r'''$.total''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static int? lastPage(dynamic response) {
    final value = getJsonField(response, r'''$.last_page''');
    return value is num ? value.toInt() : castToType<int>(value);
  }
}

// ---------------------------------------------------------------------------
// POST /v2/loyalty/redeem  { points: int }
// Redeems points and returns a redemption code + discount value.
// ---------------------------------------------------------------------------
class RedeemLoyaltyPointsCall {
  Future<ApiCallResponse> call({int? points = 0}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'RedeemLoyaltyPoints',
      apiUrl: '${LoyaltyApi.baseUrl}/redeem',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      },
      params: {'points': points},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? status(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.status'''));

  static String? redemptionCode(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.redemption_code'''));

  static double? discount(dynamic response) {
    final value = getJsonField(response, r'''$.discount''');
    return value is num ? value.toDouble() : castToType<double>(value);
  }

  static int? balanceAfter(dynamic response) {
    final value = getJsonField(response, r'''$.balance_after''');
    return value is num ? value.toInt() : castToType<int>(value);
  }

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}
