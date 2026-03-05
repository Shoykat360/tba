/*
import 'package:equatable/equatable.dart';
import '../../domain/entities/captured_image.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Fired on [CameraPreviewScreen] init — loads existing queue from storage.
class SyncInitializedEvent extends SyncEvent {
  const SyncInitializedEvent();
}

/// Fired after a successful capture — creates a new batch and queues it.
class NewBatchAddedToQueueEvent extends SyncEvent {
  final List<CapturedImage> capturedImages;
  final String batchName;

  const NewBatchAddedToQueueEvent({
    required this.capturedImages,
    required this.batchName,
  });

  @override
  List<Object?> get props => [capturedImages, batchName];
}

/// Fired when user taps "Upload Now" or connectivity is restored.
class UploadPendingBatchesRequested extends SyncEvent {
  const UploadPendingBatchesRequested();
}

/// Fired when the connectivity stream emits an online event.
class ConnectivityRestoredEvent extends SyncEvent {
  const ConnectivityRestoredEvent();
}

/// Fired when connectivity is lost — updates UI badge without clearing queue.
class ConnectivityLostEvent extends SyncEvent {
  const ConnectivityLostEvent();
}
*/


import 'package:equatable/equatable.dart';

import '../../domain/entities/image_batch.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();
  @override
  List<Object?> get props => [];
}

class LoadPendingBatchesEvent extends SyncEvent {
  const LoadPendingBatchesEvent();
}

class UploadBatchEvent extends SyncEvent {
  final ImageBatch batch;
  const UploadBatchEvent({required this.batch});
  @override
  List<Object?> get props => [batch.id];
}

class RetryAllFailedEvent extends SyncEvent {
  const RetryAllFailedEvent();
}

class CreateAndQueueBatchEvent extends SyncEvent {
  const CreateAndQueueBatchEvent();
}