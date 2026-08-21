import '/flutter_flow/flutter_flow_util.dart';
import '/env_config.dart';
import '/backend/api_requests/api_manager.dart';

export '/backend/api_requests/api_manager.dart' show ApiCallResponse;

/// Voucher API group — points to the Laravel backend (claimed vouchers).
class VoucherApi {
  static String get baseUrl => '${EnvConfig.laravelBaseUrl}/v2/vouchers';

  static final GetMyVouchersCall getMyVouchersCall = GetMyVouchersCall();
  static final ClaimVoucherCall claimVoucherCall = ClaimVoucherCall();
}

// ---------------------------------------------------------------------------
// GET /v2/vouchers
// Returns the current patient's claimed vouchers with lifecycle status.
// ---------------------------------------------------------------------------
class GetMyVouchersCall {
  Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetMyVouchers',
      apiUrl: VoucherApi.baseUrl,
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

  static List<dynamic>? rawList(dynamic response) =>
      response is List ? response : null;
}

// ---------------------------------------------------------------------------
// POST /v2/vouchers/claim  { promotion_id: int }
// Claims a promotion once per patient and returns a unique voucher code.
// ---------------------------------------------------------------------------
class ClaimVoucherCall {
  Future<ApiCallResponse> call({required int promotionId}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ClaimVoucher',
      apiUrl: '${VoucherApi.baseUrl}/claim',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
      },
      params: {'promotion_id': promotionId},
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

  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));

  static String? code(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.voucher.code'''));
}
