import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/image_batch_model.dart';

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

  @override
  Future<void> saveBatch(ImageBatchModel batch) async {
    try {
      await _box.put(batch.id, {
        'id': batch.id,
        'imagesMap': batch.imagesMap,
        'uploadStatusIndex': batch.uploadStatusIndex,
        'createdAt': batch.createdAt.toIso8601String(),
        'retryCount': batch.retryCount,
      });
    } catch (e) {
      throw CacheException('Failed to save batch: $e');
    }
  }

  @override
  Future<List<ImageBatchModel>> getAllBatches() async {
    try {
      return _box.values.map((rawMap) {
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
      throw CacheException('Failed to load batches: $e');
    }
  }

  @override
  Future<void> updateBatch(ImageBatchModel batch) async {
    await saveBatch(batch);
  }

  @override
  Future<void> deleteBatch(String batchId) async {
    try {
      await _box.delete(batchId);
    } catch (e) {
      throw CacheException('Failed to delete batch: $e');
    }
  }
}
