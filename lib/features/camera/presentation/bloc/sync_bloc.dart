import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/retrieve_pending_upload_queue.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';
import '../../../../core/usecases/usecase.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final RetrievePendingUploadQueue retrievePending;
  final AttemptUploadForPendingImages attemptUpload;
  final Connectivity connectivity;

  StreamSubscription? _connectivitySub;
  bool _wasConnected = false;

  SyncBloc({
    required this.retrievePending,
    required this.attemptUpload,
    required this.connectivity,
  }) : super(const SyncInitial()) {
    on<LoadPendingUploadsEvent>(_onLoad);
    on<TriggerUploadEvent>(_onTriggerUpload);
    on<StartConnectivityMonitorEvent>(_onStartMonitor);
    on<ConnectivityChangedEvent>(_onConnectivityChanged);
  }

 /* Future<void> _onLoad(
      LoadPendingUploadsEvent event, Emitter<SyncState> emit) async {
    emit(const SyncLoading());
    final result = await retrievePending(NoParams());
    result.fold(
      (failure) => emit(SyncError(failure.message)),
      (batches) async {
        final connectivity = await this.connectivity.checkConnectivity();
        final isConnected = connectivity != ConnectivityResult.none;
        emit(SyncIdle(pendingBatches: batches, isConnected: isConnected));
      },
    );
  }*/

  Future<void> _onLoad(
      LoadPendingUploadsEvent event, Emitter<SyncState> emit) async {
    emit(const SyncLoading());

    final result = await retrievePending(NoParams());

    if (result.isLeft()) {
      result.fold(
            (failure) => emit(SyncError(failure.message)),
            (_) {},
      );
      return;
    }

    final batches = result.getOrElse(() => []);

    final connectivityResult = await connectivity.checkConnectivity();
    final isConnected = connectivityResult != ConnectivityResult.none;

    emit(SyncIdle(pendingBatches: batches, isConnected: isConnected));
  }

  Future<void> _onTriggerUpload(
      TriggerUploadEvent event, Emitter<SyncState> emit) async {
    final current = state;
    if (current is! SyncIdle) return;

    emit(SyncUploading(batches: current.pendingBatches));
    await attemptUpload(NoParams());

    // Reload after upload attempt
    final result = await retrievePending(NoParams());
    result.fold(
      (failure) => emit(SyncError(failure.message)),
      (batches) => emit(SyncIdle(
        pendingBatches: batches,
        isConnected: current.isConnected,
      )),
    );
  }

  Future<void> _onStartMonitor(
      StartConnectivityMonitorEvent event, Emitter<SyncState> emit) async {
    _connectivitySub?.cancel();
    final initial = await connectivity.checkConnectivity();
    _wasConnected = initial != ConnectivityResult.none;

    _connectivitySub = connectivity.onConnectivityChanged.listen((result) {
      final isNowConnected = result != ConnectivityResult.none;
      add(ConnectivityChangedEvent(isNowConnected));
    });
  }

  Future<void> _onConnectivityChanged(
      ConnectivityChangedEvent event, Emitter<SyncState> emit) async {
    final current = state;

    // Auto-retry when connectivity is restored
    if (event.isConnected && !_wasConnected) {
      _wasConnected = true;
      if (current is SyncIdle &&
          (current.pendingCount > 0 || current.failedCount > 0)) {
        add(const TriggerUploadEvent());
      }
    }

    _wasConnected = event.isConnected;

    if (current is SyncIdle) {
      emit(SyncIdle(
        pendingBatches: current.pendingBatches,
        isConnected: event.isConnected,
      ));
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
