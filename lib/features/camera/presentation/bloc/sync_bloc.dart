/*
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../domain/usecases/retrieve_pending_upload_queue.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';
import '../../../../core/usecases/usecase.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final RetrievePendingUploadQueue retrievePending;
  final AttemptUploadForPendingImages attemptUpload;
  final Connectivity connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _connectivityPollTimer;
  bool _wasConnected = false;
  bool _isUploadInProgress = false;

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

  Future<void> _onLoad(
      LoadPendingUploadsEvent event, Emitter<SyncState> emit) async {
    emit(const SyncLoading());

    final result = await retrievePending(NoParams());

    if (result.leftOrNull != null) {
      debugPrint('[SyncBloc] ❌ Failed to load queue: ${result.leftOrNull?.message}');
      emit(SyncError(result.leftOrNull?.message ?? 'Failed to load queue'));
      return;
    }

    final batches = result.rightOrNull ?? [];
    final isConnected = await _checkConnectivity();

    debugPrint('[SyncBloc] ✅ Loaded ${batches.length} batches | connected=$isConnected');
    emit(SyncIdle(pendingBatches: batches, isConnected: isConnected));
  }

  Future<void> _onTriggerUpload(
      TriggerUploadEvent event, Emitter<SyncState> emit) async {
    final current = state;
    if (current is! SyncIdle) return;
    if (_isUploadInProgress) {
      debugPrint('[SyncBloc] ⚠️ Upload already in progress, skipping');
      return;
    }

    final isConnected = await _checkConnectivity();

    if (!isConnected) {
      debugPrint('[SyncBloc] 📵 No connection — keeping ${current.pendingBatches.length} batches in local queue');
      emit(SyncIdle(pendingBatches: current.pendingBatches, isConnected: false));
      return;
    }

    _isUploadInProgress = true;
    debugPrint('[SyncBloc] 🚀 Starting upload for ${current.pendingCount} pending + ${current.failedCount} failed batches');
    emit(SyncUploading(batches: current.pendingBatches));

    final result = await attemptUpload(NoParams());
    _isUploadInProgress = false;

    final reloadResult = await retrievePending(NoParams());
    final updatedBatches = reloadResult.rightOrNull ?? [];
    final stillConnected = await _checkConnectivity();

    if (result.leftOrNull != null) {
      debugPrint('[SyncBloc] ❌ Upload failed: ${result.leftOrNull?.message} — images remain in local queue');
      emit(SyncIdle(pendingBatches: updatedBatches, isConnected: stillConnected));
      return;
    }

    final uploadedCount = updatedBatches.where((b) => b.isUploaded).length;
    final stillPending = updatedBatches.where((b) => b.isPending || b.isFailed).length;
    debugPrint('[SyncBloc] ✅ Upload complete — uploaded=$uploadedCount, stillPending=$stillPending');

    emit(SyncIdle(pendingBatches: updatedBatches, isConnected: stillConnected));
  }

  Future<void> _onStartMonitor(
      StartConnectivityMonitorEvent event, Emitter<SyncState> emit) async {
    _connectivitySub?.cancel();
    _connectivityPollTimer?.cancel();

    // Check initial state
    _wasConnected = await _checkConnectivity();
    debugPrint('[SyncBloc] 🌐 Monitor started | initial=${_wasConnected ? "ONLINE" : "OFFLINE"}');

    // ── Stream listener (fires on most devices) ──────────────────────
    _connectivitySub = connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);
      debugPrint('[SyncBloc] 🌐 Stream event → ${isConnected ? "ONLINE" : "OFFLINE"}');
      add(ConnectivityChangedEvent(isConnected));
    });

    // ── Polling fallback every 3 seconds (fixes Android reliability) ──
    _connectivityPollTimer = Timer.periodic(
      const Duration(seconds: 3),
          (_) async {
        final isConnected = await _checkConnectivity();
        if (isConnected != _wasConnected) {
          debugPrint('[SyncBloc] 🌐 Poll detected change → ${isConnected ? "ONLINE" : "OFFLINE"}');
          add(ConnectivityChangedEvent(isConnected));
        }
      },
    );
  }

  Future<void> _onConnectivityChanged(
      ConnectivityChangedEvent event, Emitter<SyncState> emit) async {
    final current = state;

    final wasOffline = !_wasConnected;
    final nowOnline = event.isConnected;

    // Connection restored → auto retry
    if (wasOffline && nowOnline) {
      debugPrint('[SyncBloc] 🔁 Connection restored — auto-retrying pending uploads');
      _wasConnected = true;

      if (current is SyncIdle &&
          (current.pendingCount > 0 || current.failedCount > 0)) {
        add(const TriggerUploadEvent());
        return;
      }
    }

    if (!event.isConnected && _wasConnected) {
      debugPrint('[SyncBloc] 📵 Connection lost — uploads paused, queue preserved locally');
    }

    _wasConnected = event.isConnected;

    // Update UI connectivity status
    if (current is SyncIdle) {
      emit(SyncIdle(
        pendingBatches: current.pendingBatches,
        isConnected: event.isConnected,
      ));
    }
  }

  /// Single source of truth for connectivity check
  Future<bool> _checkConnectivity() async {
    try {
      final results = await connectivity.checkConnectivity();
      // checkConnectivity returns List in connectivity_plus ^6.x
      if (results is List) {
        return (results as List<ConnectivityResult>)
            .any((r) => r != ConnectivityResult.none);
      }
      return results != ConnectivityResult.none;
    } catch (e) {
      debugPrint('[SyncBloc] ⚠️ Connectivity check error: $e');
      return false;
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _connectivityPollTimer?.cancel();
    return super.close();
  }
}*/


import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/extensions/either_extensions.dart';
import '../../domain/usecases/retrieve_pending_upload_queue.dart';
import '../../domain/usecases/attempt_upload_for_pending_images.dart';
import '../../../../core/usecases/usecase.dart';
import 'sync_event.dart';
import 'sync_state.dart';


class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final RetrievePendingUploadQueue retrievePending;
  final AttemptUploadForPendingImages attemptUpload;
  final Connectivity connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _connectivityPollTimer;
  bool _wasConnected = false;
  bool _isUploadInProgress = false;

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

  Future<void> _onLoad(
      LoadPendingUploadsEvent event, Emitter<SyncState> emit) async {
    emit(const SyncLoading());

    final result = await retrievePending(NoParams());

    if (result.leftOrNull != null) {
      debugPrint('[SyncBloc] ❌ Failed to load queue: ${result.leftOrNull?.message}');
      emit(SyncError(result.leftOrNull?.message ?? 'Failed to load queue'));
      return;
    }

    final batches = result.rightOrNull ?? [];
    final isConnected = await _hasRealInternet();

    debugPrint('[SyncBloc] ✅ Loaded ${batches.length} batches | internet=$isConnected');
    emit(SyncIdle(pendingBatches: batches, isConnected: isConnected));
  }

  Future<void> _onTriggerUpload(
      TriggerUploadEvent event, Emitter<SyncState> emit) async {
    final current = state;
    if (current is! SyncIdle) return;
    if (_isUploadInProgress) {
      debugPrint('[SyncBloc] ⚠️ Upload already in progress, skipping');
      return;
    }

    // Validate REAL internet — not just WiFi/data connected
    final isConnected = await _hasRealInternet();

    if (!isConnected) {
      debugPrint('[SyncBloc] 📵 No real internet — keeping ${current.pendingBatches.length} batches in local queue');
      emit(SyncIdle(pendingBatches: current.pendingBatches, isConnected: false));
      return;
    }

    _isUploadInProgress = true;
    debugPrint('[SyncBloc] 🚀 Starting upload for ${current.pendingCount} pending + ${current.failedCount} failed batches');
    emit(SyncUploading(batches: current.pendingBatches));

    final result = await attemptUpload(NoParams());
    _isUploadInProgress = false;

    final reloadResult = await retrievePending(NoParams());
    final updatedBatches = reloadResult.rightOrNull ?? [];
    final stillConnected = await _hasRealInternet();

    if (result.leftOrNull != null) {
      debugPrint('[SyncBloc] ❌ Upload failed: ${result.leftOrNull?.message} — images remain in local queue');
      emit(SyncIdle(pendingBatches: updatedBatches, isConnected: stillConnected));
      return;
    }

    final uploadedCount = updatedBatches.where((b) => b.isUploaded).length;
    final stillPending = updatedBatches.where((b) => b.isPending || b.isFailed).length;
    debugPrint('[SyncBloc] ✅ Upload complete — uploaded=$uploadedCount, stillPending=$stillPending');

    emit(SyncIdle(pendingBatches: updatedBatches, isConnected: stillConnected));
  }

  Future<void> _onStartMonitor(
      StartConnectivityMonitorEvent event, Emitter<SyncState> emit) async {
    _connectivitySub?.cancel();
    _connectivityPollTimer?.cancel();

    _wasConnected = await _hasRealInternet();
    debugPrint('[SyncBloc] 🌐 Monitor started | initial=${_wasConnected ? "ONLINE" : "OFFLINE"}');

    // Stream listener
    _connectivitySub = connectivity.onConnectivityChanged.listen((results) async {
      final hasAdapter = results.any((r) => r != ConnectivityResult.none);
      if (!hasAdapter) {
        // Definitely offline — no need to ping
        debugPrint('[SyncBloc] 🌐 Stream: no network adapter → OFFLINE');
        add(ConnectivityChangedEvent(false));
      } else {
        // Has adapter but validate real internet
        final hasInternet = await _hasRealInternet();
        debugPrint('[SyncBloc] 🌐 Stream: adapter present, internet=$hasInternet');
        add(ConnectivityChangedEvent(hasInternet));
      }
    });

    // Polling fallback every 4 seconds
    _connectivityPollTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) async {
        final isConnected = await _hasRealInternet();
        if (isConnected != _wasConnected) {
          debugPrint('[SyncBloc] 🌐 Poll detected change → ${isConnected ? "ONLINE" : "OFFLINE"}');
          add(ConnectivityChangedEvent(isConnected));
        }
      },
    );
  }

  Future<void> _onConnectivityChanged(
      ConnectivityChangedEvent event, Emitter<SyncState> emit) async {
    final current = state;

    final wasOffline = !_wasConnected;
    final nowOnline = event.isConnected;

    // Connection restored → auto retry
    if (wasOffline && nowOnline) {
      debugPrint('[SyncBloc] 🔁 Connection restored — auto-retrying pending uploads');
      _wasConnected = true;

      if (current is SyncIdle &&
          (current.pendingCount > 0 || current.failedCount > 0)) {
        add(const TriggerUploadEvent());
        return;
      }
    }

    if (!event.isConnected && _wasConnected) {
      debugPrint('[SyncBloc] 📵 Real internet lost — uploads paused, queue preserved');
    }

    _wasConnected = event.isConnected;

    if (current is SyncIdle) {
      emit(SyncIdle(
        pendingBatches: current.pendingBatches,
        isConnected: event.isConnected,
      ));
    }
  }

  /// Checks for REAL internet by attempting a DNS lookup.
  /// This correctly returns false when:
  /// - WiFi connected but no internet (e.g. hotel portal)
  /// - Mobile data on but no data plan/signal
  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      final hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      debugPrint('[SyncBloc] 🔍 Internet check: $hasInternet');
      return hasInternet;
    } on SocketException catch (_) {
      debugPrint('[SyncBloc] 🔍 Internet check: false (SocketException)');
      return false;
    } on TimeoutException catch (_) {
      debugPrint('[SyncBloc] 🔍 Internet check: false (Timeout)');
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    _connectivityPollTimer?.cancel();
    return super.close();
  }
}
