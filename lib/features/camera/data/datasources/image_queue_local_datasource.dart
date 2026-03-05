/*
import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/image_batch_model.dart';

abstract class ImageQueueLocalDatasource {
  /// Returns all [ImageBatchModel] entries stored in the Hive queue.
  Future<List<ImageBatchModel>> getAllBatchesFromQueue();

  /// Appends or updates [batchModel] in the Hive queue.
  /// If a batch with the same id already exists it is replaced.
  Future<void> saveOrUpdateBatchInQueue(ImageBatchModel batchModel);

  /// Removes the batch with [batchId] from the Hive queue.
  Future<void> removeBatchFromQueue(String batchId);
}

class ImageQueueLocalDatasourceImpl implements ImageQueueLocalDatasource {
  final HiveInterface _hive;

  const ImageQueueLocalDatasourceImpl({required HiveInterface hive})
      : _hive = hive;

  Box<String> get _queueBox =>
      _hive.box<String>(AppConstants.imageQueueHiveBoxName);

  @override
  Future<List<ImageBatchModel>> getAllBatchesFromQueue() async {
    try {
      final String? encodedData =
          _queueBox.get(AppConstants.imageQueueHiveKey);

      if (encodedData == null) return [];

      final List<dynamic> decoded =
          jsonDecode(encodedData) as List<dynamic>;

      return decoded
          .map((e) => ImageBatchModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to load image queue: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> saveOrUpdateBatchInQueue(ImageBatchModel batchModel) async {
    try {
      final List<ImageBatchModel> existing = await getAllBatchesFromQueue();

      // Replace existing entry with same id, or append if new.
      final int existingIndex =
          existing.indexWhere((b) => b.id == batchModel.id);

      if (existingIndex >= 0) {
        existing[existingIndex] = batchModel;
      } else {
        existing.add(batchModel);
      }

      final List<Map<String, dynamic>> encodable =
          existing.map((b) => b.toMap()).toList();

      await _queueBox.put(
        AppConstants.imageQueueHiveKey,
        jsonEncode(encodable),
      );
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to save batch to queue: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeBatchFromQueue(String batchId) async {
    try {
      final List<ImageBatchModel> existing = await getAllBatchesFromQueue();
      existing.removeWhere((b) => b.id == batchId);

      final List<Map<String, dynamic>> encodable =
          existing.map((b) => b.toMap()).toList();

      await _queueBox.put(
        AppConstants.imageQueueHiveKey,
        jsonEncode(encodable),
      );
    } catch (e) {
      throw LocalStorageException(
        message: 'Failed to remove batch from queue: ${e.toString()}',
      );
    }
  }
}
*/


