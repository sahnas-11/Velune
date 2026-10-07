import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

class VeluneMapCanvas extends StatelessWidget {
  final String pickupLabel;
  final String dropoffLabel;
  final String statusText;
  final bool showDriver;
  final double height;
  final double progress; // 0.0 to 1.0 along the route

  const VeluneMapCanvas({
    super.key,
    this.pickupLabel = 'Matara Clock Tower',
    this.dropoffLabel = 'World Trade Center, Colombo',
    this.statusText = 'Expressway Corridor (E01) • Smooth Traffic',
    this.showDriver = true,
    this.height = 190,
    this.progress = 0.45,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VeluneColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            CustomPaint(
              size: Size(double.infinity, height),
              painter: _MapPainter(progress: progress),
            ),
            // Top Status Chip
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 4),
                  ],
                ),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: VeluneColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        statusText,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: VeluneColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.navigation, size: 12, color: VeluneColors.accentBlue),
                  ],
                ),
              ),
            ),
            // Pickup / Dropoff Overlays
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: VeluneColors.deepNavy.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          pickupLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward, size: 10, color: Colors.white60),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 12, color: VeluneColors.danger),
                        const SizedBox(width: 4),
                        Text(
                          dropoffLabel,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final double progress;

  _MapPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE4E9F2);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw secondary road grid
    final gridPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.35), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.65), gridPaint);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.3, size.height), gridPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.7, size.height), gridPaint);

    // Draw main expressway route line
    final routePath = Path();
    final p0 = Offset(size.width * 0.15, size.height * 0.75);
    final p1 = Offset(size.width * 0.45, size.height * 0.60);
    final p2 = Offset(size.width * 0.60, size.height * 0.35);
    final p3 = Offset(size.width * 0.85, size.height * 0.30);

    routePath.moveTo(p0.dx, p0.dy);
    routePath.cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    final routeBgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routeBgPaint);

    final routePaint = Paint()
      ..color = VeluneColors.accentBlue
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(routePath, routePaint);

    // Start point
    final startPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(p0, 6, startPaint);
    canvas.drawCircle(p0, 3, Paint()..color = Colors.white);

    // End point
    final endPaint = Paint()..color = VeluneColors.danger;
    canvas.drawCircle(p3, 6, endPaint);
    canvas.drawCircle(p3, 3, Paint()..color = Colors.white);

    // Current car location along cubic curve approx
    final t = progress.clamp(0.0, 1.0);
    final cx = pow(1 - t, 3) * p0.dx + 3 * pow(1 - t, 2) * t * p1.dx + 3 * (1 - t) * pow(t, 2) * p2.dx + pow(t, 3) * p3.dx;
    final cy = pow(1 - t, 3) * p0.dy + 3 * pow(1 - t, 2) * t * p1.dy + 3 * (1 - t) * pow(t, 2) * p2.dy + pow(t, 3) * p3.dy;
    final carPos = Offset(cx, cy);

    // Radar pulse around car
    final radarPaint = Paint()
      ..color = VeluneColors.accentBlue.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(carPos, 16, radarPaint);

    // Car dot
    final carPaint = Paint()..color = VeluneColors.deepNavy;
    canvas.drawCircle(carPos, 7, carPaint);
    canvas.drawCircle(carPos, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
