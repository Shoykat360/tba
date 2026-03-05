/*
import 'package:equatable/equatable.dart';
import '../../domain/entities/image_batch.dart';

abstract class SyncState extends Equatable {
  const SyncState();

  @override
  List<Object?> get props => [];
}

/// Emitted before the queue has been loaded from storage.
class SyncInitialState extends SyncState {
  const SyncInitialState();
}

/// Primary state — always carries the full queue snapshot.
class SyncLoadedState extends SyncState {
  final List<ImageBatch> allBatches;

  /// True while upload operations are actively running.
  final bool isUploading;

  /// True when the device has an active internet connection.
  final bool isOnline;

  const SyncLoadedState({
    required this.allBatches,
    required this.isUploading,
    required this.isOnline,
  });

  List<ImageBatch> get pendingBatches =>
      allBatches.where((b) => b.isPending).toList();

  List<ImageBatch> get failedBatches =>
      allBatches.where((b) => b.isFailed).toList();

  List<ImageBatch> get uploadedBatches =>
      allBatches.where((b) => b.isUploaded).toList();

  int get totalPendingImageCount =>
      pendingBatches.fold(0, (sum, b) => sum + b.imageCount);

  SyncLoadedState copyWith({
    List<ImageBatch>? allBatches,
    bool? isUploading,
    bool? isOnline,
  }) {
    return SyncLoadedState(
      allBatches: allBatches ?? this.allBatches,
      isUploading: isUploading ?? this.isUploading,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  List<Object?> get props => [allBatches, isUploading, isOnline];
}

/// One-shot state — upload cycle completed. Listener reloads queue.
class SyncUploadCompletedState extends SyncState {
  final int uploadedCount;
  final int failedCount;

  const SyncUploadCompletedState({
    required this.uploadedCount,
    required this.failedCount,
  });

  @override
  List<Object?> get props => [uploadedCount, failedCount];
}

/// Emitted when the queue storage fails.
class SyncErrorState extends SyncState {
  final String errorMessage;

  const SyncErrorState({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}
*/


import 'package:equatable/equatable.dart';

import '../../domain/entities/image_batch.dart';

abstract class SyncState extends Equatable {
  const SyncState();
  @override
  List<Object?> get props => [];
}

class SyncInitial extends SyncState {
  const SyncInitial();
}

class SyncLoading extends SyncState {
  const SyncLoading();
}

class SyncLoaded extends SyncState {
  final List<ImageBatch> batches;
  const SyncLoaded({required this.batches});
  @override
  List<Object?> get props => [batches];
}

class SyncUploading extends SyncLoaded {
  final String uploadingBatchId;
  const SyncUploading({required super.batches, required this.uploadingBatchId});
  @override
  List<Object?> get props => [batches, uploadingBatchId];
}

class SyncError extends SyncState {
  final String message;
  const SyncError({required this.message});
  @override
  List<Object?> get props => [message];
}