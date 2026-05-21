import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/theme/app_colors.dart';

/// طبقة ألعاب نارية لشاشة العيد. تطلق فرقعات عشوائية تنفجر
/// إلى particles ملوّنة تسقط مع gravity.
class FireworksLayer extends StatefulWidget {
  const FireworksLayer({
    super.key,
    this.spawnIntervalMs = 650,
    this.maxConcurrent = 6,
  });

  final int spawnIntervalMs;
  final int maxConcurrent;

  @override
  State<FireworksLayer> createState() => _FireworksLayerState();
}

class _FireworksLayerState extends State<FireworksLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_onTick);
  final List<_Firework> _fireworks = <_Firework>[];
  final math.Random _rng = math.Random();
  Duration _lastSpawn = Duration.zero;
  Duration _lastTick = Duration.zero;

  static const List<Color> _palette = <Color>[
    EidColors.gold,
    Color(0xFFFFD54F),
    Color(0xFFFF7043),
    Color(0xFFEF5350),
    Color(0xFFE91E63),
    Color(0xFF7E57C2),
    Color(0xFF42A5F5),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFFFAF5E6),
  ];

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double dt = _lastTick == Duration.zero
        ? 0.016
        : ((elapsed - _lastTick).inMilliseconds / 1000).clamp(0.0, 0.05);
    _lastTick = elapsed;

    if ((elapsed - _lastSpawn).inMilliseconds >= widget.spawnIntervalMs &&
        _fireworks.length < widget.maxConcurrent) {
      _fireworks.add(_spawnFirework());
      _lastSpawn = elapsed;
    }

    for (final _Firework f in _fireworks) {
      f.update(dt);
    }
    _fireworks.removeWhere((_Firework f) => f.isDead);

    if (mounted) setState(() {});
  }

  _Firework _spawnFirework() {
    final Size size = context.size ?? const Size(360, 640);
    final double cx = _rng.nextDouble() * size.width * 0.8 + size.width * 0.1;
    final double cy =
        size.height * 0.15 + _rng.nextDouble() * size.height * 0.40;
    final Color base = _palette[_rng.nextInt(_palette.length)];
    final Color accent = _palette[_rng.nextInt(_palette.length)];
    final int particleCount = 32 + _rng.nextInt(24);
    return _Firework(
      origin: Offset(cx, cy),
      colorA: base,
      colorB: accent,
      particleCount: particleCount,
      rng: _rng,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _FireworksPainter(_fireworks),
        size: Size.infinite,
      ),
    );
  }
}

class _Firework {
  _Firework({
    required this.origin,
    required this.colorA,
    required this.colorB,
    required this.particleCount,
    required math.Random rng,
  }) {
    final double speed = 130 + rng.nextDouble() * 90;
    for (int i = 0; i < particleCount; i++) {
      final double angle =
          (i / particleCount) * math.pi * 2 + rng.nextDouble() * 0.2;
      final double v = speed * (0.7 + rng.nextDouble() * 0.5);
      particles.add(
        _Particle(
          position: origin,
          velocity: Offset(math.cos(angle) * v, math.sin(angle) * v),
          color: i.isEven ? colorA : colorB,
          life: 1.2 + rng.nextDouble() * 0.9,
        ),
      );
    }
  }

  final Offset origin;
  final Color colorA;
  final Color colorB;
  final int particleCount;
  final List<_Particle> particles = <_Particle>[];

  bool get isDead => particles.every((_Particle p) => p.age >= p.life);

  void update(double dt) {
    for (final _Particle p in particles) {
      p.update(dt);
    }
  }
}

class _Particle {
  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.life,
  });

  Offset position;
  Offset velocity;
  final Color color;
  final double life;
  double age = 0;

  static const double _gravity = 95;

  void update(double dt) {
    age += dt;
    final double drag = math.pow(0.92, dt * 60).toDouble();
    velocity = Offset(
      velocity.dx * drag,
      velocity.dy * drag + _gravity * dt,
    );
    position = position + velocity * dt;
  }

  double get alpha {
    final double t = (age / life).clamp(0.0, 1.0);
    return (1 - t) * (1 - t);
  }
}

class _FireworksPainter extends CustomPainter {
  _FireworksPainter(this.fireworks);
  final List<_Firework> fireworks;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;
    for (final _Firework f in fireworks) {
      for (final _Particle p in f.particles) {
        if (p.age >= p.life) continue;
        final double a = p.alpha;
        paint.color = p.color.withValues(alpha: a);
        canvas.drawCircle(p.position, 2.5 * (0.5 + a), paint);

        paint.color = p.color.withValues(alpha: a * 0.35);
        canvas.drawCircle(
          p.position - p.velocity * 0.025,
          1.4 * (0.5 + a),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworksPainter old) => true;
}
