import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// خلفية متدرّجة عيدية مع زخارف خفيفة (هلال + نجوم).
/// Placeholder بصري لـ M1 — سنبدّلها بـ SVG حقيقي في M7.
class EidBackground extends StatelessWidget {
  const EidBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const _GradientLayer(),
        const Positioned(top: 60, left: 24, child: _Crescent()),
        const Positioned(top: 140, right: 40, child: _Star()),
        const Positioned(top: 200, right: 110, child: _Star(size: 10)),
        const Positioned(top: 90, right: 80, child: _Star(size: 14)),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GradientLayer extends StatelessWidget {
  const _GradientLayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            EidColors.darkGreen,
            EidColors.green,
            EidColors.cream,
          ],
          stops: <double>[0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _Crescent extends StatelessWidget {
  const _Crescent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 64,
      child: CustomPaint(painter: _CrescentPainter()),
    );
  }
}

class _CrescentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint outer = Paint()..color = EidColors.gold.withValues(alpha: 0.92);
    final Paint inner = Paint()..color = EidColors.darkGreen;

    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, size.width / 2, outer);
    canvas.drawCircle(
      Offset(center.dx + size.width * 0.18, center.dy - size.height * 0.05),
      size.width / 2.05,
      inner,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Star extends StatelessWidget {
  const _Star({this.size = 12});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.star,
      size: size,
      color: EidColors.gold.withValues(alpha: 0.85),
    );
  }
}
