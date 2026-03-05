import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// A metric card that animates its entrance with a staggered slide-and-fade,
/// pulses its status indicator, and smoothly transitions between value states.
///
/// Pure UI — receives only display data and an optional tap callback.
class AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final String? subValue;
  final IconData icon;
  final Color accentColor;
  final Color accentColorSoft;
  final Duration entranceDelay;
  final bool isActive;
  final VoidCallback? onTap;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.accentColorSoft,
    required this.entranceDelay,
    this.subValue,
    this.isActive = true,
    this.onTap,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _pulseAnim;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Entrance: slides up from 20px below, fades in.
    _entranceController = AnimationController(
      vsync: this,
      duration: ShowcaseTheme.durationSlow,
    );

    _slideAnim = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: ShowcaseTheme.curveOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: ShowcaseTheme.curveOut),
    );

    // Status dot pulse.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    Future.delayed(widget.entranceDelay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnim.value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: ShowcaseTheme.durationFast,
          curve: ShowcaseTheme.curveOut,
          padding: const EdgeInsets.all(ShowcaseTheme.spaceMd),
          decoration: BoxDecoration(
            color: _isPressed
                ? ShowcaseTheme.surfaceRaised
                : ShowcaseTheme.surface,
            borderRadius: BorderRadius.circular(ShowcaseTheme.radiusMd),
            border: Border.all(
              color: _isPressed
                  ? widget.accentColor.withOpacity(0.5)
                  : ShowcaseTheme.surfaceBorder,
              width: 1.0,
            ),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8.0,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: widget.accentColorSoft,
                      borderRadius:
                          BorderRadius.circular(ShowcaseTheme.radiusSm),
                    ),
                    child: Icon(widget.icon,
                        color: widget.accentColor, size: 18.0),
                  ),
                  const Spacer(),
                  // Pulsing status dot.
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (_, __) => Opacity(
                      opacity: widget.isActive ? _pulseAnim.value : 0.3,
                      child: Container(
                        width: 7.0,
                        height: 7.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isActive
                              ? widget.accentColor
                              : ShowcaseTheme.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ShowcaseTheme.spaceMd),
              AnimatedSwitcher(
                duration: ShowcaseTheme.durationNormal,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Text(
                  widget.value,
                  key: ValueKey(widget.value),
                  style: ShowcaseTheme.valueStyle(
                    size: 22.0,
                    color: widget.accentColor,
                  ),
                ),
              ),
              const SizedBox(height: ShowcaseTheme.spaceXs),
              Text(widget.label, style: ShowcaseTheme.labelStyle()),
              if (widget.subValue != null) ...[
                const SizedBox(height: ShowcaseTheme.spaceXs),
                Text(widget.subValue!,
                    style: ShowcaseTheme.bodyStyle(size: 12.0)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
