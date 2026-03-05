import 'package:flutter/material.dart';
import 'showcase_theme.dart';

/// A full-width feature tile used in the navigation section.
/// The icon container carries a [Hero] tag so it flies to the destination
/// screen's AppBar when the route is pushed.
///
/// Animates a left-side accent bar and background wash on selection/hover.
class FeatureNavigationTile extends StatefulWidget {
  final String heroTag;
  final String title;
  final String description;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final Color accentColorSoft;
  final VoidCallback onTap;
  final Duration entranceDelay;

  const FeatureNavigationTile({
    super.key,
    required this.heroTag,
    required this.title,
    required this.description,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.accentColorSoft,
    required this.onTap,
    required this.entranceDelay,
  });

  @override
  State<FeatureNavigationTile> createState() => _FeatureNavigationTileState();
}

class _FeatureNavigationTileState extends State<FeatureNavigationTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _slideAnim;
  late final Animation<double> _fadeAnim;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: ShowcaseTheme.durationSlow,
    );

    _slideAnim = Tween<double>(begin: -24.0, end: 0.0).animate(
      CurvedAnimation(parent: _entranceController, curve: ShowcaseTheme.curveOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: ShowcaseTheme.curveOut),
    );

    Future.delayed(widget.entranceDelay, () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) => Opacity(
        opacity: _fadeAnim.value,
        child: Transform.translate(
          offset: Offset(_slideAnim.value, 0),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: ShowcaseTheme.durationFast,
          curve: ShowcaseTheme.curveOut,
          margin: const EdgeInsets.only(bottom: ShowcaseTheme.spaceSm),
          decoration: BoxDecoration(
            color: _isHovered
                ? ShowcaseTheme.surfaceRaised
                : ShowcaseTheme.surface,
            borderRadius: BorderRadius.circular(ShowcaseTheme.radiusMd),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withOpacity(0.4)
                  : ShowcaseTheme.surfaceBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ShowcaseTheme.radiusMd),
            child: Row(
              children: [
                // Animated left-side accent bar.
                AnimatedContainer(
                  duration: ShowcaseTheme.durationNormal,
                  width: _isHovered ? 4.0 : 2.0,
                  height: 80.0,
                  color: _isHovered
                      ? widget.accentColor
                      : widget.accentColor.withOpacity(0.3),
                ),
                const SizedBox(width: ShowcaseTheme.spaceMd),

                // Hero-tagged icon.
                Hero(
                  tag: widget.heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedContainer(
                      duration: ShowcaseTheme.durationNormal,
                      width: 48.0,
                      height: 48.0,
                      decoration: BoxDecoration(
                        color: _isHovered
                            ? widget.accentColor.withOpacity(0.25)
                            : widget.accentColorSoft,
                        borderRadius:
                            BorderRadius.circular(ShowcaseTheme.radiusSm),
                      ),
                      child: Icon(widget.icon,
                          color: widget.accentColor, size: 22.0),
                    ),
                  ),
                ),
                const SizedBox(width: ShowcaseTheme.spaceMd),

                // Title and description.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ShowcaseTheme.spaceMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: ShowcaseTheme.textPrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3.0),
                        Text(
                          widget.description,
                          style:
                              ShowcaseTheme.bodyStyle(size: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: ShowcaseTheme.spaceSm),

                // Badge chip.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ShowcaseTheme.spaceSm,
                    vertical: 3.0,
                  ),
                  decoration: BoxDecoration(
                    color: widget.accentColorSoft,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    widget.badge,
                    style: ShowcaseTheme.labelStyle(
                      size: 10.0,
                      color: widget.accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: ShowcaseTheme.spaceMd),

                Icon(
                  Icons.chevron_right,
                  color: _isHovered
                      ? widget.accentColor
                      : ShowcaseTheme.textMuted,
                  size: 20.0,
                ),
                const SizedBox(width: ShowcaseTheme.spaceMd),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
