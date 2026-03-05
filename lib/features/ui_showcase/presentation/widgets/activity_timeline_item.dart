import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// A single item in the activity timeline.
/// Animates in with a dot-expand + fade, drawing the connecting line
/// from top to bottom so the timeline feels like it's being written live.
class ActivityTimelineItem extends StatefulWidget {
  final String timestamp;
  final String action;
  final String detail;
  final IconData icon;
  final Color dotColor;
  final bool isLast;
  final Duration entranceDelay;

  const ActivityTimelineItem({
    super.key,
    required this.timestamp,
    required this.action,
    required this.detail,
    required this.icon,
    required this.dotColor,
    required this.entranceDelay,
    this.isLast = false,
  });

  @override
  State<ActivityTimelineItem> createState() => _ActivityTimelineItemState();
}

class _ActivityTimelineItemState extends State<ActivityTimelineItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _dotScaleAnim;
  late final Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: ShowcaseTheme.durationSlow,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );

    _dotScaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _lineAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(widget.entranceDelay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column: dot + connecting line.
            SizedBox(
              width: 32.0,
              child: Column(
                children: [
                  Transform.scale(
                    scale: _dotScaleAnim.value,
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: BoxDecoration(
                        color: widget.dotColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.dotColor.withOpacity(0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(widget.icon,
                          color: widget.dotColor, size: 13.0),
                    ),
                  ),
                  if (!widget.isLast)
                    Opacity(
                      opacity: _lineAnim.value,
                      child: Container(
                        width: 1.5,
                        height: 36.0,
                        margin:
                            const EdgeInsets.symmetric(vertical: 3.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              widget.dotColor.withOpacity(0.4),
                              ShowcaseTheme.surfaceBorder,
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: ShowcaseTheme.spaceSm),

            // Right column: content.
            Expanded(
              child: Opacity(
                opacity: _fadeAnim.value,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: widget.isLast ? 0 : ShowcaseTheme.spaceSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.action,
                              style: TextStyle(
                                color: ShowcaseTheme.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: ShowcaseTheme.spaceXs),
                          Text(
                            widget.timestamp,
                            style: ShowcaseTheme.labelStyle(
                              size: 10.0,
                              color: ShowcaseTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        widget.detail,
                        style: ShowcaseTheme.bodyStyle(size: 12.0),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
