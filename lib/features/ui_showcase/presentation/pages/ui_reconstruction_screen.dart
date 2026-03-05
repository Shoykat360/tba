import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/activity_timeline_item.dart';
import '../widgets/animated_progress_ring.dart';
import '../widgets/animated_stat_card.dart';
import '../widgets/animated_toggle_chip.dart';
import '../widgets/feature_navigation_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/showcase_theme.dart';

// =============================================================================
// UIReconstructionScreen
// =============================================================================
//
// Design direction: Dark-industrial precision dashboard.
// Amber accent on near-black surfaces. Monospace value readouts.
// Asymmetric two-column layout on wide screens. Every widget earns its place.
//
// Required methods:
//   buildResponsiveLayout()         — LayoutBuilder + MediaQuery breakpoints
//   handleAnimatedStateTransition() — AnimatedSwitcher + AnimatedContainer
//
// Component tree (pure UI, zero business logic):
//
//   UIReconstructionScreen
//     ├── _BackgroundNoise              (CustomPainter scanlines + ambient glows)
//     ├── _TopBar                       (system label + version tag)
//     ├── AnimatedSwitcher              (loading ↔ ready ↔ error)
//     │    └── LayoutBuilder → buildResponsiveLayout()
//     │         ├── compact  (< 600dp)  _CompactBody  single-column scroll
//     │         └── expanded (≥ 600dp)  _WideBody     two-column scroll pair
//     └── AnimatedContainer             (amber flash overlay on navigation)
//
// =============================================================================

// ---------------------------------------------------------------------------
// UIScreenState — drives handleAnimatedStateTransition
// ---------------------------------------------------------------------------
enum UIScreenState { loading, ready, navigating, error }

// ---------------------------------------------------------------------------
// UIReconstructionScreen
// ---------------------------------------------------------------------------
class UIReconstructionScreen extends StatefulWidget {
  final VoidCallback? onAttendanceTapped;
  final VoidCallback? onCameraTapped;

  const UIReconstructionScreen({
    super.key,
    this.onAttendanceTapped,
    this.onCameraTapped,
  });

  @override
  State<UIReconstructionScreen> createState() => _UIReconstructionScreenState();
}

class _UIReconstructionScreenState extends State<UIReconstructionScreen>
    with TickerProviderStateMixin {

  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _masterEntryController;
  late final AnimationController _flashController;
  late final AnimationController _clockPulseController;

  // Staggered slices of _masterEntryController
  late final Animation<double> _topBarFade;
  late final Animation<double> _colLeftFade;
  late final Animation<Offset> _colLeftSlide;
  late final Animation<double> _colRightFade;
  late final Animation<Offset> _colRightSlide;

  // ── UI state ───────────────────────────────────────────────────────────────
  UIScreenState _screenState = UIScreenState.loading;
  int _selectedTab = 0;

  // ── Static display data — pure UI, zero domain coupling ───────────────────

  static const List<String> _tabs = ['Week', 'Month', 'All'];

  static const List<_StatData> _statCards = [
    _StatData(
      label:           'CHECK-INS',
      value:           '12',
      subValue:        '+3 vs last week',
      icon:            Icons.fingerprint,
      accentColor:     ShowcaseTheme.accent,
      accentColorSoft: ShowcaseTheme.accentSoft,
      entranceDelay:   Duration(milliseconds: 120),
    ),
    _StatData(
      label:           'DAY STREAK',
      value:           '5',
      subValue:        'Personal best',
      icon:            Icons.local_fire_department_rounded,
      accentColor:     ShowcaseTheme.success,
      accentColorSoft: ShowcaseTheme.successSoft,
      entranceDelay:   Duration(milliseconds: 200),
    ),
    _StatData(
      label:           'IMG QUEUED',
      value:           '3',
      subValue:        'Pending upload',
      icon:            Icons.cloud_upload_outlined,
      accentColor:     ShowcaseTheme.info,
      accentColorSoft: ShowcaseTheme.infoSoft,
      entranceDelay:   Duration(milliseconds: 280),
    ),
    _StatData(
      label:           'IMG SYNCED',
      value:           '47',
      subValue:        'Lifetime total',
      icon:            Icons.check_circle_outline_rounded,
      accentColor:     ShowcaseTheme.success,
      accentColorSoft: ShowcaseTheme.successSoft,
      entranceDelay:   Duration(milliseconds: 360),
    ),
  ];

  static const List<_RingData> _rings = [
    _RingData(label: 'GPS',   centerLabel: '98%', progress: 0.98,
              color: ShowcaseTheme.success,
              delay: Duration(milliseconds: 600)),
    _RingData(label: 'SYNC',  centerLabel: '94%', progress: 0.94,
              color: ShowcaseTheme.accent,
              delay: Duration(milliseconds: 750)),
    _RingData(label: 'QUEUE', centerLabel: '63%', progress: 0.63,
              color: ShowcaseTheme.info,
              delay: Duration(milliseconds: 900)),
  ];

  static const List<_TimelineData> _timeline = [
    _TimelineData(
      timestamp: '09:14',
      action:    'Attendance marked',
      detail:    'Within 18m of office geofence',
      icon:      Icons.location_on_rounded,
      color:     ShowcaseTheme.success,
      delay:     Duration(milliseconds: 500),
    ),
    _TimelineData(
      timestamp: '09:12',
      action:    'GPS lock acquired',
      detail:    'Accuracy ±4m — excellent signal',
      icon:      Icons.gps_fixed,
      color:     ShowcaseTheme.accent,
      delay:     Duration(milliseconds: 620),
    ),
    _TimelineData(
      timestamp: '08:53',
      action:    '3 images uploaded',
      detail:    'Batch #14 synced via Wi-Fi',
      icon:      Icons.cloud_done_rounded,
      color:     ShowcaseTheme.info,
      delay:     Duration(milliseconds: 740),
    ),
    _TimelineData(
      timestamp: '08:41',
      action:    'App resumed',
      detail:    'WorkManager flushed 1 task',
      icon:      Icons.power_settings_new_rounded,
      color:     ShowcaseTheme.textSecondary,
      delay:     Duration(milliseconds: 860),
      isLast:    true,
    ),
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initControllers();
    _initAnimations();
    _beginEntrySequence();
  }

  @override
  void dispose() {
    _masterEntryController.dispose();
    _flashController.dispose();
    _clockPulseController.dispose();
    super.dispose();
  }

  void _initControllers() {
    _masterEntryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _clockPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  void _initAnimations() {
    // Top bar fades in first (0–35 % of master)
    _topBarFade = CurvedAnimation(
      parent: _masterEntryController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    // Left column slides in from the left (20–65 %)
    _colLeftFade = CurvedAnimation(
      parent: _masterEntryController,
      curve: const Interval(0.20, 0.65, curve: Curves.easeOut),
    );
    _colLeftSlide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterEntryController,
      curve: const Interval(0.20, 0.65, curve: Curves.easeOutCubic),
    ));

    // Right column slides in from the right, slightly later (35–85 %)
    _colRightFade = CurvedAnimation(
      parent: _masterEntryController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _colRightSlide = Tween<Offset>(
      begin: const Offset(0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _masterEntryController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    ));
  }

  Future<void> _beginEntrySequence() async {
    // Hold on loading state briefly so AnimatedSwitcher has something to fade from.
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _screenState = UIScreenState.ready);
    _masterEntryController.forward();
  }

  // ── handleAnimatedStateTransition ─────────────────────────────────────────
  //
  // Controls the full transition lifecycle when screen state changes.
  //
  // Steps:
  //   1. setState(next)          — AnimatedSwitcher cross-fades content
  //   2. _flashController fwd    — AnimatedContainer amber overlay blooms
  //   3. action?.call()          — navigation or other side-effect fires
  //   4. _flashController rev    — overlay dissolves
  //   5. setState(ready)         — screen returns to resting state
  //
  Future<void> handleAnimatedStateTransition(
    UIScreenState next, {
    VoidCallback? action,
  }) async {
    if (!mounted) return;
    HapticFeedback.lightImpact();

    setState(() => _screenState = next);

    if (next == UIScreenState.navigating) {
      await _flashController.forward();
      action?.call();
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 80));
        await _flashController.reverse();
        if (mounted) setState(() => _screenState = UIScreenState.ready);
      }
    } else {
      action?.call();
    }
  }

  // ── Intent dispatchers — pure navigation, no logic ─────────────────────────

  void _onAttendanceTapped() => handleAnimatedStateTransition(
        UIScreenState.navigating,
        action: widget.onAttendanceTapped,
      );

  void _onCameraTapped() => handleAnimatedStateTransition(
        UIScreenState.navigating,
        action: widget.onCameraTapped,
      );

  // ── buildResponsiveLayout ──────────────────────────────────────────────────
  //
  // LayoutBuilder supplies tight constraints from the Scaffold body.
  // MediaQuery provides safe-area insets, orientation, and text scale.
  //
  // Breakpoints:
  //   < 600dp   compact   single-column CustomScrollView, stacked sections
  //   ≥ 600dp   expanded  two CustomScrollViews in a Row, each independently
  //                       scrollable — left metrics, right navigation+activity
  //
  // Overflow guards:
  //   • hPad derived as a percentage of width, clamped to [14, 24]
  //   • textScale clamped to [0.8, 1.25] — large-text accessibility safe
  //   • All Text nodes carry maxLines + overflow:ellipsis (in sub-widgets)
  //   • No fixed heights on any Row children — all Expanded or sized by content
  //
  Widget buildResponsiveLayout(BuildContext context, BoxConstraints constraints) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double w          = constraints.maxWidth;
    final double topSafe    = mq.padding.top;
    final double bottomSafe = mq.padding.bottom;
    final double tScale     = mq.textScaler.scale(1.0).clamp(0.80, 1.25);
    final double hPad       = (w * 0.045).clamp(14.0, 24.0);

    if (w >= 600) {
      return _buildWideBody(
        context:    context,
        hPad:       hPad,
        topSafe:    topSafe,
        bottomSafe: bottomSafe,
        tScale:     tScale,
        totalWidth: w,
      );
    }

    return _buildCompactBody(
      context:    context,
      hPad:       hPad,
      topSafe:    topSafe,
      bottomSafe: bottomSafe,
    );
  }

  // ── Compact layout (< 600dp) ───────────────────────────────────────────────

  Widget _buildCompactBody({
    required BuildContext context,
    required double hPad,
    required double topSafe,
    required double bottomSafe,
  }) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Safe-area + top-bar clearance
        SliverToBoxAdapter(child: SizedBox(height: topSafe + 56.0)),

        // ── Metrics grid ────────────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _colLeftFade,
              child: SlideTransition(
                position: _colLeftSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(label: 'System metrics'),
                    const SizedBox(height: ShowcaseTheme.spaceMd),
                    _buildStatsGrid(crossAxisCount: 2),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: ShowcaseTheme.spaceLg)),

        // ── Navigation tiles ─────────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _colRightFade,
              child: SlideTransition(
                position: _colRightSlide,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(label: 'Features'),
                    const SizedBox(height: ShowcaseTheme.spaceMd),
                    _buildNavTiles(),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: ShowcaseTheme.spaceLg)),

        // ── Service health rings ──────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _colLeftFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(
                    label:       'Service health',
                    accentColor: ShowcaseTheme.success,
                  ),
                  const SizedBox(height: ShowcaseTheme.spaceMd),
                  _buildRingsRow(),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: ShowcaseTheme.spaceLg)),

        // ── Activity timeline ─────────────────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          sliver: SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _colRightFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    label:       'Activity',
                    accentColor: ShowcaseTheme.info,
                    trailing: AnimatedToggleChipGroup(
                      labels:             _tabs,
                      selectedIndex:      _selectedTab,
                      accentColor:        ShowcaseTheme.info,
                      onSelectionChanged: (i) => setState(() => _selectedTab = i),
                    ),
                  ),
                  const SizedBox(height: ShowcaseTheme.spaceMd),
                  _buildTimeline(),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(child: SizedBox(height: bottomSafe + 32.0)),
      ],
    );
  }

  // ── Wide layout (≥ 600dp) ─────────────────────────────────────────────────

  Widget _buildWideBody({
    required BuildContext context,
    required double hPad,
    required double topSafe,
    required double bottomSafe,
    required double tScale,
    required double totalWidth,
  }) {
    // Gap between columns scales proportionally but stays usable
    final double colGap = (totalWidth * 0.025).clamp(12.0, 20.0);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left column — metrics + health ─────────────────────────────────
          Expanded(
            flex: 5,
            child: FadeTransition(
              opacity: _colLeftFade,
              child: SlideTransition(
                position: _colLeftSlide,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: topSafe + 56.0)),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(label: 'System metrics'),
                          const SizedBox(height: ShowcaseTheme.spaceMd),
                          _buildStatsGrid(crossAxisCount: 2),
                          const SizedBox(height: ShowcaseTheme.spaceLg),
                          const SectionHeader(
                            label:       'Service health',
                            accentColor: ShowcaseTheme.success,
                          ),
                          const SizedBox(height: ShowcaseTheme.spaceMd),
                          _buildRingsRow(),
                          SizedBox(height: bottomSafe + 32.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: colGap),

          // ── Right column — live clock + navigation + activity ───────────────
          Expanded(
            flex: 6,
            child: FadeTransition(
              opacity: _colRightFade,
              child: SlideTransition(
                position: _colRightSlide,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: topSafe + 56.0)),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLiveClockBanner(),
                          const SizedBox(height: ShowcaseTheme.spaceLg),
                          const SectionHeader(label: 'Features'),
                          const SizedBox(height: ShowcaseTheme.spaceMd),
                          _buildNavTiles(),
                          const SizedBox(height: ShowcaseTheme.spaceLg),
                          SectionHeader(
                            label:       'Activity',
                            accentColor: ShowcaseTheme.info,
                            trailing: AnimatedToggleChipGroup(
                              labels:             _tabs,
                              selectedIndex:      _selectedTab,
                              accentColor:        ShowcaseTheme.info,
                              onSelectionChanged: (i) =>
                                  setState(() => _selectedTab = i),
                            ),
                          ),
                          const SizedBox(height: ShowcaseTheme.spaceMd),
                          _buildTimeline(),
                          SizedBox(height: bottomSafe + 32.0),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildStatsGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap:  true,
      physics:     const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:   crossAxisCount,
        mainAxisSpacing:  ShowcaseTheme.spaceSm,
        crossAxisSpacing: ShowcaseTheme.spaceSm,
        // Aspect ratio keeps cards square-ish on all screen widths.
        // FittedBox inside AnimatedStatCard handles text overflow.
        childAspectRatio: 1.15,
      ),
      itemCount:   _statCards.length,
      itemBuilder: (_, i) {
        final d = _statCards[i];
        return AnimatedStatCard(
          label:           d.label,
          value:           d.value,
          subValue:        d.subValue,
          icon:            d.icon,
          accentColor:     d.accentColor,
          accentColorSoft: d.accentColorSoft,
          entranceDelay:   d.entranceDelay,
        );
      },
    );
  }

  Widget _buildNavTiles() {
    return Column(
      children: [
        FeatureNavigationTile(
          heroTag:         'hero_attendance_icon',
          title:           'Attendance',
          description:     'Geo-fenced GPS check-in — 50m radius',
          badge:           'GPS · HIVE',
          icon:            Icons.location_on_rounded,
          accentColor:     ShowcaseTheme.accent,
          accentColorSoft: ShowcaseTheme.accentSoft,
          onTap:           _onAttendanceTapped,
          entranceDelay:   const Duration(milliseconds: 300),
        ),
        FeatureNavigationTile(
          heroTag:         'hero_camera_icon',
          title:           'Camera',
          description:     'Offline-first capture · queue · sync',
          badge:           'WORKMANAGER',
          icon:            Icons.camera_alt_rounded,
          accentColor:     ShowcaseTheme.info,
          accentColorSoft: ShowcaseTheme.infoSoft,
          onTap:           _onCameraTapped,
          entranceDelay:   const Duration(milliseconds: 430),
        ),
      ],
    );
  }

  Widget _buildRingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _rings
          .map((r) => AnimatedProgressRing(
                progress:       r.progress,
                centerLabel:    r.centerLabel,
                subLabel:       r.label,
                ringColor:      r.color,
                size:           76.0,
                strokeWidth:    6.5,
                animationDelay: r.delay,
              ))
          .toList(),
    );
  }

  // AnimatedSwitcher here swaps the timeline content whenever the tab changes.
  // Key is _selectedTab so Flutter diffs correctly and cross-fades.
  Widget _buildTimeline() {
    return AnimatedSwitcher(
      duration:        ShowcaseTheme.durationNormal,
      switchInCurve:   Curves.easeOutCubic,
      switchOutCurve:  Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child:   SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end:   Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(
        key: ValueKey(_selectedTab),
        child: Column(
          children: _timeline
              .map((t) => ActivityTimelineItem(
                    timestamp:    t.timestamp,
                    action:       t.action,
                    detail:       t.detail,
                    icon:         t.icon,
                    dotColor:     t.color,
                    isLast:       t.isLast,
                    entranceDelay: t.delay,
                  ))
              .toList(),
        ),
      ),
    );
  }

  // Live clock updates every second via the repeating _clockPulseController.
  Widget _buildLiveClockBanner() {
    return AnimatedBuilder(
      animation: _clockPulseController,
      builder:   (context, _) {
        final now  = DateTime.now();
        final time =
            '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}';

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ShowcaseTheme.spaceMd,
            vertical:   ShowcaseTheme.spaceSm,
          ),
          decoration: ShowcaseTheme.accentCardDecoration(),
          child: Row(
            children: [
              // Pulsing dot — opacity driven by _clockPulseController
              Container(
                width:  8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ShowcaseTheme.accent.withOpacity(
                    0.5 + _clockPulseController.value * 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:      ShowcaseTheme.accent.withOpacity(
                        0.3 + _clockPulseController.value * 0.4,
                      ),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ShowcaseTheme.spaceSm),
              Text(
                'LIVE',
                style: ShowcaseTheme.labelStyle(
                  color:   ShowcaseTheme.accent,
                  size:    10.0,
                  spacing: 2.0,
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: ShowcaseTheme.valueStyle(
                  size:  20.0,
                  color: ShowcaseTheme.accent,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: ShowcaseTheme.background,
        body: Stack(
          children: [
            // Atmospheric scanline + ambient glow background
            const Positioned.fill(child: _BackgroundNoise()),

            // Top system bar fades in first
            FadeTransition(
              opacity:  _topBarFade,
              child:    const Align(
                alignment: Alignment.topCenter,
                child:     _TopBar(),
              ),
            ),

            // ── AnimatedSwitcher reacts to _screenState ────────────────────
            //
            // Each state gets a distinct ValueKey. When state changes,
            // Flutter fades + scales out the old child and fades + scales
            // in the new one. The ready/navigating states share 'ready'
            // key so they don't trigger a cross-fade between themselves.
            AnimatedSwitcher(
              duration:       ShowcaseTheme.durationSlow,
              switchInCurve:  Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child:   ScaleTransition(
                  scale: Tween<double>(begin: 0.97, end: 1.0).animate(anim),
                  child: child,
                ),
              ),
              child: _buildStateContent(),
            ),

            // ── AnimatedContainer — amber wash on navigation tap ───────────
            //
            // Morphs from transparent → accent tint when navigating,
            // then dissolves back to transparent. Purely declarative —
            // no gesture handling, IgnorePointer implicitly via color.
            AnimatedContainer(
              duration: ShowcaseTheme.durationFast,
              color:    _screenState == UIScreenState.navigating
                  ? ShowcaseTheme.accent.withOpacity(0.07)
                  : Colors.transparent,
            ),

            // Secondary flash: sine-wave opacity ripple from _flashController
            AnimatedBuilder(
              animation: _flashController,
              builder:   (_, __) {
                final double opacity =
                    math.sin(_flashController.value * math.pi) * 0.18;
                return IgnorePointer(
                  child: Container(
                    color: ShowcaseTheme.accent.withOpacity(opacity),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_screenState) {
      case UIScreenState.loading:
        return const _LoadingView(key: ValueKey('loading'));
      case UIScreenState.error:
        return const _ErrorView(key: ValueKey('error'));
      case UIScreenState.ready:
      case UIScreenState.navigating:
        // Same key for both: no cross-fade when navigating tap lands.
        // The amber overlay communicates the transition instead.
        return KeyedSubtree(
          key:   const ValueKey('ready'),
          child: LayoutBuilder(builder: buildResponsiveLayout),
        );
    }
  }
}

// =============================================================================
// Private widgets — file-scoped, no external dependencies
// =============================================================================

// ── Background ────────────────────────────────────────────────────────────────

class _BackgroundNoise extends StatelessWidget {
  const _BackgroundNoise();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NoisePainter(),
      size:    Size.infinite,
    );
  }
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Solid base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = ShowcaseTheme.background,
    );

    // Horizontal scan lines — every 2px, near-invisible
    final Paint scanLine = Paint()
      ..color       = Colors.white.withOpacity(0.012)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 2.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanLine);
    }

    // Amber radial glow — top-left
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.08),
      size.width * 0.55,
      Paint()
        ..shader = RadialGradient(colors: [
          ShowcaseTheme.accent.withOpacity(0.055),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.12, size.height * 0.08),
          radius: size.width * 0.55,
        )),
    );

    // Teal radial glow — bottom-right
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.72),
      size.width * 0.45,
      Paint()
        ..shader = RadialGradient(colors: [
          ShowcaseTheme.success.withOpacity(0.045),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
          center: Offset(size.width * 0.88, size.height * 0.72),
          radius: size.width * 0.45,
        )),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    return Container(
      height:  topPad + 50.0,
      padding: EdgeInsets.fromLTRB(20, topPad + 4, 20, 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
          colors: [ShowcaseTheme.background, ShowcaseTheme.background.withOpacity(0)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'SYS.OVERVIEW',
            style: ShowcaseTheme.labelStyle(
              size:    11.0,
              color:   ShowcaseTheme.textMuted,
              spacing: 2.2,
            ),
          ),
          const Spacer(),
          Text(
            'DASHBOARD',
            style: ShowcaseTheme.labelStyle(
              size:   12.0,
              color:  ShowcaseTheme.textSecondary,
              spacing: 2.8,
              weight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
            decoration: BoxDecoration(
              border:       Border.all(color: ShowcaseTheme.surfaceBorder),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Text(
              'v1.0.0',
              style: ShowcaseTheme.labelStyle(
                size:    9.5,
                color:   ShowcaseTheme.textMuted,
                spacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading & error views ─────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28.0, height: 28.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color:       ShowcaseTheme.accent,
            ),
          ),
          const SizedBox(height: ShowcaseTheme.spaceMd),
          Text(
            'INITIALISING',
            style: ShowcaseTheme.labelStyle(
              size:    11.0,
              color:   ShowcaseTheme.textMuted,
              spacing: 2.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: ShowcaseTheme.danger, size: 40.0),
          const SizedBox(height: ShowcaseTheme.spaceMd),
          Text(
            'SYSTEM ERROR',
            style: ShowcaseTheme.labelStyle(
              color:   ShowcaseTheme.danger,
              size:    12.0,
              spacing: 2.0,
            ),
          ),
          const SizedBox(height: ShowcaseTheme.spaceLg),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                border:       Border.all(color: ShowcaseTheme.danger.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(ShowcaseTheme.radiusSm),
              ),
              child: Text(
                'RETRY',
                style: ShowcaseTheme.labelStyle(
                  color: ShowcaseTheme.danger, spacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Immutable data carriers — pure value objects, no logic
// =============================================================================

class _StatData {
  final String  label, value;
  final String? subValue;
  final IconData icon;
  final Color   accentColor, accentColorSoft;
  final Duration entranceDelay;

  const _StatData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentColorSoft,
    required this.entranceDelay,
    this.subValue,
  });
}

class _RingData {
  final String label, centerLabel;
  final double progress;
  final Color  color;
  final Duration delay;

  const _RingData({
    required this.label,
    required this.centerLabel,
    required this.progress,
    required this.color,
    required this.delay,
  });
}

class _TimelineData {
  final String   timestamp, action, detail;
  final IconData icon;
  final Color    color;
  final Duration delay;
  final bool     isLast;

  const _TimelineData({
    required this.timestamp,
    required this.action,
    required this.detail,
    required this.icon,
    required this.color,
    required this.delay,
    this.isLast = false,
  });
}
