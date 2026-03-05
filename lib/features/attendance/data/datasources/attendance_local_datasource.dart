/*
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_record_model.dart';
import '../models/office_location_model.dart';

abstract class AttendanceLocalDatasource {
  /// Stores [officeLocationModel] in Hive local storage.
  Future<void> saveOfficeLocation(OfficeLocationModel officeLocationModel);

  /// Returns the saved [OfficeLocationModel] from Hive.
  /// Throws [NoSavedOfficeLocationException] if none found.
  Future<OfficeLocationModel> getSavedOfficeLocation();

  /// Appends [attendanceRecordModel] to the local attendance list in Hive.
  Future<void> saveAttendanceRecord(AttendanceRecordModel attendanceRecordModel);

  /// Returns all saved [AttendanceRecordModel] entries from Hive.
  Future<List<AttendanceRecordModel>> getAllAttendanceRecords();
}

class AttendanceLocalDatasourceImpl implements AttendanceLocalDatasource {
  final HiveInterface _hive;

  const AttendanceLocalDatasourceImpl({required HiveInterface hive})
      : _hive = hive;

  Box<String> get _officeLocationBox =>
      _hive.box<String>(AppConstants.officeLocationHiveBoxName);

  Box<String> get _attendanceBox =>
      _hive.box<String>(AppConstants.attendanceHiveBoxName);

  @override
  Future<void> saveOfficeLocation(
    OfficeLocationModel officeLocationModel,
  ) async {
    try {
      final String encodedData =
          jsonEncode(officeLocationModel.toMap());
      await _officeLocationBox.put(
        AppConstants.officeLocationHiveKey,
        encodedData,
      );
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to save office location: ${e.toString()}',
      );
    }
  }

  @override
  Future<OfficeLocationModel> getSavedOfficeLocation() async {
    try {
      final String? encodedData = _officeLocationBox.get(
        AppConstants.officeLocationHiveKey,
      );

      if (encodedData == null) {
        throw const NoSavedOfficeLocationException();
      }

      final Map<String, dynamic> decodedMap =
          jsonDecode(encodedData) as Map<String, dynamic>;

      return OfficeLocationModel.fromMap(decodedMap);
    } on NoSavedOfficeLocationException {
      rethrow;
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to load office location: ${e.toString()}',
      );
    }
  }

  /// Stores the record under its own unique key (prefixed by [_recordKeyPrefix]).
  ///
  /// Using one key per record avoids the read-then-write anti-pattern: the
  /// previous approach read all existing records, appended the new one, then
  /// re-serialised the entire list — a non-atomic sequence vulnerable to
  /// corruption under concurrent writes. Each record now lives independently.
  @override
  Future<void> saveAttendanceRecord(
    AttendanceRecordModel attendanceRecordModel,
  ) async {
    try {
      final String recordKey =
          _buildAttendanceRecordKey(attendanceRecordModel.id);
      await _attendanceBox.put(
        recordKey,
        jsonEncode(attendanceRecordModel.toMap()),
      );
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to save attendance record: ${e.toString()}',
      );
    }
  }

  /// Reads every key that starts with [_recordKeyPrefix] and deserialises each.
  @override
  Future<List<AttendanceRecordModel>> getAllAttendanceRecords() async {
    try {
      final List<AttendanceRecordModel> records = [];

      for (final String key in _attendanceBox.keys.cast<String>()) {
        if (!key.startsWith(AppConstants.attendanceRecordKeyPrefix)) continue;

        final String? encodedData = _attendanceBox.get(key);
        if (encodedData == null) continue;

        final Map<String, dynamic> decodedMap =
            jsonDecode(encodedData) as Map<String, dynamic>;
        records.add(AttendanceRecordModel.fromMap(decodedMap));
      }

      // Return records sorted by most recently marked first.
      records.sort((a, b) => b.markedAt.compareTo(a.markedAt));
      return records;
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to load attendance records: ${e.toString()}',
      );
    }
  }

  String _buildAttendanceRecordKey(String recordId) =>
      '${AppConstants.attendanceRecordKeyPrefix}$recordId';
}
*/


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