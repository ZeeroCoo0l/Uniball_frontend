import 'package:flutter/material.dart';

class FootballFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Stripe colors
    final lightGreen = const Color(0xFF388E3C);
    final darkGreen = const Color(0xFF2E7D32);

    // Number of horizontal stripes
    int stripeCount = 10;
    double stripeHeight = size.height / stripeCount;

    // Draw alternating stripes
    for (int i = 0; i < stripeCount; i++) {
      final paint =
          Paint()
            ..color = i.isEven ? lightGreen : darkGreen
            ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeHeight, size.width, stripeHeight),
        paint,
      );
    }

    // White lines
    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke;

    // Outer boundary
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), linePaint);

    // Midfield line (horizontal)
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.1,
      linePaint,
    );

    // Center spot
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 5, dotPaint);

    // Goalkeeper boxes (penalty areas)
    final boxWidth = size.width * 0.35;
    final boxHeight = size.height * 0.1;

    // Top box
    canvas.drawRect(
      Rect.fromLTWH((size.width - boxWidth) / 2, 0, boxWidth, boxHeight),
      linePaint,
    );

    // Bottom box
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - boxWidth) / 2,
        size.height - boxHeight,
        boxWidth,
        boxHeight,
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
