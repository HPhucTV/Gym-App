import 'dart:math' as math;
import 'package:flutter/material.dart';

enum ParticleShape { rectangle, circle, triangle }

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  double vx;
  double vy;
  double rotation;
  final double rotationSpeed;
  final ParticleShape shape;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
  });
}

class ConfettiCelebration extends StatefulWidget {
  final bool isActive;
  final Duration duration;
  final VoidCallback onFinished;

  const ConfettiCelebration({
    super.key,
    required this.isActive,
    this.duration = const Duration(milliseconds: 3000),
    required this.onFinished,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  Size _canvasSize = Size.zero;
  bool _initialized = false;

  final List<Color> _colors = const [
    Color(0xFFF97316), // Orange
    Color(0xFF22C55E), // Green
    Color(0xFF3B82F6), // Blue
    Color(0xFFEAB308), // Yellow
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(_updateParticles);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFinished();
      }
    });

    if (widget.isActive) {
      _startCelebration();
    }
  }

  @override
  void didUpdateWidget(ConfettiCelebration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _startCelebration();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopCelebration();
    }
  }

  void _startCelebration() {
    _initialized = false;
    _particles.clear();
    _controller.forward(from: 0.0);
  }

  void _stopCelebration() {
    _controller.stop();
    _particles.clear();
  }

  void _initParticles(Size size) {
    if (_initialized || size.width == 0 || size.height == 0) return;

    for (int i = 0; i < 120; i++) {
      final startX = size.width * _random.nextDouble();
      final startY = -20.0; // Spawn slightly above top of view
      final speedAngle = _random.nextDouble() * math.pi * 2;
      final speedMag = 1.5 + _random.nextDouble() * 4.5;
      final shape = ParticleShape.values[_random.nextInt(ParticleShape.values.length)];

      _particles.add(
        ConfettiParticle(
          x: startX,
          y: startY,
          color: _colors[_random.nextInt(_colors.length)],
          size: 6.0 + _random.nextDouble() * 10.0,
          vx: math.cos(speedAngle) * speedMag,
          vy: 3.0 + _random.nextDouble() * 6.0,
          rotation: _random.nextDouble() * 360.0,
          rotationSpeed: -6.0 + _random.nextDouble() * 12.0,
          shape: shape,
        ),
      );
    }
    _initialized = true;
  }

  void _updateParticles() {
    if (!_initialized) return;

    const gravity = 0.15;
    for (final p in _particles) {
      p.x += p.vx;
      p.y += p.vy;
      p.vy += gravity;
      p.vx *= 0.98; // Wind resistance
      p.rotation += p.rotationSpeed;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (_canvasSize != size) {
          _canvasSize = size;
          _initParticles(size);
        }

        return IgnorePointer(
          child: CustomPaint(
            size: size,
            painter: ConfettiPainter(particles: _particles),
          ),
        );
      },
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  ConfettiPainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation * math.pi / 180);

      switch (p.shape) {
        case ParticleShape.rectangle:
          canvas.drawRect(
            Rect.fromLTWH(-p.size / 2, -p.size / 4, p.size, p.size / 2),
            paint,
          );
          break;
        case ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case ParticleShape.triangle:
          final path = Path()
            ..moveTo(0, -p.size / 2)
            ..lineTo(-p.size / 2, p.size / 2)
            ..lineTo(p.size / 2, p.size / 2)
            ..close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) => true;
}
