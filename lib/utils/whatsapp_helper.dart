import 'dart:io';

class WhatsAppHelper {
  static String buildPreFilledMessage({
    required String branchName,
    required String patientName,
    required String patientNric,
    required String doctorName,
    required String date,
    required String time,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Hi He Clinic $branchName!');
    buffer.writeln();
    buffer.writeln('I would like to book an appointment:');
    buffer.writeln('- Name: $patientName');
    buffer.writeln('- NRIC: $patientNric');
    buffer.writeln('- Branch: $branchName');
    buffer.writeln('- Doctor: $doctorName');
    buffer.writeln('- Date: $date');
    buffer.writeln('- Time: $time');
    buffer.writeln();
    buffer.write('Please confirm my appointment. Thank you!');
    return buffer.toString();
  }

  static String buildDeepLink({
    required String phoneNumber,
    required String message,
  }) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    final encoded = Uri.encodeComponent(message);
    return 'https://wa.me/$cleaned?text=$encoded';
  }

  static bool get isWhatsAppAvailable {
    if (Platform.isAndroid) {
      return true;
    }
    return true;
  }

  static String getWhatsAppInstallUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=com.whatsapp';
    }
    return 'https://apps.apple.com/app/id310633997';
  }
}
