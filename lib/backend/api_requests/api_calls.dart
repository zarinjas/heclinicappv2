import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import '/env_config.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

/// Start MEDICAL APPS API Group Code

class MedicalAppsApiGroup {
  static String getBaseUrl() => EnvConfig.medicalAppsBaseUrl;
  static Map<String, String> headers = {};
  static RegisterCall registerCall = RegisterCall();
  static LoginCall loginCall = LoginCall();
  static ProfileCall profileCall = ProfileCall();
  static LogoutCall logoutCall = LogoutCall();
  static RequestForgotPasswordCall requestForgotPasswordCall =
      RequestForgotPasswordCall();
  static VerifyResetCodeCall verifyResetCodeCall = VerifyResetCodeCall();
  static ChangepasswordCall changepasswordCall = ChangepasswordCall();
  static SlidersCall slidersCall = SlidersCall();
  static ServicesPackagesCall servicesPackagesCall = ServicesPackagesCall();
  static CreateAppointmentCall createAppointmentCall = CreateAppointmentCall();
  static FirsttimechangepasswordCall firsttimechangepasswordCall =
      FirsttimechangepasswordCall();
  static UpdateProfilCall updateProfilCall = UpdateProfilCall();
  static GetMedicalCertificateCall getMedicalCertificateCall =
      GetMedicalCertificateCall();
  static ForgotchangeCall forgotchangeCall = ForgotchangeCall();
}

class RegisterCall {
  Future<ApiCallResponse> call({
    String? accept = '',
    String? email = '',
    String? telephone = '',
    String? name = '',
    String? nric = '',
    String? cek = '',
    String? fcmToken = '',
    String? dob = '',
    String? allergies = '',
    String? foodAllergies = '',
    String? title = '',
    String? sex = '',
    String? nationality = '',
    String? referredBy = '',
    String? address = '',
    List<String>? doctorList,
    String? allergiesSelect = '',
    String? nricType = '',
    String? foodAllergiesSelect = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();
    final doctor = _serializeList(doctorList);

    return ApiManager.instance.makeApiCall(
      callName: 'Register',
      apiUrl: '${baseUrl}/register',
      callType: ApiCallType.POST,
      headers: {
        'Accept': '${accept}',
      },
      params: {
        'email': email,
        'telephone': telephone,
        'name': name,
        'cek': cek,
        'fcm_token': fcmToken,
        'nric': nric,
        'dob': dob,
        'allergies': allergies,
        'food_allergies': foodAllergies,
        'title': title,
        'sex': sex,
        'nationality': nationality,
        'referred_by': referredBy,
        'address': address,
        'doctor': doctor,
        'allergies_select': allergiesSelect,
        'nric_type': nricType,
        'food_allergies_select': foodAllergiesSelect,
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

  String? token(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.token''',
      ));
  String? idplato(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.user.idplato''',
      ));
}

class LoginCall {
  Future<ApiCallResponse> call({
    String? email = '',
    String? password = '',
    String? fcmToken = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'login',
      apiUrl: '${baseUrl}/login',
      callType: ApiCallType.POST,
      headers: {
        'Accept': 'application/json',
      },
      params: {
        'email': email,
        'password': password,
        'fcm_token': fcmToken,
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

  String? token(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.token''',
      ));
  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.status''',
      ));
}

class ProfileCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
    String? accept = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'profile',
      apiUrl: '${baseUrl}/profile',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': '${authorization}',
        'Accept': '${accept}',
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

  String? avatar(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.avatar''',
      ));
  String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.name''',
      ));
  String? nric(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.nric''',
      ));
  String? address(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.address''',
      ));
  String? dob(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.dob''',
      ));
  String? fcmtoken(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.fcm_token''',
      ));
  String? nohp(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.telephone''',
      ));
  String? email(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.email''',
      ));
  String? changed(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.changed''',
      ));
  String? idplato(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data.idplato''',
      ));
}

class LogoutCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Logout',
      apiUrl: '${baseUrl}/logout',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': '${authorization}',
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
}

class RequestForgotPasswordCall {
  Future<ApiCallResponse> call({
    String? accept = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'RequestForgotPassword',
      apiUrl: '${baseUrl}/forgot-password',
      callType: ApiCallType.POST,
      headers: {
        'Accept': '${accept}',
      },
      params: {},
      body: ffApiRequestBody,
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

class VerifyResetCodeCall {
  Future<ApiCallResponse> call() async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'VerifyResetCode',
      apiUrl: '${baseUrl}/verify-reset-code',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
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

class ChangepasswordCall {
  Future<ApiCallResponse> call({
    String? accept = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'changepassword',
      apiUrl: '${baseUrl}/change-password',
      callType: ApiCallType.POST,
      headers: {
        'Accept': '${accept}',
      },
      params: {},
      body: ffApiRequestBody,
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

class SlidersCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'Sliders',
      apiUrl: '${baseUrl}/sliders',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': '${authorization}',
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

  List<int>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  List<String>? image(dynamic response) => (getJsonField(
        response,
        r'''$[:].image''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ServicesPackagesCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'ServicesPackages',
      apiUrl: '${baseUrl}/servicepackages',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': '${authorization}',
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
}

class CreateAppointmentCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
    String? accept = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    final ffApiRequestBody = '''
{}''';
    return ApiManager.instance.makeApiCall(
      callName: 'create_appointment',
      apiUrl: '${baseUrl}/appointments',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': '${authorization}',
        'Accept': '${accept}',
      },
      params: {},
      body: ffApiRequestBody,
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

class FirsttimechangepasswordCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
    String? newPassword = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'firsttimechangepassword',
      apiUrl: '${baseUrl}/change-password-first',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': '${authorization}',
      },
      params: {
        'new_password': newPassword,
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

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.status''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
}

class UpdateProfilCall {
  Future<ApiCallResponse> call({
    String? authorization = '',
    String? name = '',
    FFUploadedFile? avatar,
    String? dob = '',
    String? address = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'UpdateProfil',
      apiUrl: '${baseUrl}/update',
      callType: ApiCallType.POST,
      headers: {
        'Authorization': '${authorization}',
        'Accept': 'application/json',
      },
      params: {
        'name': name,
        'avatar': avatar,
        'dob': dob,
        'address': address,
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

  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.status''',
      ));
  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  String? avatar(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.user.avatar''',
      ));
  String? name(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.user.name''',
      ));
}

class GetMedicalCertificateCall {
  Future<ApiCallResponse> call({
    String? auth = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'GetMedicalCertificate',
      apiUrl: '${baseUrl}/pdfs',
      callType: ApiCallType.GET,
      headers: {
        'Authorization': '${auth}',
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

  String? path(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].path''',
      ));
  String? tgl(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.data[:].created_at''',
      ));
  List? data(dynamic response) => getJsonField(
        response,
        r'''$.data''',
        true,
      ) as List?;
}

class ForgotchangeCall {
  Future<ApiCallResponse> call({
    String? telephone = '',
  }) async {
    final baseUrl = MedicalAppsApiGroup.getBaseUrl();

    return ApiManager.instance.makeApiCall(
      callName: 'forgotchange',
      apiUrl: '${baseUrl}/changePasswordforgot',
      callType: ApiCallType.POST,
      headers: {},
      params: {
        'telephone': telephone,
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

  String? message(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$.message''',
      ));
  bool? status(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.status''',
      ));
}

/// Start PLATO API Group — Proxy via Laravel

class PlatomeApiGroup {
  static String getBaseUrl() => EnvConfig.platomBaseUrl;
  static Map<String, String> headers() => {
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
        'Content-Type': 'application/json',
      };
  static Map<String, String> headersWithDb() => {
        'Authorization': 'Bearer ${FFAppState().tokenauth}',
        'Content-Type': 'application/json',
        'db': 'hemedclinic',
      };
}

/// End MEDICAL APPS API Group Code

class GetPatientCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getPatient',
      apiUrl: '${EnvConfig.platomBaseUrl}/patient',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headers(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetproviderCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'getprovider',
      apiUrl: '${EnvConfig.platomBaseUrl}/facility',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headers(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class DeletePatientForAdminOnlyCall {
  static Future<ApiCallResponse> call({
    String? idplato = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Delete Patient For Admin Only',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/patient/${idplato}',
      callType: ApiCallType.DELETE,
      headers: PlatomeApiGroup.headers(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class CeknumberphoneCall {
  static Future<ApiCallResponse> call({
    String? telephone = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'ceknumberphone',
      apiUrl: '${EnvConfig.platomBaseUrl}/search/patient',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headers(),
      params: {
        'telephone': telephone,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetPatientbyidCall {
  static Future<ApiCallResponse> call({
    String? idpatient = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getPatientbyid',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/patient/${idpatient}',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headers(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? givenid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].given_id''',
      ));
}

class GetPatientbyidCopyCall {
  static Future<ApiCallResponse> call({
    String? idpatient = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getPatientbyid Copy',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/patient/${idpatient}',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headers(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:]._id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? name(dynamic response) => (getJsonField(
        response,
        r'''$[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? nric(dynamic response) => (getJsonField(
        response,
        r'''$[:].nric''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? dob(dynamic response) => (getJsonField(
        response,
        r'''$[:].dob''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? email(dynamic response) => (getJsonField(
        response,
        r'''$[:].email''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static String? givenid(dynamic response) => castToType<String>(getJsonField(
        response,
        r'''$[:].given_id''',
      ));
}

class GetArticlesCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'GetArticles',
      apiUrl: '${EnvConfig.wordpressBaseUrl}/posts?per_page=10',
      callType: ApiCallType.GET,
      headers: {},
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<int>? id(dynamic response) => (getJsonField(
        response,
        r'''$[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<String>? title(dynamic response) => (getJsonField(
        response,
        r'''$[:].title.rendered''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? excerpt(dynamic response) => (getJsonField(
        response,
        r'''$[:].excerpt.rendered''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? content(dynamic response) => (getJsonField(
        response,
        r'''$[:].content.rendered''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? featuredmedia(dynamic response) => (getJsonField(
        response,
        r'''$[:].featured_media_src_url''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetReportCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'getReport',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/patient/${patientId}/note',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? note(dynamic response) => (getJsonField(
        response,
        r'''$[:].note''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? time(dynamic response) => (getJsonField(
        response,
        r'''$[:].timestamp''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? kategori(dynamic response) => (getJsonField(
        response,
        r'''$[:].folder_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? author(dynamic response) => (getJsonField(
        response,
        r'''$[:].author''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List? diagnosis(dynamic response) => getJsonField(
        response,
        r'''$[:].diagnosis''',
        true,
      ) as List?;
  static List? attachment(dynamic response) => getJsonField(
        response,
        r'''$[:].attachments''',
        true,
      ) as List?;
  static List<int>? trash(dynamic response) => (getJsonField(
        response,
        r'''$[:].cancel''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<int>? draft(dynamic response) => (getJsonField(
        response,
        r'''$[:].draft''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
}

class LetterCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Letter',
      apiUrl: '${EnvConfig.platomBaseUrl}/letter',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {
        'patient_id': patientId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? subject(dynamic response) => (getJsonField(
        response,
        r'''$[:].subject''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? html(dynamic response) => (getJsonField(
        response,
        r'''$[:].html''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? tgl(dynamic response) => (getJsonField(
        response,
        r'''$[:].created_on''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? author(dynamic response) => (getJsonField(
        response,
        r'''$[:].created_by''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class LetterCopyCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Letter Copy',
      apiUrl: '${EnvConfig.platomBaseUrl}/invoice',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {
        'patient_id': patientId,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? itemname(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? deskripsi(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].dosage''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? kategori(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].category''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? inventori(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].inventory''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<int>? redemptions(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].redemptions''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List? otherpackage(dynamic response) => getJsonField(
        response,
        r'''$[:].item[:].others''',
        true,
      ) as List?;
  static List<String>? givenid(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].given_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List? item(dynamic response) => getJsonField(
        response,
        r'''$[:].item''',
        true,
      ) as List?;
  static List<int>? invoice(dynamic response) => (getJsonField(
        response,
        r'''$[:].invoice''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<int>(x))
          .withoutNulls
          .toList();
  static List<String>? idlist(dynamic response) => (getJsonField(
        response,
        r'''$[:].item[:].invoice_id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetAppointmentCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
    String? modifiedSince = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Get Appointment',
      apiUrl: '${EnvConfig.platomBaseUrl}/appointment',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {
        'patient_id': patientId,
        'modified_since': modifiedSince,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? start(dynamic response) => (getJsonField(
        response,
        r'''$[:].starttime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? end(dynamic response) => (getJsonField(
        response,
        r'''$[:].endtime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetAppointmentUpcomingCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
    String? startDate = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Get Appointment upcoming',
      apiUrl: '${EnvConfig.platomBaseUrl}/appointment',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {
        'patient_id': patientId,
        'start_date': startDate,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? start(dynamic response) => (getJsonField(
        response,
        r'''$[:].starttime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? end(dynamic response) => (getJsonField(
        response,
        r'''$[:].endtime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? title(dynamic response) => (getJsonField(
        response,
        r'''$[:].title''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? doctorCode(dynamic response) => (getJsonField(
        response,
        r'''$[:].code_Background''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? locationCode(dynamic response) => (getJsonField(
        response,
        r'''$[:].code_Top''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetAppointmentDetailsCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
    String? modifiedSince = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'Get Appointment Details',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/appointment/a052e78b3a5547bba54ddbbc83619e93',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {
        'patient_id': patientId,
        'modified_since': modifiedSince,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? start(dynamic response) => (getJsonField(
        response,
        r'''$[:].starttime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? end(dynamic response) => (getJsonField(
        response,
        r'''$[:].endtime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetAppointmentCodeCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Get Appointment Code',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/appointment/codes',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? codes(dynamic response) => (getJsonField(
        response,
        r'''$.Background.codes[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? names(dynamic response) => (getJsonField(
        response,
        r'''$.Background.codes[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? codelocation(dynamic response) => (getJsonField(
        response,
        r'''$.Top.codes[:].id''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? namelocation(dynamic response) => (getJsonField(
        response,
        r'''$.Top.codes[:].name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class GetAppointmentCopyCall {
  static Future<ApiCallResponse> call() async {
    return ApiManager.instance.makeApiCall(
      callName: 'Get Appointment Copy',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/appointments/calendars',
      callType: ApiCallType.GET,
      headers: PlatomeApiGroup.headersWithDb(),
      params: {},
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? start(dynamic response) => (getJsonField(
        response,
        r'''$[:].starttime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? end(dynamic response) => (getJsonField(
        response,
        r'''$[:].endtime''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class EditPatiendCall {
  static Future<ApiCallResponse> call({
    String? patientId = '',
    String? name = '',
    String? dob = '',
    String? address = '',
  }) async {
    final ffApiRequestBody = '''
{
  "name": "${escapeStringForJson(name)}",
  "dob": "${escapeStringForJson(dob)}",
  "address": "${escapeStringForJson(address)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'EditPatiend',
      apiUrl:
          '${EnvConfig.platomBaseUrl}/patient/${patientId}',
      callType: ApiCallType.PUT,
      headers: PlatomeApiGroup.headers(),
      params: {},
      body: ffApiRequestBody,
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

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
