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

class SyncIdle extends SyncState {
  final List<ImageBatch> pendingBatches;
  final bool isConnected;

  const SyncIdle({
    required this.pendingBatches,
    required this.isConnected,
  });

  int get pendingCount =>
      pendingBatches.where((b) => b.isPending).length;
  int get failedCount =>
      pendingBatches.where((b) => b.isFailed).length;
  int get uploadedCount =>
      pendingBatches.where((b) => b.isUploaded).length;

  @override
  List<Object?> get props => [pendingBatches, isConnected];
}

class SyncUploading extends SyncState {
  final List<ImageBatch> batches;
  const SyncUploading({required this.batches});

  @override
  List<Object?> get props => [batches];
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);

  @override
  List<Object?> get props => [message];
}
