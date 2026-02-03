import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaterProgressIndicator extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double goal;
  final double current;
  final String unit;
  final double size;

  const WaterProgressIndicator({
    super.key,
    required this.progress,
    required this.goal,
    required this.current,
    this.unit = 'ml',
    this.size = 200,
  });

  @override
  State<WaterProgressIndicator> createState() => WaterProgressIndicatorState();
}

class WaterProgressIndicatorState extends State<WaterProgressIndicator>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _celebrateController;

  double _animatedProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _animatedProgress = widget.progress.clamp(0.0, 1.0);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
  }

  @override
  void didUpdateWidget(covariant WaterProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newProgress = widget.progress.clamp(0.0, 1.0);
    if (newProgress != _animatedProgress) {
      final tween = Tween<double>(begin: _animatedProgress, end: newProgress);
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 450),
      );

      controller.addListener(() {
        final curvedValue = Curves.easeOutCubic.transform(controller.value);
        setState(() {
          _animatedProgress = tween.transform(curvedValue);
        });
      });

      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed ||
            status == AnimationStatus.dismissed) {
          controller.dispose();
        }
      });

      controller.forward();
    }
  }

  // Public methods for external triggers (optional for future use)
  void triggerPulse() {
    _pulseController
      ..reset()
      ..forward();
  }

  void triggerCelebrate() {
    if (_celebrateController.isAnimating) return;
    _celebrateController
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final goal = widget.goal;
    final current = widget.current;
    final unit = widget.unit;

    return AnimatedBuilder(
      animation: Listenable.merge(
        [_waveController, _pulseController, _celebrateController],
      ),
      builder: (context, child) {
        final pulseScale =
            1.0 + 0.05 * Curves.easeOut.transform(_pulseController.value);
        final celebrateValue = Curves.easeOutQuad.transform(
          _celebrateController.value,
        );

        return Transform.scale(
          scale: pulseScale,
          child: SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                CustomPaint(
                  size: Size.square(size),
                  painter: _WaterWavePainter(
                    progress: _animatedProgress,
                    wavePhase: _waveController.value * 2 * math.pi,
                    celebrateValue: celebrateValue,
                  ),
                ),
                // Center text
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      current.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A237E), // deep indigo
                        letterSpacing: -0.03,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'of ${goal.toStringAsFixed(0)} $unit',
                      style: TextStyle(
                        fontSize: size * 0.09,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A237E), // deep indigo
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WaterWavePainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final double celebrateValue;

  _WaterWavePainter({
    required this.progress,
    required this.wavePhase,
    required this.celebrateValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0xFFE0E7FF) // indigo border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    // Progress ring with blue gradient
    final ringPaint = Paint()
      ..shader = progress >= 1.0
          ? LinearGradient(
              colors: [
                const Color(0xFF10B981), // vibrant green for goal
                const Color(0xFF059669),
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius - 6))
          : LinearGradient(
              colors: [
                const Color(0xFF448AFF), // bright blue
                const Color(0xFF00E5FF), // cyan
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius - 6))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    // Draw background ring
    canvas.drawCircle(center, radius - 6, bgPaint);

    // Draw progress ring (arc)
    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius - 6);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      ringPaint,
    );

    // Clip to inner circle for wave and inner fill
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius - 12));
    canvas.save();
    canvas.clipPath(clipPath);

    // Soft background fill inside circle (light blue tint)
    final bgFillPaint = Paint()
      ..color = const Color(0xFFEEF2FF); // very light blue
    canvas.drawRect(Offset.zero & size, bgFillPaint);

    // Base height: higher with progress
    final clampedProgress = progress.clamp(0.0, 1.0);
    final baseHeight = size.height * (1.0 - clampedProgress);

    // Create two layered waves for depth, with gentler motion
    void drawWaveLayer({
      required double amplitude,
      required double frequency,
      required double phaseOffset,
      required List<Color> colors,
      required double opacity,
    }) {
      final wavePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(1 - opacity),
          BlendMode.modulate,
        );

      final path = Path()..moveTo(0, baseHeight);
      for (double x = 0; x <= size.width; x += 2) {
        final y = baseHeight +
            math.sin(
                  (x / size.width * frequency * 2 * math.pi) +
                      wavePhase +
                      phaseOffset,
                ) *
                amplitude;
        path.lineTo(x, y);
      }
      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      canvas.drawPath(path, wavePaint);
    }

    // Vibrant blue waves with cyan-to-blue gradient
    drawWaveLayer(
      amplitude: 4.0,
      frequency: 1.2,
      phaseOffset: 0,
      colors: const [
        Color(0xFF00E5FF), // cyan
        Color(0xFF2979FF), // bright blue
      ],
      opacity: 1.0,
    );

    drawWaveLayer(
      amplitude: 3.0,
      frequency: 0.9,
      phaseOffset: math.pi / 2,
      colors: const [
        Color(0xFF448AFF), // bright blue
        Color(0xFF2962FF), // vibrant blue
      ],
      opacity: 0.8,
    );

    // Blue-tinted overlay gradient for depth
    final overlayPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.0),
          const Color(0xFF448AFF).withOpacity(0.1),
          const Color(0xFF2962FF).withOpacity(0.2),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawRect(Offset.zero & size, overlayPaint);

    canvas.restore();

    // Celebration glow with vibrant blue
    if (celebrateValue > 0) {
      final glowPaint = Paint()
        ..color = const Color(0xFF2962FF).withOpacity(0.4 * (1 - celebrateValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16 * (1 + celebrateValue);
      canvas.drawCircle(center, radius - 6, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.celebrateValue != celebrateValue;
  }
}
