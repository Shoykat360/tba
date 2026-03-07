import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_record_model.dart';
import '../models/office_location_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveOfficeLocationToStorage(OfficeLocationModel location);
  Future<OfficeLocationModel> readOfficeLocationFromStorage();
  Future<void> saveAttendanceRecordToStorage(AttendanceRecordModel record);
  Future<List<AttendanceRecordModel>> readAllAttendanceRecordsFromStorage();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final SharedPreferences sharedPreferences;

  AttendanceLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveOfficeLocationToStorage(OfficeLocationModel location) async {
    try {
      final String encodedJson = jsonEncode(location.toJson());
      await sharedPreferences.setString(AppConstants.officeLocationKey, encodedJson);
    } catch (e) {
      throw const LocalStorageException('Failed to save office location.');
    }
  }

  @override
  Future<OfficeLocationModel> readOfficeLocationFromStorage() async {
    try {
      final String? encodedJson =
          sharedPreferences.getString(AppConstants.officeLocationKey);

      if (encodedJson == null) {
        throw const LocalStorageException('No office location saved.');
      }

      return OfficeLocationModel.fromJson(jsonDecode(encodedJson));
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw const LocalStorageException('Failed to load office location.');
    }
  }

  @override
  Future<void> saveAttendanceRecordToStorage(AttendanceRecordModel record) async {
    try {
      final List<Map<String, dynamic>> existingRecords =
          await readRawRecordsFromStorage();
      existingRecords.add(record.toJson());
      await sharedPreferences.setString(
        AppConstants.attendanceRecordsKey,
        jsonEncode(existingRecords),
      );
    } catch (e) {
      throw const LocalStorageException('Failed to save attendance record.');
    }
  }

  @override
  Future<List<AttendanceRecordModel>> readAllAttendanceRecordsFromStorage() async {
    try {
      final List<Map<String, dynamic>> rawRecords =
          await readRawRecordsFromStorage();
      return rawRecords
          .map((rawRecord) => AttendanceRecordModel.fromJson(rawRecord))
          .toList();
    } catch (e) {
      throw const LocalStorageException('Failed to load attendance records.');
    }
  }

  Future<List<Map<String, dynamic>>> readRawRecordsFromStorage() async {
    final String? encodedJson =
        sharedPreferences.getString(AppConstants.attendanceRecordsKey);
    if (encodedJson == null) return [];
    final List<dynamic> decodedList = jsonDecode(encodedJson);
    return decodedList.cast<Map<String, dynamic>>();
  }
}
