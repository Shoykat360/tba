import 'package:flutter/material.dart';

/// Animated yellow square that appears at the user's tap point to show
/// where the camera will focus.
class FocusIndicatorWidget extends StatefulWidget {
  final Offset position;

  const FocusIndicatorWidget({super.key, required this.position});

  @override
  State<FocusIndicatorWidget> createState() => _FocusIndicatorWidgetState();
}

class _FocusIndicatorWidgetState extends State<FocusIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = Tween<double>(begin: 1.6, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOut),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
          parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 30,
      top: widget.position.dy - 30,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (_, __) => Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.yellowAccent, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.yellowAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
