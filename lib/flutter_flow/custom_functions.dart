import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

String? getExcerpt(String? content) {
  const int maxLength = 100;
  final safeContent = content ?? '';
  if (safeContent.isEmpty) return '';
  if (safeContent.length <= maxLength) return safeContent;
  return safeContent.substring(0, maxLength) + '...';
}

String formatDateTimeDMY(String inputDateTime) {
  try {
    final parsedDate = DateTime.parse(inputDateTime);
    final outputFormat = DateFormat('dd/MM/yy HH:mm');
    return outputFormat.format(parsedDate);
  } catch (e) {
    return inputDateTime; // fallback jika format salah
  }
}

bool? isBeforeOrNow(String inputDateTime) {
  try {
    final parsedDate = DateTime.parse(inputDateTime);
    final now = DateTime.now();
    print(parsedDate.isBefore(now));
    return parsedDate.isAfter(now) || parsedDate.isAtSameMomentAs(now);
  } catch (e) {
    return false; // fallback jika format salah
  }
}

int? dateToUnixSeconds(DateTime inputDate) {
  final utcDate = DateTime.utc(inputDate.year, inputDate.month, inputDate.day);
  return utcDate.millisecondsSinceEpoch ~/ 1000;
}

bool? isbeforenow(String inputDateTime) {
  try {
    final parsedDateTime = DateTime.parse(inputDateTime);

    // Hapus jam-menit-detik dari keduanya
    final today = DateTime.now();
    final nowDateOnly = DateTime(today.year, today.month, today.day);
    final inputDateOnly =
        DateTime(parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);

    return !inputDateOnly.isBefore(nowDateOnly);
  } catch (e) {
    return false;
  }
}

String? getdoctorname(
  String code,
  List<String> listCode,
  List<String> listDoctorName,
) {
  final index = listCode.indexOf(code);
  if (index != -1 && index < listDoctorName.length) {
    return listDoctorName[index];
  }
  return ''; // Atau bisa return 'Tidak ditemukan'
}

String? flattenOrPickAttachment(dynamic attachments) {
  // Jika null → tidak ada lampiran
  if (attachments == null) return null;

  // Jika hanya 1 dan berupa String
  if (attachments is String) return attachments;

  // Jika berbentuk List
  if (attachments is List) {
    if (attachments.isEmpty) return null;
    return attachments.join(', ');
  }

  // Jika format tidak dikenali
  return null;
}

String? countMatchingGivenId(
  List<dynamic> otherPackage,
  String targetPackageId,
  List<String> givenIds,
  List<String> listCategory,
  List<int> remaining,
  List<String> idinvoice,
  String idset,
) {
// Cari index pertama dari package_id yang cocok DAN kategorinya "Treatment"
  int targetIndex = -1;
  int indexpackagekedua = 0;
  for (int i = 0; i < otherPackage.length; i++) {
    if (i >= listCategory.length) continue; // Hindari error out of range
    if (otherPackage[i] is Map &&
        otherPackage[i]['package_id'] == targetPackageId &&
        listCategory[i] == 'Treatment') {
      targetIndex = i;
      indexpackagekedua = targetIndex;
      break;
    }
  }

  // Jika tidak ketemu
  if (targetIndex == -1 ||
      targetIndex >= givenIds.length ||
      targetIndex >= listCategory.length) {
    return '0';
  }

  // Ambil givenId dari index target
  String targetGivenId = givenIds[targetIndex];

  // Hitung berapa banyak givenId yang sama, kategori "Treatment", selain index target
  int count = 0;
  for (int i = 0; i < givenIds.length; i++) {
    if (i == targetIndex) continue;
    if (listCategory[i] == 'Treatment' &&
        givenIds[i] == targetGivenId &&
        idinvoice[i] == idset) {
      count++;
    }
  }

  int remain = remaining[indexpackagekedua] - count;

  return remain.toString();
}

String getnamepdf(String url) {
  try {
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
  } catch (e) {
    return 'unknown_file';
  }
  return 'unknown_file';
}

String? getdayname(String? tgldate) {
  final s = (tgldate ?? '').trim();
  if (s.isEmpty) return '';

  try {
    final dt = DateFormat('dd/MM/yyyy, HH:mm').parseStrict(s);
    return DateFormat('EEEE', 'en_US').format(dt); // Thursday, etc.
  } catch (_) {
    return ''; // fallback kalau format invalid
  }
}

bool? isFutureDateTime(String? input) {
  if (input == null) return false;
  final s = input.trim();
  if (s.isEmpty) return false;

  try {
    final dt = DateFormat('dd/MM/yyyy, HH:mm').parseStrict(s);
    return dt.isAfter(DateTime
        .now()); // ganti ke !dt.isBefore(DateTime.now()) kalau mau ">= now"
  } catch (_) {
    return false; // format salah -> false
  }
}

bool? isOneDayBefore(String? dateString) {
  try {
    // Contoh format: "25/10/2025, 09:30"
    final parts = dateString!.split(',');
    if (parts.length != 2) return false;

    final datePart = parts[0].trim(); // 25/10/2025
    final timePart = parts[1].trim(); // 09:30

    final datePieces = datePart.split('/');
    final timePieces = timePart.split(':');

    if (datePieces.length != 3 || timePieces.length != 2) return false;

    final day = int.parse(datePieces[0]);
    final month = int.parse(datePieces[1]);
    final year = int.parse(datePieces[2]);

    final hour = int.parse(timePieces[0]);
    final minute = int.parse(timePieces[1]);

    final targetDate = DateTime(year, month, day, hour, minute);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final diff = target.difference(today).inDays;

    return diff == 1; // True hanya H-1
  } catch (e) {
    return false;
  }
}
