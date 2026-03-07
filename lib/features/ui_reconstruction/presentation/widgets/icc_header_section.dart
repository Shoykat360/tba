import 'package:flutter/material.dart';
import 'Ui_reconstruction_theme.dart';

class IccHeaderSection extends StatelessWidget {
  const IccHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient simulating the cricket banner
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B4B),
                  Color(0xFF1A237E),
                  Color(0xFF283593),
                  Color(0xFF1565C0),
                ],
              ),
            ),
          ),
          // Decorative cricket ball circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFE53935).withOpacity(0.9),
                    const Color(0xFFB71C1C).withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Seam lines on ball
          Positioned(
            right: 10,
            top: 10,
            child: CustomPaint(
              size: const Size(100, 100),
              painter: _CricketBallPainter(),
            ),
          ),
          // Silhouette placeholder
          Positioned(
            right: 60,
            bottom: 0,
            child: Opacity(
              opacity: 0.4,
              child: Container(
                width: 90,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
              ),
            ),
          ),
          // Top bar: back + search
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),
          ),
          // Title
          const Positioned(
            bottom: 16,
            left: 16,
            child: Text(
              "ICC T20 Men's",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CricketBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Seam curves
    final path1 = Path();
    path1.moveTo(size.width * 0.3, size.height * 0.1);
    path1.cubicTo(
      size.width * 0.1, size.height * 0.4,
      size.width * 0.1, size.height * 0.6,
      size.width * 0.3, size.height * 0.9,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.7, size.height * 0.1);
    path2.cubicTo(
      size.width * 0.9, size.height * 0.4,
      size.width * 0.9, size.height * 0.6,
      size.width * 0.7, size.height * 0.9,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
