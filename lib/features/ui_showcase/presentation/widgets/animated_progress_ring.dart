import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// Custom-painted circular progress ring with animated fill.
/// Used in the system-status section to show battery / signal / sync levels.
class AnimatedProgressRing extends StatefulWidget {
  final double progress;       // 0.0 – 1.0
  final String centerLabel;
  final String subLabel;
  final Color ringColor;
  final double size;
  final double strokeWidth;
  final Duration animationDelay;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    required this.centerLabel,
    required this.subLabel,
    required this.ringColor,
    this.size = 80.0,
    this.strokeWidth = 7.0,
    this.animationDelay = Duration.zero,
  });

  @override
  State<AnimatedProgressRing> createState() => _AnimatedProgressRingState();
}

class _AnimatedProgressRingState extends State<AnimatedProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ShowcaseTheme.durationXSlow,
    );

    _progressAnim = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(widget.animationDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(AnimatedProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _progressAnim,
          builder: (_, __) {
            return SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _progressAnim.value,
                  ringColor: widget.ringColor,
                  trackColor: ShowcaseTheme.surfaceBorder,
                  strokeWidth: widget.strokeWidth,
                ),
                child: Center(
                  child: Text(
                    widget.centerLabel,
                    style: ShowcaseTheme.valueStyle(
                      size: 16.0,
                      color: widget.ringColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: ShowcaseTheme.spaceXs),
        Text(widget.subLabel, style: ShowcaseTheme.labelStyle(size: 10.0)),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.progress,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = (size.shortestSide - strokeWidth) / 2;

    // Track ring.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // Progress arc.
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.ringColor != ringColor;
}
