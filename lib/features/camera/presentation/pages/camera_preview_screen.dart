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
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen>
    with WidgetsBindingObserver {
  // Pinch-to-zoom tracking
  double _baseZoom = 1.0;
  double _currentZoom = 1.0;
  bool _showPendingPanel = false;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<CameraBloc>().add(const InitializeCameraEvent());
    } else if (state == AppLifecycleState.inactive) {
      context.read<CameraBloc>().add(const DisposeCameraEvent());
    }
  }

  void _handleTapToFocus(TapDownDetails details, BoxConstraints constraints) {
    final normalizedX =
    (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0);
    final normalizedY =
    (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0);

    context
        .read<CameraBloc>()
        .add(SetFocusPointEvent(Offset(normalizedX, normalizedY)));
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
                  _currentZoom = state.configuration.currentZoom;
                  context
                      .read<SyncBloc>()
                      .add(const LoadPendingUploadsEvent());
                }
              },
              builder: (context, state) {
                if (state is CameraLoading || state is CameraInitial) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text('Initializing camera…',
                            style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  );
                }

                if (state is CameraError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt_outlined,
                              color: Colors.red, size: 64),
                          const SizedBox(height: 16),
                          Text(state.message,
                              textAlign: TextAlign.center,
                              style:
                              const TextStyle(color: Colors.white70)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context
                                .read<CameraBloc>()
                                .add(const InitializeCameraEvent()),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final controller = state is CameraReady
                    ? state.controller
                    : (state as CameraCapturing).controller;
                final config = state is CameraReady
                    ? state.configuration
                    : (state as CameraCapturing).configuration;
                final focusPoint =
                state is CameraReady ? state.focusPoint : null;
                final showFocus =
                state is CameraReady ? state.showFocusIndicator : false;
                final isCapturing = state is CameraCapturing;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Camera preview with gestures ──────────────
                        GestureDetector(
                          onTapDown: (details) =>
                              _handleTapToFocus(details, constraints),
                          // Pinch-to-zoom: track base zoom on scale start
                          onScaleStart: (details) {
                            _baseZoom = config.currentZoom;
                          },
                          // Pinch-to-zoom: calculate new zoom smoothly
                          onScaleUpdate: (details) {
                            if (details.pointerCount < 2) return;
                            final newZoom = (_baseZoom * details.scale)
                                .clamp(config.minZoom, config.maxZoom);
                            // Only dispatch if zoom changed meaningfully
                            if ((newZoom - _currentZoom).abs() > 0.01) {
                              _currentZoom = newZoom;
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

                        // ── Focus indicator ───────────────────────────
                        if (showFocus && focusPoint != null)
                          FocusIndicatorWidget(
                            position: Offset(
                              focusPoint.dx * constraints.maxWidth,
                              focusPoint.dy * constraints.maxHeight,
                            ),
                          ),

                        // ── Top bar ───────────────────────────────────
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _TopBar(
                            onTogglePanel: () => setState(
                                    () => _showPendingPanel = !_showPendingPanel),
                            showPendingPanel: _showPendingPanel,
                          ),
                        ),

                        // ── Bottom controls ───────────────────────────
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: CameraControlsOverlay(
                            minZoom: config.minZoom,
                            maxZoom: config.maxZoom,
                            currentZoom: config.currentZoom,
                            zoomPresets: config.availableZoomPresets,
                            isCapturing: isCapturing,
                            onCapture: () => context
                                .read<CameraBloc>()
                                .add(const CaptureImageEvent()),
                            onZoomChanged: (z) => context
                                .read<CameraBloc>()
                                .add(SetZoomLevelEvent(z)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // ── Pending uploads panel ─────────────────────────────────
            if (_showPendingPanel)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _PendingUploadsPanel(
                  onClose: () =>
                      setState(() => _showPendingPanel = false),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final VoidCallback onTogglePanel;
  final bool showPendingPanel;

  const _TopBar({
    required this.onTogglePanel,
    required this.showPendingPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon:
            const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, state) {
              final isUploading = state is SyncUploading;
              final isConnected =
              state is SyncIdle ? state.isConnected : true;
              int pendingCount = 0;
              if (state is SyncIdle) {
                pendingCount =
                    state.pendingCount + state.failedCount;
              }

              return GestureDetector(
                onTap: onTogglePanel,
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
                          color: isConnected
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
                          pendingCount > 0
                              ? Icons.cloud_upload_outlined
                              : Icons.cloud_done_outlined,
                          color: pendingCount > 0
                              ? Colors.orangeAccent
                              : Colors.greenAccent,
                          size: 16,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        isUploading
                            ? 'Syncing…'
                            : !isConnected
                            ? 'Offline${pendingCount > 0 ? ' · $pendingCount queued' : ''}'
                            : pendingCount > 0
                            ? '$pendingCount pending'
                            : 'Synced',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        showPendingPanel
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
}

// ── Pending uploads panel ─────────────────────────────────────────────────
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
                builder: (context, state) {
                  /*final batches =
                  state is SyncIdle ? state.pendingBatches : [];*/
                  // Change this line in _PendingUploadsPanel:
                  final batches = state is SyncIdle
                      ? state.pendingBatches
                      : <ImageBatch>[];  // ← typed empty list
                  final isConnected =
                  state is SyncIdle ? state.isConnected : false;
                  final isUploading = state is SyncUploading;

                  return PendingUploadsList(
                    batches: batches,
                    isConnected: isConnected,
                    isUploading: isUploading,
                    onRetry: () => context
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
