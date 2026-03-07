import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/image_batch_model.dart';

// Box name is shared with background worker — keep in sync
const kImageBatchBoxName = 'image_batches';

abstract class ImageQueueLocalDatasource {
  Future<void> saveBatch(ImageBatchModel batch);
  Future<List<ImageBatchModel>> getAllBatches();
  Future<void> updateBatch(ImageBatchModel batch);
  Future<void> deleteBatch(String batchId);
}

class ImageQueueLocalDatasourceImpl implements ImageQueueLocalDatasource {
  final Box<Map> _box;

  ImageQueueLocalDatasourceImpl({required Box<Map> box}) : _box = box;

  /// Throws if the box was closed (e.g. app backgrounded then Hive shut down)
  Box<Map> get _safeBox {
    if (!_box.isOpen) {
      throw CacheException(
          'Hive box is closed — app may have been backgrounded.');
    }
    return _box;
  }

  @override
  Future<void> saveBatch(ImageBatchModel batch) async {
    try {
      await _safeBox.put(batch.id, {
        'id': batch.id,
        'imagesMap': batch.imagesMap,
        'uploadStatusIndex': batch.uploadStatusIndex,
        'createdAt': batch.createdAt.toIso8601String(),
        'retryCount': batch.retryCount,
      });
      // Flush to disk immediately so data survives app kill
      await _safeBox.flush();
      debugPrint('[HiveDS] 💾 Saved batch ${batch.id.substring(0, 8)}');
    } catch (e) {
      debugPrint('[HiveDS] ❌ saveBatch error: $e');
      throw CacheException('Failed to save batch: $e');
    }
  }

  @override
  Future<List<ImageBatchModel>> getAllBatches() async {
    try {
      return _safeBox.values.map((rawMap) {
        final map = Map<String, dynamic>.from(rawMap);
        final imagesRaw = (map['imagesMap'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        return ImageBatchModel(
          id: map['id'] as String,
          imagesMap: imagesRaw,
          uploadStatusIndex: map['uploadStatusIndex'] as int,
          createdAt: DateTime.parse(map['createdAt'] as String),
          retryCount: map['retryCount'] as int,
        );
      }).toList();
    } catch (e) {
      debugPrint('[HiveDS] ❌ getAllBatches error: $e');
      throw CacheException('Failed to load batches: $e');
    }
  }

  @override
  Future<void> updateBatch(ImageBatchModel batch) async {
    // saveBatch already overwrites by key and flushes
    await saveBatch(batch);
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    try {
      await _safeBox.delete(batchId);
      await _safeBox.flush();
      debugPrint('[HiveDS] 🗑️ Deleted batch ${batchId.substring(0, 8)}');
    } catch (e) {
      debugPrint('[HiveDS] ❌ deleteBatch error: $e');
      throw CacheException('Failed to delete batch: $e');
    }
  }
}
