import '/flutter_flow/flutter_flow_util.dart';
import '/env_config.dart';
import '/backend/api_requests/api_manager.dart';

export '/backend/api_requests/api_manager.dart' show ApiCallResponse;

/// New auth API group — points to Laravel backend (heclinic.cyberoket.cloud/api/v2/auth)
/// Replaces old MedicalAppsApiGroup auth calls (hemedicalapps.com)

class HeclinicAuthApi {
  static String get baseUrl => '${EnvConfig.laravelBaseUrl}/v2/auth';

  static final CheckNricCall checkNricCall = CheckNricCall();
  static final CheckPhoneCall checkPhoneCall = CheckPhoneCall();
  static final RegisterCall registerCall = RegisterCall();
  static final LoginCall loginCall = LoginCall();
  static final SocialLoginCall socialLoginCall = SocialLoginCall();
  static final LogoutCall logoutCall = LogoutCall();
  static final ForgotPasswordCall forgotPasswordCall = ForgotPasswordCall();
  static final ClaimAccountCall claimAccountCall = ClaimAccountCall();
  static final VerifyOtpCall verifyOtpCall = VerifyOtpCall();
  static final ResetPasswordCall resetPasswordCall = ResetPasswordCall();
  static final ChangePasswordFirstCall changePasswordFirstCall = ChangePasswordFirstCall();
  static final LinkEmailRequestCall linkEmailRequestCall = LinkEmailRequestCall();
  static final LinkEmailVerifyCall linkEmailVerifyCall = LinkEmailVerifyCall();
  static final SendFcmOtpCall sendFcmOtpCall = SendFcmOtpCall();
}

// ---------------------------------------------------------------------------
// GET /v2/auth/check-nric?nric=
// Used in Register Step 1 to detect existing Plato patients by NRIC.
// ---------------------------------------------------------------------------
class CheckNricCall {
  Future<ApiCallResponse> call({String? nric = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'CheckNric',
      apiUrl: '${HeclinicAuthApi.baseUrl}/check-nric',
      callType: ApiCallType.GET,
      headers: {'Accept': 'application/json'},
      params: {'nric': nric},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  /// Whether a matching Plato record was found.
  static bool? exists(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.exists'''));

  /// Patient name from Plato (if exists).
  static String? name(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.name'''));

  /// Plato internal patient ID (if exists).
  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.idplato'''));
}

// ---------------------------------------------------------------------------
// GET /v2/auth/check-phone?telephone=
// Used in Register Step 1 to detect existing Plato patients by phone number.
// ---------------------------------------------------------------------------
class CheckPhoneCall {
  Future<ApiCallResponse> call({String? telephone = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'CheckPhone',
      apiUrl: '${HeclinicAuthApi.baseUrl}/check-phone',
      callType: ApiCallType.GET,
      headers: {'Accept': 'application/json'},
      params: {'telephone': telephone},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? exists(dynamic response) =>
      castToType<bool>(getJsonField(response, r'''$.exists'''));

  static String? name(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.name'''));

  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.idplato'''));

  static String? nric(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.nric'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/register
// ---------------------------------------------------------------------------
class RegisterCall {
  Future<ApiCallResponse> call({
    String? name = '',
    String? email = '',
    String? telephone = '',
    String? nric = '',
    String? nricType = '',
    String? nationality = '',
    String? dob = '',
    String? sex = '',
    String? title = '',
    String? address = '',
    String? allergiesSelect = '',
    String? allergies = '',
    String? foodAllergiesSelect = '',
    String? foodAllergies = '',
    String? referredBy = '',
    String? idplato = '',      // pre-resolved from check-nric (walk-in link)
    String? password = '',
    String? fcmToken = '',
    String? countryCode = '60',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicRegister',
      apiUrl: '${HeclinicAuthApi.baseUrl}/register',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'name': name,
        'email': email,
        'telephone': telephone,
        'nric': nric,
        'nric_type': nricType,
        'nationality': nationality,
        'dob': dob,
        'sex': sex,
        'title': title,
        'address': address,
        'allergies_select': allergiesSelect,
        'allergies': allergies,
        'food_allergies_select': foodAllergiesSelect,
        'food_allergies': foodAllergies,
        'referred_by': referredBy,
        'idplato': idplato,
        'password': password,
        'password_confirmation': password,
        'fcm_token': fcmToken,
        'country_code': countryCode,
      },
      bodyType: BodyType.MULTIPART,
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
  static String? token(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.token'''));
  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.idplato'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/login
// identifier can be NRIC, email, or phone number (any format)
// ---------------------------------------------------------------------------
class LoginCall {
  Future<ApiCallResponse> call({
    String? identifier = '',
    String? password = '',
    String? fcmToken = '',
    String? countryCode = '60',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicLogin',
      apiUrl: '${HeclinicAuthApi.baseUrl}/login',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'identifier': identifier,
        'password': password,
        'fcm_token': fcmToken,
        'country_code': countryCode,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? token(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.token'''));
  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.idplato'''));
  static String? name(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.name'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));

  /// Whether the patient has ever changed their password (first login check).
  static String? passwordChangedAt(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.password_changed_at'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/social-login
// provider: 'google' | 'apple', id_token verified server-side.
// ---------------------------------------------------------------------------
class SocialLoginCall {
  Future<ApiCallResponse> call({
    String? provider = '',
    String? idToken = '',
    String? email = '',
    String? name = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicSocialLogin',
      apiUrl: '${HeclinicAuthApi.baseUrl}/social-login',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'provider': provider,
        'id_token': idToken,
        'email': email,
        'name': name,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? token(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.token'''));
  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.idplato'''));
  static String? name(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.name'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/logout   (requires Bearer token)
// ---------------------------------------------------------------------------
class LogoutCall {
  Future<ApiCallResponse> call({String? token = ''}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicLogout',
      apiUrl: '${HeclinicAuthApi.baseUrl}/logout',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      params: {},
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }
}

// ---------------------------------------------------------------------------
// POST /v2/auth/forgot-password
// Sends OTP to the patient's email (or WhatsApp if configured server-side).
// ---------------------------------------------------------------------------
class ForgotPasswordCall {
  Future<ApiCallResponse> call({String? identifier = '', String? countryCode = '60'}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicForgotPassword',
      apiUrl: '${HeclinicAuthApi.baseUrl}/forgot-password',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'identifier': identifier,
        'country_code': countryCode,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
}

// ---------------------------------------------------------------------------
// POST /v2/auth/claim-account
// For existing Plato patients without an app account yet. Sends an OTP.
// ---------------------------------------------------------------------------
class ClaimAccountCall {
  Future<ApiCallResponse> call({String? identifier = '', String? countryCode = '60'}) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicClaimAccount',
      apiUrl: '${HeclinicAuthApi.baseUrl}/claim-account',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'identifier': identifier,
        'country_code': countryCode,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? channel(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.channel'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/change-password-first
// Protected. Sets a fresh password on first login (temporary password).
// ---------------------------------------------------------------------------
class ChangePasswordFirstCall {
  Future<ApiCallResponse> call({
    String? token = '',
    String? newPassword = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicChangePasswordFirst',
      apiUrl: '${HeclinicAuthApi.baseUrl}/change-password-first',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      params: {
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? token(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.token'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/verify-otp
// Verifies the OTP and returns a reset_token.
// ---------------------------------------------------------------------------
class VerifyOtpCall {
  Future<ApiCallResponse> call({
    String? identifier = '',
    String? otp = '',
    String? countryCode = '60',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicVerifyOtp',
      apiUrl: '${HeclinicAuthApi.baseUrl}/verify-otp',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'identifier': identifier,
        'otp': otp,
        'country_code': countryCode,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? resetToken(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.reset_token'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/reset-password
// Resets the password using the reset_token from verify-otp.
// ---------------------------------------------------------------------------
class ResetPasswordCall {
  Future<ApiCallResponse> call({
    String? resetToken = '',
    String? password = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicResetPassword',
      apiUrl: '${HeclinicAuthApi.baseUrl}/reset-password',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': password,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
  static String? token(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.token'''));
  static String? idplato(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.idplato'''));
  static String? name(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.user.name'''));
  static String? message(dynamic response) =>
      castToType<String>(getJsonField(response, r'''$.message'''));
}

// ---------------------------------------------------------------------------
// POST /v2/auth/link-email-request
// Protected. Sends an OTP to a new email the patient wants to bind.
// ---------------------------------------------------------------------------
class LinkEmailRequestCall {
  Future<ApiCallResponse> call({
    String? token = '',
    String? email = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicLinkEmailRequest',
      apiUrl: '${HeclinicAuthApi.baseUrl}/link-email-request',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      params: {
        'email': email,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
}

// ---------------------------------------------------------------------------
// POST /v2/auth/link-email-verify
// Protected. Verifies the OTP and binds the new email to the account.
// ---------------------------------------------------------------------------
class LinkEmailVerifyCall {
  Future<ApiCallResponse> call({
    String? token = '',
    String? email = '',
    String? otp = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicLinkEmailVerify',
      apiUrl: '${HeclinicAuthApi.baseUrl}/link-email-verify',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      params: {
        'email': email,
        'otp': otp,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
}

// ---------------------------------------------------------------------------
// POST /v2/auth/send-fcm-otp
// Sends the OTP via Firebase push notification as a last-resort fallback.
// ---------------------------------------------------------------------------
class SendFcmOtpCall {
  Future<ApiCallResponse> call({
    String? identifier = '',
    String? countryCode = '60',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'HeclinicSendFcmOtp',
      apiUrl: '${HeclinicAuthApi.baseUrl}/send-fcm-otp',
      callType: ApiCallType.POST,
      headers: {'Accept': 'application/json'},
      params: {
        'identifier': identifier,
        'country_code': countryCode,
      },
      bodyType: BodyType.X_WWW_FORM_URL_ENCODED,
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
}
