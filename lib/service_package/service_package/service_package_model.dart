import '/backend/api_requests/api_calls.dart';
import '/backend/api_requests/api_manager.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/components/skeleton_loaders.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'service_package_widget.dart' show ServicePackageWidget;

class ServicePackageModel extends FlutterFlowModel<ServicePackageWidget> {
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  List<Map<String, dynamic>> packages = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  Future<void> loadPackages() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final response = await MedicalAppsApiGroup.servicesPackagesCall.call();
      if (response.succeeded && response.statusCode == 200) {
        final ids = MedicalAppsApiGroup.servicesPackagesCall.id(response.jsonBody) ?? [];
        final names = MedicalAppsApiGroup.servicesPackagesCall.name(response.jsonBody) ?? [];
        final descriptions = MedicalAppsApiGroup.servicesPackagesCall.description(response.jsonBody) ?? [];
        final images = MedicalAppsApiGroup.servicesPackagesCall.image(response.jsonBody) ?? [];
        final sortOrders = MedicalAppsApiGroup.servicesPackagesCall.sortOrder(response.jsonBody) ?? [];

        packages = List.generate(ids.length, (i) => {
          'id': ids[i],
          'name': names.length > i ? names[i] : '',
          'description': descriptions.length > i ? descriptions[i] : '',
          'image': images.length > i ? images[i] : '',
          'sort_order': sortOrders.length > i ? sortOrders[i] : 0,
        });

        isLoading = false;
      } else {
        hasError = true;
        errorMessage = 'Something went wrong';
        isLoading = false;
      }
    } catch (e) {
      hasError = true;
      errorMessage = 'Something went wrong';
      isLoading = false;
    }

    notifyListeners();
  }
}
