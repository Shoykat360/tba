import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_record_model.dart';
import '../models/office_location_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveOfficeLocation(OfficeLocationModel location);
  Future<OfficeLocationModel> loadOfficeLocation();
  Future<void> saveAttendanceRecord(AttendanceRecordModel record);
  Future<List<AttendanceRecordModel>> getAttendanceRecords();
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  final SharedPreferences sharedPreferences;

  AttendanceLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> saveOfficeLocation(OfficeLocationModel location) async {
    try {
      final jsonString = jsonEncode(location.toJson());
      await sharedPreferences.setString(AppConstants.officeLocationKey, jsonString);
    } catch (e) {
      throw const LocalStorageException('Failed to save office location.');
    }
  }

  @override
  Future<OfficeLocationModel> loadOfficeLocation() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.officeLocationKey);
      if (jsonString == null) {
        throw const LocalStorageException('No office location saved.');
      }
      return OfficeLocationModel.fromJson(jsonDecode(jsonString));
    } on LocalStorageException {
      rethrow;
    } catch (e) {
      throw const LocalStorageException('Failed to load office location.');
    }
  }

  @override
  Future<void> saveAttendanceRecord(AttendanceRecordModel record) async {
    try {
      final existing = await _getRawRecords();
      existing.add(record.toJson());
      await sharedPreferences.setString(
        AppConstants.attendanceRecordsKey,
        jsonEncode(existing),
      );
    } catch (e) {
      throw const LocalStorageException('Failed to save attendance record.');
    }
  }

  @override
  Future<List<AttendanceRecordModel>> getAttendanceRecords() async {
    try {
      final raw = await _getRawRecords();
      return raw.map((e) => AttendanceRecordModel.fromJson(e)).toList();
    } catch (e) {
      throw const LocalStorageException('Failed to load attendance records.');
    }
  }

  Future<List<Map<String, dynamic>>> _getRawRecords() async {
    final jsonString = sharedPreferences.getString(AppConstants.attendanceRecordsKey);
    if (jsonString == null) return [];
    final List<dynamic> decoded = jsonDecode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }
}