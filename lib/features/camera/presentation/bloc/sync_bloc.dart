import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/background/background_upload_worker.dart';
import '../../domain/usecases/camera_usecases.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final RetrievePendingUploadQueue retrievePendingQueueUseCase;
  final AttemptUploadForPendingImages attemptUploadUseCase;
  final Connectivity connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivityStreamSub;
  Timer? _connectivityPollingTimer;
  bool _wasConnectedLastCheck = false;
  bool _isUploadCurrentlyRunning = false;

  SyncBloc({
    required this.retrievePendingQueueUseCase,
    required this.attemptUploadUseCase,
    required this.connectivity,
  }) : super(const SyncInitial()) {
    on<LoadPendingUploadsEvent>(_handleLoadPendingUploads);
    on<TriggerUploadEvent>(_handleTriggerUpload);
    on<StartConnectivityMonitorEvent>(_handleStartConnectivityMonitor);
    on<ConnectivityStatusChangedEvent>(_handleConnectivityStatusChanged);
  }

  // ── Load queue ─────────────────────────────────────────────────────────────

  Future<void> _handleLoadPendingUploads(
      LoadPendingUploadsEvent event, Emitter<SyncState> emit) async {
    emit(const SyncLoading());

    // retrievePendingUploadQueue also resets any stuck "uploading" batches
    // (batches that were mid-upload when the app was killed).
    // This is the entry point called on app resume, so the reset always
    // happens before any upload attempt.
    final result = await retrievePendingQueueUseCase(NoParams());

    if (result.leftOrNull != null) {
      debugPrint(
          '[SyncBloc] ❌ Load queue failed: ${result.leftOrNull?.message}');
      emit(SyncError(result.leftOrNull?.message ?? 'Failed to load queue'));
      return;
    }

    final batches = result.rightOrNull ?? [];
    final isCurrentlyOnline = await checkForRealInternet();

    debugPrint(
        '[SyncBloc] 📋 Loaded ${batches.length} batches | online=$isCurrentlyOnline');
    emit(SyncIdle(pendingBatches: batches, isConnected: isCurrentlyOnline));

    // BUG FIX — After app restart, if there are pending/failed batches AND
    // we already have internet, trigger an upload immediately instead of
    // waiting for the connectivity monitor to fire a change event (which
    // it won't, because the status hasn't changed).
    if (isCurrentlyOnline && batches.any((b) => b.isPending || b.isFailed)) {
      debugPrint(
          '[SyncBloc] 🔁 Found ${batches.where((b) => b.isPending || b.isFailed).length} '
              'pending/failed batches on load — triggering upload');
      add(const TriggerUploadEvent());
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  Future<void> _handleTriggerUpload(
      TriggerUploadEvent event, Emitter<SyncState> emit) async {
    final currentState = state;
    if (currentState is! SyncIdle) return;

    if (_isUploadCurrentlyRunning) {
      debugPrint('[SyncBloc] ⚠️ Upload already running — skipping');
      return;
    }

    final isOnline = await checkForRealInternet();
    if (!isOnline) {
      debugPrint('[SyncBloc] 📵 No real internet — queue preserved');
      emit(SyncIdle(
          pendingBatches: currentState.pendingBatches, isConnected: false));
      return;
    }

    _isUploadCurrentlyRunning = true;
    debugPrint(
        '[SyncBloc] 🚀 Starting upload — '
            'pending=${currentState.pendingCount}, failed=${currentState.failedCount}');
    emit(SyncUploading(batches: currentState.pendingBatches));

    final uploadResult = await attemptUploadUseCase(NoParams());
    _isUploadCurrentlyRunning = false;

    // Always reload queue after upload to show accurate statuses
    final reloadResult = await retrievePendingQueueUseCase(NoParams());
    final refreshedBatches = reloadResult.rightOrNull ?? [];
    final stillOnline = await checkForRealInternet();

    if (uploadResult.leftOrNull != null) {
      debugPrint(
          '[SyncBloc] ❌ Upload error: ${uploadResult.leftOrNull?.message}');
    } else {
      final uploadedCount =
          refreshedBatches.where((b) => b.isUploaded).length;
      debugPrint(
          '[SyncBloc] ✅ Upload cycle done — uploaded=$uploadedCount, '
              'remaining=${refreshedBatches.where((b) => b.isPending || b.isFailed).length}');
    }

    emit(SyncIdle(pendingBatches: refreshedBatches, isConnected: stillOnline));
  }

  // ── Connectivity monitor ───────────────────────────────────────────────────

  Future<void> _handleStartConnectivityMonitor(
      StartConnectivityMonitorEvent event,
      Emitter<SyncState> emit) async {
    _connectivityStreamSub?.cancel();
    _connectivityPollingTimer?.cancel();

    _wasConnectedLastCheck = await checkForRealInternet();
    debugPrint(
        '[SyncBloc] 🌐 Monitor started | '
            'initial=${_wasConnectedLastCheck ? "ONLINE" : "OFFLINE"}');

    // Stream listener — fires when network adapter changes
    _connectivityStreamSub =
        connectivity.onConnectivityChanged.listen((results) async {
          final hasNetworkAdapter =
          results.any((r) => r != ConnectivityResult.none);
          if (!hasNetworkAdapter) {
            debugPrint('[SyncBloc] 🌐 Stream: no adapter → OFFLINE');
            add(const ConnectivityStatusChangedEvent(false));
          } else {
            final isOnline = await checkForRealInternet();
            debugPrint(
                '[SyncBloc] 🌐 Stream: adapter present, internet=$isOnline');
            add(ConnectivityStatusChangedEvent(isOnline));
          }
        });

    // Polling fallback every 4 seconds — catches captive portals and
    // cases where the stream does not fire
    _connectivityPollingTimer =
        Timer.periodic(const Duration(seconds: 4), (_) async {
          final isOnline = await checkForRealInternet();
          if (isOnline != _wasConnectedLastCheck) {
            debugPrint(
                '[SyncBloc] 🌐 Poll detected change → '
                    '${isOnline ? "ONLINE" : "OFFLINE"}');
            add(ConnectivityStatusChangedEvent(isOnline));
          }
        });
  }

  Future<void> _handleConnectivityStatusChanged(
      ConnectivityStatusChangedEvent event,
      Emitter<SyncState> emit) async {
    final currentState = state;

    final wasOffline = !_wasConnectedLastCheck;
    final nowOnline = event.isConnected;

    if (wasOffline && nowOnline) {
      debugPrint('[SyncBloc] 🔁 Connection restored — auto retrying uploads');
      _wasConnectedLastCheck = true;

      if (currentState is SyncIdle &&
          (currentState.pendingCount > 0 || currentState.failedCount > 0)) {
        // Queue a background task in case the app goes away soon
        await BackgroundSyncScheduler.triggerImmediateUploadNow();
        add(const TriggerUploadEvent());
        return;
      }
    }

    if (!event.isConnected && _wasConnectedLastCheck) {
      debugPrint('[SyncBloc] 📵 Internet lost — uploads paused, queue preserved');
    }

    _wasConnectedLastCheck = event.isConnected;

    if (currentState is SyncIdle) {
      emit(SyncIdle(
        pendingBatches: currentState.pendingBatches,
        isConnected: event.isConnected,
      ));
    }
  }

  // ── Internet check ─────────────────────────────────────────────────────────

  /// DNS lookup to verify real internet (not just adapter presence).
  Future<bool> checkForRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      debugPrint('[SyncBloc] 🔍 Internet check: $isOnline');
      return isOnline;
    } on SocketException {
      debugPrint('[SyncBloc] 🔍 Internet check: false (SocketException)');
      return false;
    } on TimeoutException {
      debugPrint('[SyncBloc] 🔍 Internet check: false (Timeout)');
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _connectivityStreamSub?.cancel();
    _connectivityPollingTimer?.cancel();
    return super.close();
  }
}