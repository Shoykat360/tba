import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/image_batch.dart';
import '../bloc/camera_bloc.dart';
import '../bloc/camera_event.dart';
import '../bloc/camera_state.dart';
import '../bloc/sync_bloc.dart';
import '../bloc/sync_event.dart';
import '../bloc/sync_state.dart';
import '../widgets/camera_controls_overlay.dart';
import '../widgets/focus_indicator_widget.dart';
import '../widgets/pending_uploads_list.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() =>
      _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen>
    with WidgetsBindingObserver {
  // Pinch-to-zoom: track the zoom level at the moment the pinch starts
  double _zoomAtPinchStart = 1.0;
  double _currentDisplayZoom = 1.0;
  bool _showPendingUploadsPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<CameraBloc>().add(const InitializeCameraEvent());
    context.read<SyncBloc>()
      ..add(const LoadPendingUploadsEvent())
      ..add(const StartConnectivityMonitorEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    context.read<CameraBloc>().add(const DisposeCameraEvent());
    super.dispose();
  }

  /// Re-initialize when app comes back to foreground; dispose when going away.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CameraBloc>().add(const InitializeCameraEvent());
    } else if (state == AppLifecycleState.inactive) {
      context.read<CameraBloc>().add(const DisposeCameraEvent());
    }
  }

  void _handleTapToFocus(
      TapDownDetails details, BoxConstraints constraints) {
    // Normalize tap position to 0.0–1.0 range for camera API
    final normalizedX =
        (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final normalizedY =
        (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);

    context.read<CameraBloc>().add(
          SetFocusPointEvent(Offset(normalizedX, normalizedY)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            BlocConsumer<CameraBloc, CameraState>(
              listener: (context, state) {
                if (state is CameraReady) {
                  _currentDisplayZoom = state.configuration.currentZoom;
                  // Refresh queue count in top bar whenever camera is ready
                  context
                      .read<SyncBloc>()
                      .add(const LoadPendingUploadsEvent());
                }
              },
              builder: (context, state) {
                if (state is CameraLoading || state is CameraInitial) {
                  return const _CameraLoadingView();
                }

                if (state is CameraError) {
                  return _CameraErrorView(
                    message: state.message,
                    onRetry: () => context
                        .read<CameraBloc>()
                        .add(const InitializeCameraEvent()),
                  );
                }

                // Both CameraReady and CameraCapturing expose controller + config
                final controller = state is CameraReady
                    ? state.controller
                    : (state as CameraCapturing).controller;
                final config = state is CameraReady
                    ? state.configuration
                    : (state as CameraCapturing).configuration;
                final focusPoint =
                    state is CameraReady ? state.focusPoint : null;
                final showFocusIndicator =
                    state is CameraReady ? state.showFocusIndicator : false;
                final isCurrentlyCapturing = state is CameraCapturing;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Camera preview with gesture support ───────
                        GestureDetector(
                          onTapDown: (details) =>
                              _handleTapToFocus(details, constraints),
                          onScaleStart: (details) {
                            // Record zoom level at pinch start so scale is relative
                            _zoomAtPinchStart = config.currentZoom;
                          },
                          onScaleUpdate: (details) {
                            if (details.pointerCount < 2) return;
                            final newZoom =
                                (_zoomAtPinchStart * details.scale)
                                    .clamp(config.minZoom, config.maxZoom);
                            // Only dispatch if the change is meaningful (> 1%)
                            if ((newZoom - _currentDisplayZoom).abs() >
                                0.01) {
                              _currentDisplayZoom = newZoom;
                              context
                                  .read<CameraBloc>()
                                  .add(SetZoomLevelEvent(newZoom));
                            }
                          },
                          child: ClipRect(
                            child: OverflowBox(
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  height: constraints.maxWidth *
                                      controller.value.aspectRatio,
                                  child: CameraPreview(controller),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Tap-to-focus indicator ────────────────────
                        if (showFocusIndicator && focusPoint != null)
                          FocusIndicatorWidget(
                            position: Offset(
                              focusPoint.dx * constraints.maxWidth,
                              focusPoint.dy * constraints.maxHeight,
                            ),
                          ),

                        // ── Top status bar ────────────────────────────
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _TopStatusBar(
                            onTogglePendingPanel: () => setState(() {
                              _showPendingUploadsPanel =
                                  !_showPendingUploadsPanel;
                            }),
                            isPendingPanelOpen: _showPendingUploadsPanel,
                          ),
                        ),

                        // ── Bottom camera controls ────────────────────
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CameraControlsOverlay(
                            minZoom: config.minZoom,
                            maxZoom: config.maxZoom,
                            currentZoom: config.currentZoom,
                            zoomPresets: config.availableZoomPresets,
                            isCapturing: isCurrentlyCapturing,
                            onCapture: () => context
                                .read<CameraBloc>()
                                .add(const CaptureImageEvent()),
                            onZoomChanged: (zoom) => context
                                .read<CameraBloc>()
                                .add(SetZoomLevelEvent(zoom)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // ── Pending uploads slide-up panel ────────────────────────
            if (_showPendingUploadsPanel)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _PendingUploadsPanel(
                  onClose: () => setState(
                      () => _showPendingUploadsPanel = false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Loading view ───────────────────────────────────────────────────────────
class _CameraLoadingView extends StatelessWidget {
  const _CameraLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text('Initialising camera…',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

// ── Error view ─────────────────────────────────────────────────────────────
class _CameraErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CameraErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top status bar ─────────────────────────────────────────────────────────
class _TopStatusBar extends StatelessWidget {
  final VoidCallback onTogglePendingPanel;
  final bool isPendingPanelOpen;

  const _TopStatusBar({
    required this.onTogglePendingPanel,
    required this.isPendingPanelOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              final isUploading = syncState is SyncUploading;
              final isOnline = syncState is SyncIdle
                  ? syncState.isConnected
                  : true;
              final queueCount = syncState is SyncIdle
                  ? syncState.pendingCount + syncState.failedCount
                  : 0;

              return GestureDetector(
                onTap: onTogglePendingPanel,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Connectivity dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isUploading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white),
                        )
                      else
                        Icon(
                          queueCount > 0
                              ? Icons.cloud_upload_outlined
                              : Icons.cloud_done_outlined,
                          color: queueCount > 0
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                          size: 16,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        _buildStatusLabel(
                            isUploading, isOnline, queueCount),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        isPendingPanelOpen
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _buildStatusLabel(
      bool isUploading, bool isOnline, int queueCount) {
    if (isUploading) return 'Syncing…';
    if (!isOnline) {
      return queueCount > 0
          ? 'Offline · $queueCount queued'
          : 'Offline';
    }
    return queueCount > 0 ? '$queueCount pending' : 'Synced';
  }
}

// ── Pending uploads slide-up panel ─────────────────────────────────────────
class _PendingUploadsPanel extends StatelessWidget {
  final VoidCallback onClose;

  const _PendingUploadsPanel({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: BlocBuilder<SyncBloc, SyncState>(
                builder: (context, syncState) {
                  final batches = syncState is SyncIdle
                      ? syncState.pendingBatches
                      : <ImageBatch>[];
                  final isOnline =
                      syncState is SyncIdle ? syncState.isConnected : false;
                  final isUploading = syncState is SyncUploading;

                  return PendingUploadsList(
                    batches: batches,
                    isConnected: isOnline,
                    isUploading: isUploading,
                    onRetryTapped: () => context
                        .read<SyncBloc>()
                        .add(const TriggerUploadEvent()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
