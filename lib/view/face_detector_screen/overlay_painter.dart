import 'package:flutter/material.dart';

class OverlayPainter extends CustomPainter {
  final double screenWidth;
  final double screenHeight;

  OverlayPainter({required this.screenWidth, required this.screenHeight});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 2.0;

    final ovalPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(screenWidth / 2, screenHeight / 2.1),
        width: screenWidth * 0.8,  // width
        height: screenHeight * 0.5,
      ));

    final outerPath = Path()..addRect(Rect.fromLTWH(0, 0, screenWidth, screenHeight));
    final overlayPath = Path.combine(PathOperation.difference, outerPath, ovalPath);

    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, paint);

    //  It will create outer circle
    final ovalStrokePath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(screenWidth / 2, screenHeight / 2.1),
        width: screenWidth * 0.8,  // width
        height: screenHeight * 0.5,
      ));

    //Create dashed effect
    final dashArray = [10.0, 5.0]; // Define dash length and space
    paint.shader = null;
    final dashPath = _createDashedPath(ovalStrokePath, dashArray);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawPath(dashPath, borderPaint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

  Path _createDashedPath(Path path, List<double> dashArray) {
    final dashedPath = Path();
    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final segment = metric.extractPath(
          distance,
          distance + dashArray[0],
        );
        dashedPath.addPath(segment, Offset.zero);
        distance += dashArray[0] + dashArray[1];
      }
      distance = 0.0; // Reset for next metric
    }
    return dashedPath;
  }

}